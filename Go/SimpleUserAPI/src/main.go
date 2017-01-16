package main

import (
	"log"

	"gopkg.in/gin-gonic/gin.v1"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/postgres"
)

func main() {

	db, err := gorm.Open("postgres", "host=localhost user=postgres dbname=postgres sslmode=disable password=postgres")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	r := gin.Default()
	r.Use(ErrorHandler)

	SetupUsers(r, db)
	SetupAuth(r, db)

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Run() // listen and serve on 0.0.0.0:8080
}
