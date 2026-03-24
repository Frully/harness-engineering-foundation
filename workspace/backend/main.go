package main

import (
	"log"
	"os"

	"harness-engineering-foundation/backend/composition"
	"harness-engineering-foundation/backend/config"
	"harness-engineering-foundation/backend/runtime"
)

func main() {
	cfg := config.Load()
	logger := log.New(os.Stdout, "[backend] ", log.LstdFlags)

	app, err := composition.Build(cfg, logger)
	if err != nil {
		logger.Fatalf("failed to build application: %v", err)
	}
	defer func() {
		if closeErr := app.Repo.Close(); closeErr != nil {
			logger.Printf("failed to close repository: %v", closeErr)
		}
	}()

	logger.Printf("starting backend on :%d using db=%s", cfg.Port, cfg.DBPath)
	if err := runtime.ListenAndServe(cfg, app.Server.Handler()); err != nil {
		logger.Fatalf("server exited with error: %v", err)
	}
}
