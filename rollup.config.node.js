import JsUtils from './tools/JsUtils'
import { terser } from 'rollup-plugin-terser'
import pkg from './bin/node/package.json'
import classes from './tools/coreClasses.json';

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)

export default [
  {
    input: 'bin/node/lightstreamer-node_orig.js',
    output: [ 
      {
        file: 'bin/node/lightstreamer-node.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Node.js", versionNum, buildNum, "CJS", classes)
      },
      {
        file: 'bin/node/lightstreamer-node.min.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Node.js", versionNum, buildNum, "CJS", classes),
        sourcemap: true,
        plugins: [
          terser()
        ]
      }
    ]
  }
];