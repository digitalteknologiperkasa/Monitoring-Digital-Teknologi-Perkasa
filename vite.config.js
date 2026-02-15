import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  base: '/Monitoring-Digital-Teknologi-Perkasa/',
  plugins: [vue()],
  build: {
    outDir: 'docs',
  },
})
