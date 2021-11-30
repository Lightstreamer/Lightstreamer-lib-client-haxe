import UmdUtils from './tools/UmdUtils'

const classes = ["LightstreamerClient", "Subscription"]

export default [
  {
    input: 'bin/web/lightstreamer_orig.js',
    output: [ 
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer-core.js',
        format: 'iife',
        banner: UmdUtils.generateUmdHeader(classes),
        footer: UmdUtils.generateUmdFooter('lightstreamerExports')
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