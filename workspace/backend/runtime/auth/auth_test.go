package auth_test

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	"harness-engineering-foundation/backend/composition"
	"harness-engineering-foundation/backend/config"
)

func TestAuthRegisterSupportsWebAndMobileSessions(t *testing.T) {
	server := newAuthTestServer(t)
	defer server.Close()

	webRegister := postJSON(t, server.URL+"/api/auth/register", map[string]string{
		"email":    "web@example.com",
		"password": "hunter2",
	}, nil)
	if webRegister.StatusCode != http.StatusOK {
		t.Fatalf("web register status = %d", webRegister.StatusCode)
	}
	if len(webRegister.Cookies()) == 0 {
		t.Fatal("expected web register to set a session cookie")
	}

	mobileRegister := postJSON(t, server.URL+"/api/auth/register", map[string]string{
		"email":    "mobile@example.com",
		"password": "hunter2",
	}, map[string]string{"X-Client-Type": "mobile"})
	if mobileRegister.StatusCode != http.StatusOK {
		t.Fatalf("mobile register status = %d", mobileRegister.StatusCode)
	}

	var mobileBody struct {
		Token string `json:"token"`
	}
	decodeBody(t, mobileRegister, &mobileBody)
	if mobileBody.Token == "" {
		t.Fatal("expected mobile register to return a bearer token")
	}
}

func TestAuthLoginAcceptsValidCredentialsAndRejectsInvalidPassword(t *testing.T) {
	server := newAuthTestServer(t)
	defer server.Close()

	register := postJSON(t, server.URL+"/api/auth/register", map[string]string{
		"email":    "repeat@example.com",
		"password": "hunter2",
	}, nil)
	if register.StatusCode != http.StatusOK {
		t.Fatalf("register status = %d", register.StatusCode)
	}

	login := postJSON(t, server.URL+"/api/auth/login", map[string]string{
		"email":    "repeat@example.com",
		"password": "hunter2",
	}, nil)
	if login.StatusCode != http.StatusOK {
		t.Fatalf("login status = %d", login.StatusCode)
	}

	badLogin := postJSON(t, server.URL+"/api/auth/login", map[string]string{
		"email":    "repeat@example.com",
		"password": "wrong-password",
	}, nil)
	if badLogin.StatusCode != http.StatusUnauthorized {
		t.Fatalf("bad login status = %d", badLogin.StatusCode)
	}
}

func TestAuthLogoutRevokesCookieAndBearerSessions(t *testing.T) {
	server := newAuthTestServer(t)
	defer server.Close()

	webRegister := postJSON(t, server.URL+"/api/auth/register", map[string]string{
		"email":    "logout-web@example.com",
		"password": "hunter2",
	}, nil)
	if webRegister.StatusCode != http.StatusOK {
		t.Fatalf("web register status = %d", webRegister.StatusCode)
	}

	webCookie := webRegister.Cookies()[0]
	var webBody struct {
		CSRFToken string `json:"csrfToken"`
	}
	decodeBody(t, webRegister, &webBody)

	webLogout, _ := http.NewRequest(http.MethodPost, server.URL+"/api/auth/logout", nil)
	webLogout.AddCookie(webCookie)
	webLogout.Header.Set("X-CSRF-Token", webBody.CSRFToken)
	webLogoutResponse, err := http.DefaultClient.Do(webLogout)
	if err != nil {
		t.Fatalf("web logout request: %v", err)
	}
	if webLogoutResponse.StatusCode != http.StatusNoContent {
		t.Fatalf("web logout status = %d", webLogoutResponse.StatusCode)
	}

	webMe, _ := http.NewRequest(http.MethodGet, server.URL+"/api/me", nil)
	webMe.AddCookie(webCookie)
	webMeResponse, err := http.DefaultClient.Do(webMe)
	if err != nil {
		t.Fatalf("web me request: %v", err)
	}
	if webMeResponse.StatusCode != http.StatusUnauthorized {
		t.Fatalf("web me after logout status = %d", webMeResponse.StatusCode)
	}

	mobileRegister := postJSON(t, server.URL+"/api/auth/register", map[string]string{
		"email":    "logout-mobile@example.com",
		"password": "hunter2",
	}, map[string]string{"X-Client-Type": "mobile"})
	if mobileRegister.StatusCode != http.StatusOK {
		t.Fatalf("mobile register status = %d", mobileRegister.StatusCode)
	}

	var mobileBody struct {
		Token string `json:"token"`
	}
	decodeBody(t, mobileRegister, &mobileBody)

	mobileLogout, _ := http.NewRequest(http.MethodPost, server.URL+"/api/auth/logout", nil)
	mobileLogout.Header.Set("Authorization", "Bearer "+mobileBody.Token)
	mobileLogoutResponse, err := http.DefaultClient.Do(mobileLogout)
	if err != nil {
		t.Fatalf("mobile logout request: %v", err)
	}
	if mobileLogoutResponse.StatusCode != http.StatusNoContent {
		t.Fatalf("mobile logout status = %d", mobileLogoutResponse.StatusCode)
	}
}

func newAuthTestServer(t *testing.T) *httptest.Server {
	t.Helper()

	dbPath := filepath.Join(t.TempDir(), "auth.sqlite")
	cfg := config.Config{
		DBPath:        dbPath,
		CookieName:    "hed_session",
		CookieSecure:  false,
		SessionTTL:    time.Hour,
		AllowedOrigin: "http://127.0.0.1:4173",
	}

	app, err := composition.Build(cfg, log.New(os.Stdout, "", 0))
	if err != nil {
		t.Fatalf("build app: %v", err)
	}
	t.Cleanup(func() {
		if closeErr := app.Repo.Close(); closeErr != nil {
			t.Fatalf("close repo: %v", closeErr)
		}
	})

	server := httptest.NewServer(app.Server.Handler())
	t.Cleanup(server.Close)
	return server
}

func postJSON(t *testing.T, url string, body map[string]string, headers map[string]string) *http.Response {
	t.Helper()

	payload, err := json.Marshal(body)
	if err != nil {
		t.Fatalf("marshal body: %v", err)
	}

	request, err := http.NewRequest(http.MethodPost, url, bytes.NewReader(payload))
	if err != nil {
		t.Fatalf("new request: %v", err)
	}
	request.Header.Set("Content-Type", "application/json")
	for key, value := range headers {
		request.Header.Set(key, value)
	}

	response, err := http.DefaultClient.Do(request)
	if err != nil {
		t.Fatalf("post request: %v", err)
	}
	return response
}

func decodeBody(t *testing.T, response *http.Response, out any) {
	t.Helper()
	defer response.Body.Close()
	if err := json.NewDecoder(response.Body).Decode(out); err != nil {
		t.Fatalf("decode body: %v", err)
	}
}
