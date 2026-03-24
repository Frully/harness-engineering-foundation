package runtime

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strings"

	"harness-engineering-foundation/backend/config"
	"harness-engineering-foundation/backend/types"
)

type AuthUseCase interface {
	Register(ctx context.Context, email string, password string, clientType types.ClientType) (types.User, *types.IssuedSession, error)
	Login(ctx context.Context, email string, password string, clientType types.ClientType) (types.User, *types.IssuedSession, error)
	Authenticate(ctx context.Context, rawToken string) (*types.AuthContext, error)
	Logout(ctx context.Context, sessionID int64) error
	ValidateCSRF(session types.Session, token string) error
}

type Server struct {
	cfg  config.Config
	auth AuthUseCase
	log  *log.Logger
}

func NewServer(cfg config.Config, auth AuthUseCase, logger *log.Logger) *Server {
	return &Server{
		cfg:  cfg,
		auth: auth,
		log:  logger,
	}
}

func (s *Server) Handler() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", s.handleHealth)
	mux.HandleFunc("POST /api/auth/register", s.handleRegister)
	mux.HandleFunc("POST /api/auth/login", s.handleLogin)
	mux.Handle("POST /api/auth/logout", s.withAuth(s.handleLogout))
	mux.Handle("GET /api/me", s.withAuth(s.handleMe))
	return s.withCORS(s.withLogging(mux))
}

func (s *Server) handleHealth(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func (s *Server) handleRegister(w http.ResponseWriter, r *http.Request) {
	s.handleAuthMutation(w, r, true)
}

func (s *Server) handleLogin(w http.ResponseWriter, r *http.Request) {
	s.handleAuthMutation(w, r, false)
}

func (s *Server) handleAuthMutation(w http.ResponseWriter, r *http.Request, register bool) {
	clientType := detectClientType(r)
	var request types.AuthRequest
	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	var (
		user    types.User
		session *types.IssuedSession
		err     error
	)

	if register {
		user, session, err = s.auth.Register(r.Context(), request.Email, request.Password, clientType)
	} else {
		user, session, err = s.auth.Login(r.Context(), request.Email, request.Password, clientType)
	}
	if err != nil {
		status, message := statusForError(err)
		writeError(w, status, message)
		return
	}

	if clientType == types.ClientTypeWeb {
		s.setSessionCookie(w, session.Token)
		writeJSON(w, http.StatusOK, types.WebAuthResponse{
			User:      user,
			CSRFToken: session.CSRFToken,
		})
		return
	}

	writeJSON(w, http.StatusOK, types.MobileAuthResponse{
		User:  user,
		Token: session.Token,
	})
}

func (s *Server) handleLogout(w http.ResponseWriter, r *http.Request) {
	authContext, ok := authContextFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	if authContext.Session.ClientType == types.ClientTypeWeb {
		if err := s.auth.ValidateCSRF(authContext.Session, r.Header.Get("X-CSRF-Token")); err != nil {
			writeError(w, http.StatusForbidden, "invalid csrf token")
			return
		}
	}

	if err := s.auth.Logout(r.Context(), authContext.Session.ID); err != nil {
		writeError(w, http.StatusInternalServerError, "failed to logout")
		return
	}

	s.clearSessionCookie(w)
	w.WriteHeader(http.StatusNoContent)
}

func (s *Server) handleMe(w http.ResponseWriter, r *http.Request) {
	authContext, ok := authContextFromRequest(r)
	if !ok {
		writeError(w, http.StatusUnauthorized, "unauthorized")
		return
	}

	writeJSON(w, http.StatusOK, types.MeResponse{User: authContext.User})
}

func (s *Server) withAuth(next http.HandlerFunc) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rawToken, clientType := extractToken(r, s.cfg.CookieName)
		authContext, err := s.auth.Authenticate(r.Context(), rawToken)
		if err != nil {
			if errors.Is(err, types.ErrUnauthorized) {
				writeError(w, http.StatusUnauthorized, "unauthorized")
				return
			}
			writeError(w, http.StatusInternalServerError, "authentication failed")
			return
		}

		// Enforce transport parity: web cookies stay web, bearer stays mobile.
		if authContext.Session.ClientType != clientType {
			writeError(w, http.StatusUnauthorized, "unauthorized")
			return
		}

		ctx := context.WithValue(r.Context(), authContextKey{}, authContext)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func (s *Server) withCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", s.cfg.AllowedOrigin)
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-CSRF-Token, X-Client-Type")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}

func (s *Server) withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		s.log.Printf("%s %s", r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

func (s *Server) setSessionCookie(w http.ResponseWriter, token string) {
	http.SetCookie(w, &http.Cookie{
		Name:     s.cfg.CookieName,
		Value:    token,
		Path:     "/",
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		Secure:   s.cfg.CookieSecure,
	})
}

func (s *Server) clearSessionCookie(w http.ResponseWriter) {
	http.SetCookie(w, &http.Cookie{
		Name:     s.cfg.CookieName,
		Value:    "",
		Path:     "/",
		MaxAge:   -1,
		HttpOnly: true,
		SameSite: http.SameSiteLaxMode,
		Secure:   s.cfg.CookieSecure,
	})
}

type authContextKey struct{}

func authContextFromRequest(r *http.Request) (*types.AuthContext, bool) {
	value := r.Context().Value(authContextKey{})
	authContext, ok := value.(*types.AuthContext)
	return authContext, ok
}

func detectClientType(r *http.Request) types.ClientType {
	if strings.EqualFold(r.Header.Get("X-Client-Type"), string(types.ClientTypeMobile)) {
		return types.ClientTypeMobile
	}
	return types.ClientTypeWeb
}

func extractToken(r *http.Request, cookieName string) (string, types.ClientType) {
	if header := r.Header.Get("Authorization"); strings.HasPrefix(strings.ToLower(header), "bearer ") {
		return strings.TrimSpace(header[len("Bearer "):]), types.ClientTypeMobile
	}

	cookie, err := r.Cookie(cookieName)
	if err == nil {
		return cookie.Value, types.ClientTypeWeb
	}

	return "", types.ClientTypeWeb
}

func statusForError(err error) (int, string) {
	switch {
	case errors.Is(err, types.ErrEmailExists):
		return http.StatusConflict, "email already registered"
	case errors.Is(err, types.ErrInvalidCredentials):
		return http.StatusUnauthorized, "invalid email or password"
	default:
		return http.StatusInternalServerError, "request failed"
	}
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, types.ErrorResponse{Message: message})
}

func ListenAndServe(cfg config.Config, handler http.Handler) error {
	address := fmt.Sprintf(":%d", cfg.Port)
	return http.ListenAndServe(address, handler)
}
