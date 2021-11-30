import virtual from '@rollup/plugin-virtual'
import UmdUtils from './tools/UmdUtils'

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
        banner: UmdUtils.generateUmdHeader(classes),
        footer: UmdUtils.generateUmdFooter('lightstreamerExports')
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