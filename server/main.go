package main

import (
	"megaphone-server/interface/post/api"

	"github.com/gin-gonic/gin"
)

func main() {
	postHandler := api.PostHandler{}

	r := gin.Default()
	r.GET("/posts", postHandler.GetPosts)

	r.Run(":8000")
}
