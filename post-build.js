import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

try {
  const src = path.resolve(__dirname, 'docs/index.html');
  const dest = path.resolve(__dirname, 'docs/404.html');
  
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, dest);
    console.log('✅ Copied docs/index.html to docs/404.html for GitHub Pages SPA routing.');
  } else {
    console.error('❌ docs/index.html not found. Make sure vite build ran successfully.');
    process.exit(1);
  }
} catch (err) {
  console.error('❌ Failed to copy docs/index.html to docs/404.html:', err);
  process.exit(1);
}
