import { nodeResolve } from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'

export default {
  input: 'bin-test/web/lightstreamer_orig.js',
  output: {
    file: 'bin-test/web/lightstreamer.js',
    format: 'iife'
  },
  plugins: [
    nodeResolve(),
    commonjs({transformMixedEsModules: true})
  ]
}