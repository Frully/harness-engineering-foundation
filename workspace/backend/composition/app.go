package composition

import (
	"log"

	"harness-engineering-foundation/backend/config"
	"harness-engineering-foundation/backend/repo"
	"harness-engineering-foundation/backend/runtime"
	"harness-engineering-foundation/backend/service"
)

type App struct {
	Server *runtime.Server
	Repo   *repo.SQLiteRepo
}

func Build(cfg config.Config, logger *log.Logger) (*App, error) {
	sqliteRepo, err := repo.NewSQLiteRepo(cfg.DBPath)
	if err != nil {
		return nil, err
	}

	authService := service.NewAuthService(sqliteRepo, cfg.SessionTTL)
	server := runtime.NewServer(cfg, authService, logger)

	return &App{
		Server: server,
		Repo:   sqliteRepo,
	}, nil
}
