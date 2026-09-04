/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Government Official Colors
        'gov-blue': {
          DEFAULT: '#1e3a5f',
          light: '#2d5a7f',
          dark: '#0f2744'
        },
        'gov-gold': {
          DEFAULT: '#d4a574',
          light: '#e8c49a',
          dark: '#b8945e'
        },
        'gov-green': {
          DEFAULT: '#2d5a3d',
          light: '#3d7a4d',
          dark: '#1d4a2d'
        },
        // Risk Level Colors
        safe: {
          light: '#4ADE80',
          DEFAULT: '#22C55E',
          dark: '#15803D'
        },
        watch: {
          light: '#FDE047',
          DEFAULT: '#EAB308',
          dark: '#A16207'
        },
        warning: {
          light: '#FB923C',
          DEFAULT: '#F97316',
          dark: '#C2410C'
        },
        evacuate: {
          light: '#F87171',
          DEFAULT: '#EF4444',
          dark: '#B91C1C'
        }
      }
    },
  },
  plugins: [],
}
