package main

import (
	"database/sql"
	"fmt"
	"log"
	postApi "megaphone-server/interface/post/api"

	"github.com/gin-gonic/gin"
	migrate "github.com/golang-migrate/migrate/v4"
	migratePostgres "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	_ "github.com/lib/pq"
)

const (
	pgHost     = "localhost"
	pgPort     = 5432
	pgUser     = "postgres"
	pgPass     = "postgres"
	pgDatabase = "postgres"
)

func main() {
	connStr := fmt.Sprintf("postgresql://%s:%s@%s:%d/%s?sslmode=disable", pgUser, pgPass, pgHost, pgPort, pgDatabase)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		panic(err)
	}
	defer db.Close()
	log.Printf("Connected to Postgres at %s:%d", pgHost, pgPort)

	err = runMigrations(db)
	if err != nil {
		panic(err)
	}

	postHandler := postApi.PostHandler{}

	r := gin.Default()
	r.GET("/posts", postHandler.GetPosts)

	r.Run(":8000")
}

func runMigrations(db *sql.DB) error {
	driver, err := migratePostgres.WithInstance(db, &migratePostgres.Config{})
	if err != nil {
		return err
	}
	m, err := migrate.NewWithDatabaseInstance("file://migrations", "postgres", driver)
	if err != nil {
		return err
	}
	err = m.Up()
	if err != nil {
		return err
	}
	return nil
}
