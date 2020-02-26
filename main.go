package main

import (
	"bytes"
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
)

var url = os.Getenv("WEBHOOK_URL")

func getMessage() string {
	text := "It is *Wednesday*, my dudes!"
	img := os.Getenv("IMG_URL")

	return fmt.Sprintf(`{"blocks": [{"type": "section","text": {"type": "mrkdwn","text": "%s"},"accessory": {"type": "image","image_url": "%s","alt_text": "frog"}}]}`, text, img)
}

func HandleRequest(ctx context.Context) {
	msg := getMessage()
	jsonStr := []byte(msg)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonStr))

	if err != nil {
		panic(err)
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)

	if err != nil {
		panic(err)
	}

	defer resp.Body.Close()

	data, err := ioutil.ReadAll(resp.Body)

	if err != nil {
		panic(err)
	}

	log.Printf("sending %s to %s, got ", msg, url, resp.StatusCode, string(data))

}

func main() {
	lambda.Start(HandleRequest)
}