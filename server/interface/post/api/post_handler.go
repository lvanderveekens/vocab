package api

import "github.com/gin-gonic/gin"

type PostHandler struct{}

func (h *PostHandler) GetPosts(c *gin.Context) {
	post1 := PostDTO{Id: 1, Name: "Chicken"}
	post2 := PostDTO{Id: 2, Name: "Pizza"}
	post3 := PostDTO{Id: 3, Name: "Pasta"}
	post4 := PostDTO{Id: 4, Name: "Spaghetti"}
	posts := []PostDTO{post1, post2, post3, post4}

	c.JSON(200, posts)
}
