import virtual from '@rollup/plugin-virtual'
import JsUtils from '../../JsUtils.mjs'
import pkg from '../../../bin/web/build/dist/npm/package.json' assert { type: 'json' };

const classes = ["Chart", "DynaGrid", "SimpleChartListener", "StaticGrid", "StatusWidget", "ChartListener", "DynaGridListener", "StaticGridListener"]

export default [
  {
    input: 'virtual-entrypoint',
    output: [
      {
        name: 'lightstreamerExports',
        file: 'bin/web/build/full/obj/lightstreamer-widgets.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", pkg.version, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        file: 'bin/web/build/full/obj/lightstreamer-widgets.esm.js',
        format: 'es',
        banner: JsUtils.generateCopyright("Web", pkg.version, "ESM", classes)
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