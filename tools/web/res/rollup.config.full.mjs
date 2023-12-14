import { nodeResolve } from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import terser from '@rollup/plugin-terser'
import JsUtils from '../../JsUtils.mjs'
import pkg from '../../../bin/web/build/dist/npm/package.json' assert { type: 'json' };
import classes from '../../../src/wrapper/web/full/wrapper.export.json' assert { type: 'json' };

const dist = 'bin/web/build/dist/npm'

export default [
  {
    input: 'bin/web/build/full/obj/ls_web_client_wrapper.js',
    output: [
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", pkg.version, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer.min.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", pkg.version, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports'),
        sourcemap: true,
        plugins: [
          terser()
        ]
      },
      { 
        file: `${dist}/lightstreamer.esm.js`, 
        format: 'es',
        banner: JsUtils.generateCopyright("Web", pkg.version, "ESM", classes) 
      },
      { 
        file: `${dist}/lightstreamer.common.js`, 
        format: 'cjs',
        banner: JsUtils.generateCopyright("Web", pkg.version, "CJS", classes)
      }
    ],
    plugins: [
      nodeResolve(),
      commonjs({transformMixedEsModules: true}),
    ]
  }
];
