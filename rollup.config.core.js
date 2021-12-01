import JsUtils from './tools/JsUtils'
import pkg from './bin/web/package.json'

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)
const classes = ["LightstreamerClient", "Subscription"]

export default [
  {
    input: 'bin/web/lightstreamer_orig.js',
    output: [ 
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer-core.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        file: 'bin/web/lightstreamer-core.esm.js',
        format: 'es',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "ESM", classes)
      },
      {
        file: 'bin/web/lightstreamer-core.common.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "CJS", classes)
      }
    ]
  }
];