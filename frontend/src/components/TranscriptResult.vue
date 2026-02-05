<template>
  <div id="result" class="result">
    {{ transcript }}
  </div>
</template>

<script setup lang="ts">
defineProps<{
  transcript: string;
}>();
</script>

<style scoped>
.result {
  margin-top: 20px;
  padding: 15px;
  background-color: #f5f5f5;
  border-radius: 4px;
}

@media (prefers-color-scheme: dark) {
  .result {
    background-color: #333;
  }
}
</style>
