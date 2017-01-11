package main

import (
	. "bytes"
	. "encoding/json"
	. "fmt"
	"io/ioutil"
	"os"
	"strconv"
)

func main() {

	bytes, err := ioutil.ReadAll(os.Stdin)

	var json interface{}
	err = Unmarshal(bytes, &json)
	if err != nil {
		Println("error:", err)
		os.Exit(1)
	}

	for _, key := range os.Args[1:] {
		index, err := strconv.Atoi(key)

		// if we cannot convert to an integer then we must have a string key
		if err != nil {
			blob, found := json.(map[string]interface{})
			if !found {
				panic("json at " + key + " is not a object")
			}
			json = blob[key]
		} else {
			blob, found := json.([]interface{})
			if !found {
				panic("json at " + key + " is not an array")
			}
			json = blob[index]
		}
	}

	if json == nil {
		println("nil")
		os.Exit(0)
	}

	output, err := Marshal(json)
	if err != nil {
		panic("error: " + err.Error())
	}
	println(string(Trim(output, `"`)))
}
