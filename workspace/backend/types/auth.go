package types

import (
	"context"
	"errors"
	"strings"
	"time"
	"unicode"
)

type ClientType string

const (
	ClientTypeWeb    ClientType = "web"
	ClientTypeMobile ClientType = "mobile"
)

type User struct {
	ID        int64     `json:"id"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"createdAt"`
}

type Session struct {
	ID         int64
	UserID     int64
	TokenHash  string
	CSRFToken  string
	ClientType ClientType
	ExpiresAt  time.Time
	RevokedAt  *time.Time
	CreatedAt  time.Time
	LastUsedAt time.Time
}

type AuthRequest struct {
	Email           string `json:"email"`
	Password        string `json:"password"`
	ConfirmPassword string `json:"confirmPassword,omitempty"`
}

type WebAuthResponse struct {
	User      User   `json:"user"`
	CSRFToken string `json:"csrfToken"`
}

type MobileAuthResponse struct {
	User  User   `json:"user"`
	Token string `json:"token"`
}

type MeResponse struct {
	User User `json:"user"`
}

type ErrorResponse struct {
	Message string `json:"message"`
}

type AuthContext struct {
	User    User
	Session Session
}

type UserRecord struct {
	User
	PasswordHash string
}

type AuthStore interface {
	CreateUser(ctx context.Context, email string, passwordHash string) (User, error)
	GetUserByEmail(ctx context.Context, email string) (UserRecord, error)
	GetUserByID(ctx context.Context, userID int64) (User, error)
	CreateSession(ctx context.Context, session Session) error
	GetSessionByHash(ctx context.Context, tokenHash string) (Session, error)
	TouchSession(ctx context.Context, sessionID int64, expiresAt time.Time) error
	RevokeSession(ctx context.Context, sessionID int64) error
}

type IssuedSession struct {
	Token     string
	CSRFToken string
	ExpiresAt time.Time
}

const PasswordPolicyMessage = "password must be at least 8 characters and include uppercase, lowercase, number, and symbol"

var (
	ErrNotFound             = errors.New("not found")
	ErrInvalidCredentials   = errors.New("invalid email or password")
	ErrInvalidRegistration  = errors.New("email, password, and password confirmation are required")
	ErrPasswordConfirmation = errors.New("password confirmation does not match")
	ErrWeakPassword         = errors.New(PasswordPolicyMessage)
	ErrEmailExists          = errors.New("email already registered")
	ErrUnauthorized         = errors.New("unauthorized")
	ErrForbidden            = errors.New("forbidden")
)

func ValidatePasswordComplexity(password string) error {
	if len(password) < 8 {
		return ErrWeakPassword
	}

	var hasUpper bool
	var hasLower bool
	var hasDigit bool
	var hasSymbol bool

	for _, character := range password {
		switch {
		case unicode.IsUpper(character):
			hasUpper = true
		case unicode.IsLower(character):
			hasLower = true
		case unicode.IsDigit(character):
			hasDigit = true
		case strings.ContainsRune("!@#$%^&*()_+-=[]{}|;:,.<>?/~`", character):
			hasSymbol = true
		case unicode.IsPunct(character) || unicode.IsSymbol(character):
			hasSymbol = true
		}
	}

	if hasUpper && hasLower && hasDigit && hasSymbol {
		return nil
	}

	return ErrWeakPassword
}
