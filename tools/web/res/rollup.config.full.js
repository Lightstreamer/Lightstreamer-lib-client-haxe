import { nodeResolve } from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import { terser } from 'rollup-plugin-terser'
import JsUtils from '../../JsUtils'
import pkg from '../../../bin/web/build/dist/package.json'
import classes from './classes.full.json'

const [versionNum, buildNum] = JsUtils.parseSemVer(pkg.version)

export default [
  {
    input: 'bin/web/build/full/obj/ls_web_client_wrapper.js',
    output: [
      {
        name: 'lightstreamerExports',
        file: 'bin/web/build/dist/lightstreamer.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        name: 'lightstreamerExports',
        file: 'bin/web/build/dist/lightstreamer.min.js',
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports'),
        sourcemap: true,
        plugins: [
          terser()
        ]
      },
      { 
        file: 'bin/web/build/dist/lightstreamer.esm.js', 
        format: 'es',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "ESM", classes) 
      },
      { 
        file: 'bin/web/build/dist/lightstreamer.common.js', 
        format: 'cjs',
        banner: JsUtils.generateCopyright("Web", versionNum, buildNum, "CJS", classes)
      }
    ],
    plugins: [
      nodeResolve(),
      commonjs({transformMixedEsModules: true}),
    ]
  }
];
