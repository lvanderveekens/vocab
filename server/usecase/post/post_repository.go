package post

import "megaphone-server/domain"

type PostRepository interface {
	FindAll() ([]domain.Post, error)
}
