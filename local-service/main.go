package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

// @title Meeting Plunger Client API
// @version 1.0
// @description Client API server for Meeting Plunger - bridges frontend and backend
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url https://github.com/terryyin/meeting-plunger
// @contact.email support@example.com

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:3001
// @BasePath /
// @schemes http

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
	http.HandleFunc("/transcribe", HandleTranscribe)

	port := ":3001"
	fmt.Printf("Starting client API server on http://localhost%s\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
