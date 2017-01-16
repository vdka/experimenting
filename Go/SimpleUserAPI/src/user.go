package main

import (
	"net/http"
	"strings"
	"time"

	"golang.org/x/crypto/bcrypt"

	"github.com/jinzhu/gorm"
	uuid "github.com/satori/go.uuid"
	"gopkg.in/gin-gonic/gin.v1"
)

// User ..
type User struct {
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt"`

	ID uuid.UUID `sql:"type:uuid;default:uuid_generate_v4()" json:"id" gorm:"primary_key"`

	Username string `json:"username" gorm:"not null;unique"`
	Password []byte `sql:"type:varchar" json:"-" gorm:"not null"`
}

// SetupUsers ..
func SetupUsers(r *gin.Engine, db *gorm.DB) {
	db.AutoMigrate(&User{})

	authorized := r.Group("/").Use(AuthMiddleware(db))

	authorized.GET("/user", func(c *gin.Context) {
		user := c.MustGet("user").(User)
		c.JSON(200, user)
	})

	authorized.PUT("/user", func(c *gin.Context) {

		var user struct {
			User
			Username string `json:"username,omitempty"`
			Password []byte `json:"password,omitempty"`
		}

		user.User = c.MustGet("user").(User)
		tx := db.Begin()

		err := c.BindJSON(&user)
		if err != nil {
			c.AbortWithError(400, err)
		}

		err = tx.Update(&user).Error
		if err != nil {
			tx.Rollback()
			c.AbortWithError(500, err)
			return
		}

		tx.Commit()
		c.JSON(200, user)
	})

	r.POST("/users", func(c *gin.Context) {
		var requestBody struct {
			User
			Password string `json:"password"`
		}

		err := c.BindJSON(&requestBody)
		if err != nil {
			c.AbortWithError(400, err)
			return
		}

		if len(requestBody.Password) < 6 {
			c.AbortWithError(400, ErrorClient).SetMeta(gin.H{"password": "too short, minimum length 6"})
			return
		}

		requestBody.User.Password, err = bcrypt.GenerateFromPassword([]byte(requestBody.Password), 5)
		if err != nil {
			c.AbortWithError(500, err).SetType(gin.ErrorTypePrivate)
			return
		}

		tx := db.Begin()

		err = tx.Create(&requestBody.User).Error
		if err != nil {
			tx.Rollback()
			if strings.Contains(err.Error(), "duplicate key value violates unique constraint \"users_username_key\"") {
				c.AbortWithError(400, ErrorClient).SetMeta(gin.H{"username": "already exists"})
				return
			}
			c.AbortWithError(500, err).SetType(gin.ErrorTypePrivate)
			return
		}

		tx.Commit()

		c.JSON(http.StatusCreated, requestBody.User)
	})
}
