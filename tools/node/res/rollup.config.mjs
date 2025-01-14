import terser from '@rollup/plugin-terser'
import JsUtils from '../../JsUtils.mjs'
import pkg from '../../../bin/node/build/dist/npm/package.json' with { type: 'json' };
import classes from '../../../src/wrapper/node/wrapper.export.json' with { type: 'json' };

export default [
  {
    input: 'bin/node/build/obj/ls_node_client_wrapper.js',
    output: [ 
      {
        file: 'bin/node/build/dist/npm/lightstreamer-node.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Node.js", pkg.version, "CJS", classes)
      },
      {
        file: 'bin/node/build/dist/npm/lightstreamer-node.min.js',
        format: 'cjs',
        banner: JsUtils.generateCopyright("Node.js", pkg.version, "CJS", classes),
        sourcemap: true,
        plugins: [
          terser()
        ]
      }
    ]
  }
];