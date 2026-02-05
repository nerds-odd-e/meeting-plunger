<template>
  <div>
    <h1>Meeting Plunger</h1>
    <p>Convert audio recordings to transcript</p>

    <UploadForm @transcript="handleTranscript" />

    <TranscriptResult v-if="transcript" :transcript="transcript" />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import UploadForm from './components/UploadForm.vue';
import TranscriptResult from './components/TranscriptResult.vue';

const transcript = ref<string>('');

const handleTranscript = (text: string) => {
  transcript.value = text;
};
</script>
