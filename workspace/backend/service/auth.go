package service

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"

	"harness-engineering-foundation/backend/types"
)

type AuthService struct {
	store      types.AuthStore
	sessionTTL time.Duration
}

func NewAuthService(store types.AuthStore, sessionTTL time.Duration) *AuthService {
	return &AuthService{
		store:      store,
		sessionTTL: sessionTTL,
	}
}

func (s *AuthService) Register(ctx context.Context, email string, password string, clientType types.ClientType) (types.User, *types.IssuedSession, error) {
	cleanEmail := strings.TrimSpace(strings.ToLower(email))
	if cleanEmail == "" || password == "" {
		return types.User{}, nil, types.ErrInvalidCredentials
	}

	if _, err := s.store.GetUserByEmail(ctx, cleanEmail); err == nil {
		return types.User{}, nil, types.ErrEmailExists
	} else if !errors.Is(err, types.ErrNotFound) {
		return types.User{}, nil, fmt.Errorf("lookup existing user: %w", err)
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return types.User{}, nil, fmt.Errorf("hash password: %w", err)
	}

	user, err := s.store.CreateUser(ctx, cleanEmail, string(passwordHash))
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "unique") {
			return types.User{}, nil, types.ErrEmailExists
		}
		return types.User{}, nil, fmt.Errorf("create user: %w", err)
	}

	session, err := s.issueSession(ctx, user.ID, clientType)
	if err != nil {
		return types.User{}, nil, err
	}

	return user, session, nil
}

func (s *AuthService) Login(ctx context.Context, email string, password string, clientType types.ClientType) (types.User, *types.IssuedSession, error) {
	cleanEmail := strings.TrimSpace(strings.ToLower(email))
	record, err := s.store.GetUserByEmail(ctx, cleanEmail)
	if err != nil {
		if errors.Is(err, types.ErrNotFound) {
			return types.User{}, nil, types.ErrInvalidCredentials
		}
		return types.User{}, nil, fmt.Errorf("get user by email: %w", err)
	}

	if bcrypt.CompareHashAndPassword([]byte(record.PasswordHash), []byte(password)) != nil {
		return types.User{}, nil, types.ErrInvalidCredentials
	}

	session, err := s.issueSession(ctx, record.ID, clientType)
	if err != nil {
		return types.User{}, nil, err
	}

	return record.User, session, nil
}

func (s *AuthService) Authenticate(ctx context.Context, rawToken string) (*types.AuthContext, error) {
	if strings.TrimSpace(rawToken) == "" {
		return nil, types.ErrUnauthorized
	}

	tokenHash := hashToken(rawToken)
	session, err := s.store.GetSessionByHash(ctx, tokenHash)
	if err != nil {
		if errors.Is(err, types.ErrNotFound) {
			return nil, types.ErrUnauthorized
		}
		return nil, fmt.Errorf("get session: %w", err)
	}

	if session.RevokedAt != nil || time.Now().UTC().After(session.ExpiresAt) {
		return nil, types.ErrUnauthorized
	}

	user, err := s.store.GetUserByID(ctx, session.UserID)
	if err != nil {
		if errors.Is(err, types.ErrNotFound) {
			return nil, types.ErrUnauthorized
		}
		return nil, fmt.Errorf("get session user: %w", err)
	}

	nextExpiry := time.Now().UTC().Add(s.sessionTTL)
	if err := s.store.TouchSession(ctx, session.ID, nextExpiry); err != nil {
		return nil, fmt.Errorf("touch session: %w", err)
	}
	session.ExpiresAt = nextExpiry

	return &types.AuthContext{
		User:    user,
		Session: session,
	}, nil
}

func (s *AuthService) Logout(ctx context.Context, sessionID int64) error {
	if err := s.store.RevokeSession(ctx, sessionID); err != nil {
		return fmt.Errorf("revoke session: %w", err)
	}
	return nil
}

func (s *AuthService) ValidateCSRF(session types.Session, token string) error {
	if session.ClientType != types.ClientTypeWeb {
		return nil
	}
	if token == "" || token != session.CSRFToken {
		return types.ErrForbidden
	}
	return nil
}

func (s *AuthService) issueSession(ctx context.Context, userID int64, clientType types.ClientType) (*types.IssuedSession, error) {
	rawToken, err := randomSecret(32)
	if err != nil {
		return nil, fmt.Errorf("generate session token: %w", err)
	}

	csrfToken, err := randomSecret(24)
	if err != nil {
		return nil, fmt.Errorf("generate csrf token: %w", err)
	}

	now := time.Now().UTC()
	session := types.Session{
		UserID:     userID,
		TokenHash:  hashToken(rawToken),
		CSRFToken:  csrfToken,
		ClientType: clientType,
		ExpiresAt:  now.Add(s.sessionTTL),
		CreatedAt:  now,
		LastUsedAt: now,
	}
	if err := s.store.CreateSession(ctx, session); err != nil {
		return nil, fmt.Errorf("create session: %w", err)
	}

	return &types.IssuedSession{
		Token:     rawToken,
		CSRFToken: csrfToken,
		ExpiresAt: session.ExpiresAt,
	}, nil
}

func hashToken(raw string) string {
	digest := sha256.Sum256([]byte(raw))
	return hex.EncodeToString(digest[:])
}

func randomSecret(length int) (string, error) {
	buffer := make([]byte, length)
	if _, err := rand.Read(buffer); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buffer), nil
}
