package main

import (
	"fmt"
	"net/http"
	"time"

	jwt "github.com/dgrijalva/jwt-go"
	"github.com/jinzhu/gorm"
	uuid "github.com/satori/go.uuid"
	"golang.org/x/crypto/bcrypt"
	"gopkg.in/gin-gonic/gin.v1"
)

type Auth struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func SetupAuth(r *gin.Engine, db *gorm.DB) {

	r.POST("/auth", func(c *gin.Context) {
		var auth Auth
		err := c.BindJSON(&auth)
		if err != nil {
			c.AbortWithError(400, err)
			return
		}

		var user User
		db.Model(&user).Select("password").Where("username = ?", auth.Username).First(&user)
		err = bcrypt.CompareHashAndPassword(user.Password, []byte(auth.Password))
		if err != nil {
			c.AbortWithError(http.StatusUnauthorized, ErrorClient).SetMeta("Username or password incorrect")
			return
		}

		mySigningKey := []byte("AllYourBase")

		claims := &jwt.StandardClaims{
			Id:        user.ID.String(),
			Issuer:    "RegionsAPI",
			IssuedAt:  time.Now().Unix(),
			ExpiresAt: time.Now().Add(time.Minute * 30).Unix(),
		}
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
		ss, err := token.SignedString(mySigningKey)
		if err != nil {
			c.AbortWithError(500, err)
			return
		}

		c.JSON(200, gin.H{"access_token": ss})
	})
}

func AuthMiddleware(db *gorm.DB) func(*gin.Context) {

	return func(c *gin.Context) {

		header := c.Request.Header.Get("access_token")

		println(header)

		token, err := jwt.Parse(header, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
			}
			return []byte("AllYourBase"), nil
		})

		if err != nil {
			c.AbortWithError(401, err).SetMeta(gin.H{"access_token": "Invalid"}).SetType(gin.ErrorTypePublic)
			return
		}

		if !token.Valid {
			err = token.Claims.Valid()
			c.AbortWithError(401, err).SetMeta(gin.H{"access_token": err.Error()}).SetType(gin.ErrorTypePublic)
			return
		}

		claims := token.Claims.(jwt.MapClaims)
		user := User{ID: uuid.FromStringOrNil(claims["jti"].(string))}

		err = db.First(&user).Error
		if err != nil {
			c.AbortWithError(401, ErrorClient).SetMeta("User not found")
			return
		}

		c.Set("user", user)

		c.Next()
	}
}
