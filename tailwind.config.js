/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        "sidebar-bg": "#032A28",
        "emerald-primary": "#10b981",
        "emerald-dark": "#047857",
        "background-light": "#f8fafc",
        "background-dark": "#0a0a0a",
      },
      fontFamily: {
        "sans": ["Inter", "sans-serif"]
      },
    },
  },
  plugins: [],
}
