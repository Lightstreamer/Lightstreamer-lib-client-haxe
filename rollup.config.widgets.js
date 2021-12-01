import virtual from '@rollup/plugin-virtual'
import JsUtils from './tools/JsUtils'
import pkg from './bin/web/package.json'

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)
const classes = ["Chart", "DynaGrid", "SimpleChartListener", "StaticGrid", "StatusWidget"]

export default [
  {
    input: 'virtual-entrypoint',
    output: [
      {
        name: 'lightstreamerExports',
        file: 'bin/web/lightstreamer-widgets.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        file: 'bin/web/lightstreamer-widgets.esm.js',
        format: 'es',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "ESM", classes)
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