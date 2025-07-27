module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        'gray': {
          25: '#FAFAFA',
          50: '#F7F7F7',
          100: '#F0F0F0',
          200: '#E7E7E7',
          300: '#CFCFCF',
          400: '#9E9E9E',
          500: '#737373',
          600: '#5C5C5C',
          700: '#363636',
          800: '#242424',
          900: '#171717',
        },
        'blue': {
          25: '#F5FAFF',
          50: '#EFF8FF',
          100: '#D1E9FF',
          200: '#B2DDFF',
          300: '#84CAFF',
          400: '#53B1FD',
          500: '#2E90FA',
          600: '#1570EF',
          700: '#175CD3',
          800: '#1849A9',
          900: '#194185',
        }
      }
    },
  },
  plugins: []
}
