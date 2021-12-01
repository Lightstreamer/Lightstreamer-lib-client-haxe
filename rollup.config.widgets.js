import virtual from '@rollup/plugin-virtual'
import JsUtils from './tools/JsUtils'

const classes = ["Chart", "DynaGrid", "SimpleChartListener", "StaticGrid", "StatusWidget"]

export default [
  {
    input: 'virtual-entrypoint',
    output: [
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer-widgets.js',
        format: 'iife',
        banner: JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        file: 'bin/web/lightstreamer-widgets.esm.js',
        format: 'es'
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
${ classes.map((c) => `import ${c} from "./src-widget/${c}";`).join("\n") }
export { ${ classes.join(",") } };
`
}