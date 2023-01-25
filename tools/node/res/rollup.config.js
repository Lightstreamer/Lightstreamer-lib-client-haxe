import { terser } from 'rollup-plugin-terser'
import JsUtils from '../../JsUtils'
import pkg from '../../../bin/node/build/dist/npm/package.json'
import classes from '../../../src/wrapper/node/wrapper.export.json';

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)

export default [
  {
    input: 'bin/node/build/obj/ls_node_client_wrapper.js',
    output: [ 
      {
        file: 'bin/node/build/dist/npm/lightstreamer-node.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Node.js", versionNum, buildNum, "CJS", classes)
      },
      {
        file: 'bin/node/build/dist/npm/lightstreamer-node.min.js',
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