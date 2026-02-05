import { defineConfig } from '@hey-api/openapi-ts';

export default defineConfig({
  input: '../client/generated/openapi.json',
  output: 'src/generated/client',
  client: 'fetch',
  schemas: false,
  services: {
    asClass: true,
  },
});
