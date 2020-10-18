const fs = require('fs')
const postcss = require('postcss')
const tailwind = require('tailwindcss')
const CleanCSS = require('clean-css')

function buildDistFile() {
  return new Promise((resolve, reject) => {
    return postcss([
      tailwind({
        plugins: [require('./index.js')],
      }),
      require('autoprefixer'),
    ])
      .process(
        `
@tailwind base;
@tailwind components;
@tailwind utilities;
      `,
        {
          from: undefined,
          to: `./dist/tailwind-ui.css`,
          map: { inline: false },
        }
      )
      .then(result => {
        fs.writeFileSync(`./dist/tailwind-ui.css`, result.css)
        return result
      })
      .then(result => {
        const minified = new CleanCSS().minify(result.css)
        fs.writeFileSync(`./dist/tailwind-ui.min.css`, minified.styles)
      })
      .then(resolve)
      .catch(error => {
        console.log(error)
        reject()
      })
  })
}

console.info('Compiling CDN build...')

Promise.all([buildDistFile()]).then(() => {
  console.log('Finished.')
})
