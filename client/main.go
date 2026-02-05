package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// Parse command line arguments
	if len(os.Args) > 1 && os.Args[1] == "serve" {
		startHTTPServer()
		return
	}

	// CLI mode
	fmt.Println("Meeting Plunger CLI")
	fmt.Println("Usage:")
	fmt.Println("  client serve    Start local HTTP server for browser")
}

func startHTTPServer() {
	http.HandleFunc("/health", HandleHealth)
	http.HandleFunc("/upload", HandleUpload)

	port := ":3001"
	fmt.Printf("Starting client API server on http://localhost%s\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
