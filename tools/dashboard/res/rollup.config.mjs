import { nodeResolve } from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import terser from '@rollup/plugin-terser'
import JsUtils from '../../JsUtils.mjs'
import pkg from '../../../bin/dashboard/build/dist/package.json' assert { type: 'json' };
import classes from '../../../src/wrapper/web/full/wrapper.export.json' assert { type: 'json' };

const dist = 'bin/dashboard/build/dist'

export default [
  {
    input: 'bin/dashboard/build/obj/ls_web_client_wrapper.js',
    output: [
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer_dashboard.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", pkg.version, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports')
      },
      {
        name: 'lightstreamerExports',
        file: `${dist}/lightstreamer_dashboard.min.js`,
        format: 'iife',
        banner: JsUtils.generateCopyright("Web", pkg.version, "UMD", classes) + "\n" + JsUtils.generateUmdHeader(classes),
        footer: JsUtils.generateUmdFooter('lightstreamerExports'),
        sourcemap: true,
        plugins: [
          terser()
        ]
      }
    ],
    plugins: [
      nodeResolve(),
      commonjs({transformMixedEsModules: true}),
    ]
  }
];
