import JsUtils from './tools/JsUtils'

const classes = ["LightstreamerClient", "Subscription"]

export default [
  {
    input: 'bin/web/lightstreamer_orig.js',
    output: [ 
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer-core.js',
        format: 'iife',
        banner: JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        file: 'bin/web/lightstreamer-core.esm.js',
        format: 'es'
      },
      {
        file: 'bin/web/lightstreamer-core.common.js',
        format: 'cjs'
      }
    ]
  }
];