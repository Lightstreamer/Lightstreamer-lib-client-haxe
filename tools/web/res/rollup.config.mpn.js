import { nodeResolve } from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import { terser } from 'rollup-plugin-terser'
import JsUtils from '../../JsUtils'
import pkg from '../../../bin/web/build/dist/npm/package.json'
import classes from '../../../src/wrapper/web/mpn/wrapper.export.json';

const dist = 'bin/web/build/dist/npm'
const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)

export default [
  {
    input: 'bin/web/build/mpn/obj/ls_web_client_wrapper.js',
    output: [ 
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer-mpn.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer-mpn.min.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports'),
        sourcemap: true,
        plugins: [
          terser()
        ]
      },
      {
        file: `${dist}/lightstreamer-mpn.esm.js`,
        format: 'es',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "ESM", classes)
      },
      {
        file: `${dist}/lightstreamer-mpn.common.js`,
        format: 'cjs',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "CJS", classes)
      }
    ],
    plugins: [
      nodeResolve(),
      commonjs({transformMixedEsModules: true})
    ]
  }
];