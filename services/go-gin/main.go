package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "3004"
	}

	r := gin.Default()
	r.GET("/", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"service":   "go-gin",
			"framework": "gin",
		})
	})

	log.Printf("go-gin listening on http://127.0.0.1:%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}