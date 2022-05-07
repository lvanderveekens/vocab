package domain

import "time"

type Post struct {
	Id        int       `json:"id"`
	CreatedAt time.Time `json:"created_at"`
}
