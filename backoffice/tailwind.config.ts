import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    './lib/**/*.{ts,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        border: 'hsl(215 16% 84%)',
        input: 'hsl(215 16% 84%)',
        ring: 'hsl(197 89% 27%)',
        background: 'hsl(36 33% 96%)',
        foreground: 'hsl(215 27% 16%)',
        primary: {
          DEFAULT: 'hsl(197 89% 27%)',
          foreground: 'hsl(0 0% 100%)'
        },
        secondary: {
          DEFAULT: 'hsl(43 73% 92%)',
          foreground: 'hsl(215 27% 16%)'
        },
        muted: {
          DEFAULT: 'hsl(39 31% 92%)',
          foreground: 'hsl(215 12% 40%)'
        },
        card: {
          DEFAULT: 'hsl(0 0% 100%)',
          foreground: 'hsl(215 27% 16%)'
        },
        accent: {
          DEFAULT: 'hsl(14 84% 89%)',
          foreground: 'hsl(215 27% 16%)'
        },
        destructive: {
          DEFAULT: 'hsl(0 72% 51%)',
          foreground: 'hsl(0 0% 100%)'
        }
      },
      borderRadius: {
        lg: '1rem',
        md: '0.75rem',
        sm: '0.5rem'
      },
      fontFamily: {
        sans: ['"Noto Sans Thai"', '"Helvetica Neue"', 'system-ui', 'sans-serif']
      }
    }
  },
  plugins: []
};

export default config;
