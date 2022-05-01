package postgres

import "database/sql"

type PostRepository struct {
	db *sql.DB
}
