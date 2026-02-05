package main

import (
	"fmt"
	"log"
	"net/http"
)

// HealthResponse represents the health check response
type HealthResponse struct {
	Status string `json:"status" example:"healthy"`
}

// TranscriptResponse represents the transcript response
type TranscriptResponse struct {
	Transcript string `json:"transcript" example:"Hello, how are you?"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Error string `json:"error" example:"Method not allowed"`
}

// HandleHealth serves the health check endpoint
// @Summary Health check
// @Description Returns the health status of the client service
// @Tags health
// @Produce json
// @Success 200 {object} HealthResponse
// @Router /health [get]
func HandleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_, err := fmt.Fprintf(w, `{"status": "healthy"}`)
	if err != nil {
		log.Printf("Error writing response: %v", err)
	}
}

// HandleTranscribe handles file upload and returns hardcoded transcription
// @Summary Transcribe audio file
// @Description Accepts an audio file and returns its transcription
// @Tags transcription
// @Accept multipart/form-data
// @Produce json
// @Param file formData file true "Audio file to transcribe"
// @Success 200 {object} TranscriptResponse
// @Failure 405 {object} ErrorResponse
// @Router /transcribe [post]
func HandleTranscribe(w http.ResponseWriter, r *http.Request) {
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
