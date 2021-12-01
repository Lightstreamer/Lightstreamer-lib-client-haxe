import virtual from '@rollup/plugin-virtual'
import JsUtils from './tools/JsUtils'

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
        banner: JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      { 
        file: 'bin/web/lightstreamer.esm.js', 
        format: 'es' 
      },
      { 
        file: 'bin/web/lightstreamer.common.js', 
        format: 'cjs' 
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