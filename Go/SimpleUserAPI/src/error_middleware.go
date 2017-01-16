package main

import (
	"errors"
	"log"

	"gopkg.in/gin-gonic/gin.v1"
)

var (
	ErrorClient *gin.Error = &gin.Error{
		Err:  errors.New("clientError"),
		Type: gin.ErrorTypePublic,
	}
)

// ErrorHandler ..
func ErrorHandler(c *gin.Context) {
	c.Next()

	var errorsJSON []interface{}
	for _, err := range c.Errors {
		if err.IsType(gin.ErrorTypePrivate) && err != ErrorClient {
			log.Println(err.Error())
			break
		}

		if err.Meta != nil {
			errorsJSON = append(errorsJSON, err.Meta)
		} else {
			errorsJSON = append(errorsJSON, err.Error())
		}
	}

	if len(errorsJSON) > 0 {
		c.JSON(-1, gin.H{
			"errors": errorsJSON,
		})
	}
}
