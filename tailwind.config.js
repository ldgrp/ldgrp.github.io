const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: {
    enabled: true,
    content: [
    './posts/**/*.html',
    './templates/**/*.html',
    '*.html',
    './posts/**/*.md',
    './templates/**/*.md',
    '*.md',
    ],
  },
  theme: {
    extend: {
      fontFamily: {
        sans: [
          'Inter',
          defaultTheme.fontFamily.sans,
        ],
        serif: [
          'Roboto Slab',
          defaultTheme.fontFamily.serif
        ],
      },
    },
  },
  variants: {},
  plugins: [],
}
