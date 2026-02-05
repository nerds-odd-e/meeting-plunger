<template>
  <div class="upload-form">
    <h2>Upload Audio File</h2>
    <form id="uploadForm" @submit.prevent="handleSubmit">
      <input
        id="audioFile"
        ref="fileInput"
        type="file"
        accept="audio/*"
        required
      />
      <br /><br />
      <button type="submit">Upload</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const emit = defineEmits<{
  transcript: [text: string];
}>();

const fileInput = ref<HTMLInputElement | null>(null);

const handleSubmit = async () => {
  if (!fileInput.value?.files?.length) {
    alert('Please select a file');
    return;
  }

  const formData = new FormData();
  formData.append('file', fileInput.value.files[0]);

  try {
    const response = await fetch('/upload', {
      method: 'POST',
      body: formData,
    });

    const data = await response.json();
    emit('transcript', data.transcript);
  } catch (error) {
    const errorMessage =
      error instanceof Error ? error.message : 'Unknown error';
    emit('transcript', 'Error: ' + errorMessage);
  }
};
</script>

<style scoped>
.upload-form {
  margin: 20px 0;
  padding: 20px;
  border: 1px solid #ccc;
  border-radius: 8px;
}

button {
  background-color: #0066cc;
  color: white;
  padding: 10px 20px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
}

button:hover {
  background-color: #0052a3;
}
</style>
