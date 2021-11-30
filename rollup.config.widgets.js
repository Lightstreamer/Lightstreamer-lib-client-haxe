import virtual from '@rollup/plugin-virtual'

const classes = ["Chart", "DynaGrid", "SimpleChartListener", "StaticGrid", "StatusWidget"]
const virtualEntryPoint = generateVirtualEntryPoint()

export default [
  {
    input: 'virtual-entrypoint',
    output: {
      file: 'bin/web/lightstreamer-widgets.esm.js',
      format: 'es'
    },
    plugins: [
      virtual({ 
        'virtual-entrypoint': virtualEntryPoint
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