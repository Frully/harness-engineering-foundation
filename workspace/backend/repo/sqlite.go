package repo

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"time"

	_ "modernc.org/sqlite"

	"harness-engineering-foundation/backend/types"
)

type SQLiteRepo struct {
	db *sql.DB
}

func NewSQLiteRepo(dbPath string) (*SQLiteRepo, error) {
	if err := os.MkdirAll(filepath.Dir(dbPath), 0o755); err != nil {
		return nil, fmt.Errorf("create db dir: %w", err)
	}

	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return nil, fmt.Errorf("open db: %w", err)
	}

	repo := &SQLiteRepo{db: db}
	if err := repo.migrate(context.Background()); err != nil {
		_ = db.Close()
		return nil, err
	}

	return repo, nil
}

func (r *SQLiteRepo) Close() error {
	if r.db == nil {
		return nil
	}
	return r.db.Close()
}

func (r *SQLiteRepo) migrate(ctx context.Context) error {
	schema := `
	CREATE TABLE IF NOT EXISTS users (
	  id INTEGER PRIMARY KEY AUTOINCREMENT,
	  email TEXT NOT NULL UNIQUE,
	  password_hash TEXT NOT NULL,
	  created_at TEXT NOT NULL
	);

	CREATE TABLE IF NOT EXISTS sessions (
	  id INTEGER PRIMARY KEY AUTOINCREMENT,
	  user_id INTEGER NOT NULL,
	  token_hash TEXT NOT NULL UNIQUE,
	  csrf_token TEXT NOT NULL,
	  client_type TEXT NOT NULL,
	  expires_at TEXT NOT NULL,
	  revoked_at TEXT,
	  created_at TEXT NOT NULL,
	  last_used_at TEXT NOT NULL,
	  FOREIGN KEY(user_id) REFERENCES users(id)
	);
	`

	if _, err := r.db.ExecContext(ctx, schema); err != nil {
		return fmt.Errorf("migrate schema: %w", err)
	}
	return nil
}

func (r *SQLiteRepo) CreateUser(ctx context.Context, email string, passwordHash string) (types.User, error) {
	now := time.Now().UTC()
	result, err := r.db.ExecContext(
		ctx,
		`INSERT INTO users (email, password_hash, created_at) VALUES (?, ?, ?)`,
		email,
		passwordHash,
		now.Format(time.RFC3339Nano),
	)
	if err != nil {
		return types.User{}, fmt.Errorf("insert user: %w", err)
	}

	id, err := result.LastInsertId()
	if err != nil {
		return types.User{}, fmt.Errorf("last insert id: %w", err)
	}

	return types.User{
		ID:        id,
		Email:     email,
		CreatedAt: now,
	}, nil
}

func (r *SQLiteRepo) GetUserByEmail(ctx context.Context, email string) (types.UserRecord, error) {
	row := r.db.QueryRowContext(
		ctx,
		`SELECT id, email, password_hash, created_at FROM users WHERE email = ?`,
		email,
	)
	return scanUserRecord(row)
}

func (r *SQLiteRepo) GetUserByID(ctx context.Context, userID int64) (types.User, error) {
	row := r.db.QueryRowContext(
		ctx,
		`SELECT id, email, created_at FROM users WHERE id = ?`,
		userID,
	)

	var (
		user      types.User
		createdAt string
	)
	if err := row.Scan(&user.ID, &user.Email, &createdAt); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.User{}, types.ErrNotFound
		}
		return types.User{}, fmt.Errorf("scan user: %w", err)
	}

	parsed, err := time.Parse(time.RFC3339Nano, createdAt)
	if err != nil {
		return types.User{}, fmt.Errorf("parse created_at: %w", err)
	}
	user.CreatedAt = parsed
	return user, nil
}

func (r *SQLiteRepo) CreateSession(ctx context.Context, session types.Session) error {
	_, err := r.db.ExecContext(
		ctx,
		`INSERT INTO sessions (user_id, token_hash, csrf_token, client_type, expires_at, revoked_at, created_at, last_used_at)
		 VALUES (?, ?, ?, ?, ?, NULL, ?, ?)`,
		session.UserID,
		session.TokenHash,
		session.CSRFToken,
		string(session.ClientType),
		session.ExpiresAt.Format(time.RFC3339Nano),
		session.CreatedAt.Format(time.RFC3339Nano),
		session.LastUsedAt.Format(time.RFC3339Nano),
	)
	if err != nil {
		return fmt.Errorf("insert session: %w", err)
	}
	return nil
}

func (r *SQLiteRepo) GetSessionByHash(ctx context.Context, tokenHash string) (types.Session, error) {
	row := r.db.QueryRowContext(
		ctx,
		`SELECT id, user_id, token_hash, csrf_token, client_type, expires_at, revoked_at, created_at, last_used_at
		 FROM sessions WHERE token_hash = ?`,
		tokenHash,
	)
	return scanSession(row)
}

func (r *SQLiteRepo) TouchSession(ctx context.Context, sessionID int64, expiresAt time.Time) error {
	now := time.Now().UTC()
	_, err := r.db.ExecContext(
		ctx,
		`UPDATE sessions SET last_used_at = ?, expires_at = ? WHERE id = ?`,
		now.Format(time.RFC3339Nano),
		expiresAt.Format(time.RFC3339Nano),
		sessionID,
	)
	if err != nil {
		return fmt.Errorf("touch session: %w", err)
	}
	return nil
}

func (r *SQLiteRepo) RevokeSession(ctx context.Context, sessionID int64) error {
	now := time.Now().UTC()
	_, err := r.db.ExecContext(
		ctx,
		`UPDATE sessions SET revoked_at = ? WHERE id = ?`,
		now.Format(time.RFC3339Nano),
		sessionID,
	)
	if err != nil {
		return fmt.Errorf("revoke session: %w", err)
	}
	return nil
}

type scanner interface {
	Scan(dest ...any) error
}

func scanUserRecord(row scanner) (types.UserRecord, error) {
	var (
		record    types.UserRecord
		createdAt string
	)
	if err := row.Scan(&record.ID, &record.Email, &record.PasswordHash, &createdAt); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.UserRecord{}, types.ErrNotFound
		}
		return types.UserRecord{}, fmt.Errorf("scan user record: %w", err)
	}

	parsed, err := time.Parse(time.RFC3339Nano, createdAt)
	if err != nil {
		return types.UserRecord{}, fmt.Errorf("parse created_at: %w", err)
	}
	record.CreatedAt = parsed
	return record, nil
}

func scanSession(row scanner) (types.Session, error) {
	var (
		session    types.Session
		clientType string
		expiresAt  string
		revokedAt  sql.NullString
		createdAt  string
		lastUsedAt string
	)

	if err := row.Scan(
		&session.ID,
		&session.UserID,
		&session.TokenHash,
		&session.CSRFToken,
		&clientType,
		&expiresAt,
		&revokedAt,
		&createdAt,
		&lastUsedAt,
	); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return types.Session{}, types.ErrNotFound
		}
		return types.Session{}, fmt.Errorf("scan session: %w", err)
	}

	parsedExpiresAt, err := time.Parse(time.RFC3339Nano, expiresAt)
	if err != nil {
		return types.Session{}, fmt.Errorf("parse expires_at: %w", err)
	}
	parsedCreatedAt, err := time.Parse(time.RFC3339Nano, createdAt)
	if err != nil {
		return types.Session{}, fmt.Errorf("parse created_at: %w", err)
	}
	parsedLastUsedAt, err := time.Parse(time.RFC3339Nano, lastUsedAt)
	if err != nil {
		return types.Session{}, fmt.Errorf("parse last_used_at: %w", err)
	}

	session.ClientType = types.ClientType(clientType)
	session.ExpiresAt = parsedExpiresAt
	session.CreatedAt = parsedCreatedAt
	session.LastUsedAt = parsedLastUsedAt

	if revokedAt.Valid {
		parsedRevokedAt, err := time.Parse(time.RFC3339Nano, revokedAt.String)
		if err != nil {
			return types.Session{}, fmt.Errorf("parse revoked_at: %w", err)
		}
		session.RevokedAt = &parsedRevokedAt
	}

	return session, nil
}
