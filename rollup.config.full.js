import virtual from '@rollup/plugin-virtual'
import { terser } from 'rollup-plugin-terser'
import JsUtils from './tools/JsUtils'
import pkg from './bin/web/package.json'

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)
const coreClasses = ["LightstreamerClient", "Subscription"]
const widgetClasses = ["Chart", "DynaGrid", "SimpleChartListener", "StaticGrid", "StatusWidget"]
const classes = coreClasses.concat(widgetClasses)

export default [
  {
    input: 'virtual-entrypoint',
    output: [
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer.min.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports'),
        plugins: [
          terser()
        ]
      },
      { 
        file: 'bin/web/lightstreamer.esm.js', 
        format: 'es',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "ESM", classes) 
      },
      { 
        file: 'bin/web/lightstreamer.common.js', 
        format: 'cjs',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "CJS", classes)
      }
    ],
    plugins: [
      virtual({ 
        'virtual-entrypoint': generateVirtualEntryPoint()
      })
    ]
  }
];

function generateVirtualEntryPoint() {
  return `
export { ${ coreClasses.join(",") } } from "./bin/web/lightstreamer-core.esm.js";
export { ${ widgetClasses.join(",") } } from "./bin/web/lightstreamer-widgets.esm.js";
`
}