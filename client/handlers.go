package main

import (
	"fmt"
	"log"
	"net/http"
)

// HandleHealth serves the health check endpoint
func HandleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_, err := fmt.Fprintf(w, `{"status": "healthy"}`)
	if err != nil {
		log.Printf("Error writing response: %v", err)
	}
}

// HandleUpload handles file upload and returns hardcoded transcription
func HandleUpload(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	// TODO: Process the uploaded file and call backend API
	// For now, return hardcoded response
	w.Header().Set("Content-Type", "application/json")
	_, err := fmt.Fprintf(w, `{"transcript": "Hello, how are you?"}`)
	if err != nil {
		log.Printf("Error writing response: %v", err)
	}
}
