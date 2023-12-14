import resolve from '@rollup/plugin-node-resolve';

export default {
    input: 'dist/main.js',
    output: {
        file: 'dist/bundle.js',
        format: 'iife'
    },
    plugins: [ resolve() ]
};