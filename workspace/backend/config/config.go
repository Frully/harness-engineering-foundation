package config

import (
	"flag"
	"os"
	"strconv"
	"time"
)

type Config struct {
	Port          int
	DBPath        string
	CookieName    string
	CookieSecure  bool
	SessionTTL    time.Duration
	AllowedOrigin string
}

func Load() Config {
	cfg := Config{
		Port:          getenvInt("PORT", 8080),
		DBPath:        getenvString("DB_PATH", "workspace/backend/testdata/dev.sqlite"),
		CookieName:    getenvString("COOKIE_NAME", "hed_session"),
		CookieSecure:  getenvBool("COOKIE_SECURE", false),
		SessionTTL:    getenvDuration("SESSION_TTL", 24*time.Hour),
		AllowedOrigin: getenvString("ALLOWED_ORIGIN", "http://127.0.0.1:4173"),
	}

	// Allow smoke/tests to override without env churn.
	flag.IntVar(&cfg.Port, "port", cfg.Port, "server port")
	flag.StringVar(&cfg.DBPath, "db", cfg.DBPath, "sqlite database path")
	flag.Parse()
	return cfg
}

func getenvString(name string, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func getenvBool(name string, fallback bool) bool {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}

	parsed, err := strconv.ParseBool(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func getenvInt(name string, fallback int) int {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}

	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func getenvDuration(name string, fallback time.Duration) time.Duration {
	value := os.Getenv(name)
	if value == "" {
		return fallback
	}

	parsed, err := time.ParseDuration(value)
	if err != nil {
		return fallback
	}
	return parsed
}
