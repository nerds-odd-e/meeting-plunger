Feature: Single Speaker
  As a recorder, with one speaker in the meeting, I want to turn the audio into transcript.

  @useMockedOpenAIServiceInBackend
  Scenario: Small single speaker audio file transcription
    Given OpenAI transcription API replys the following when the model is "gpt-4o-transcribe-diarize":
    """
    {
      "text": "Please be very quiet.",
    }
    """
    When I convert the audio file "small-single-speaker.wav" into transcript
    Then the transcript should be "Please be very quiet."
