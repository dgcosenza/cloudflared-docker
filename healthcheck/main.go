package main

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

func main() {
	url := os.Getenv("CLOUDFLARED_HEALTHCHECK_URL")
	if url == "" {
		url = "http://127.0.0.1:2000/ready"
	}
	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "healthcheck request failed: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		fmt.Fprintf(os.Stderr, "healthcheck unexpected status: %d\n", resp.StatusCode)
		os.Exit(1)
	}
}
