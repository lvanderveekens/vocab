package api

import (
	"megaphone-server/usecase/post"

	"github.com/gin-gonic/gin"
)

type PostHandler struct {
	postRepository post.PostRepository
}

func NewPostHandler(postRepository post.PostRepository) *PostHandler {
	return &PostHandler{
		postRepository: postRepository,
	}
}

func (h *PostHandler) GetPosts(c *gin.Context) {
	posts, err := h.postRepository.FindAll()
	if err != nil {
		// TODO: error handling
		panic(err)
	}

	c.JSON(200, posts)
}
