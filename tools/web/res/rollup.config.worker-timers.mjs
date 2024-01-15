import { nodeResolve } from '@rollup/plugin-node-resolve'
import typescript from '@rollup/plugin-typescript';

export default commandLineArgs => {
  const input = commandLineArgs.configInput;
  const outputDir = commandLineArgs.configOutputDir;

  return {
    input: input,
    output: {
      dir: outputDir,
      format: 'es'
    },
    plugins: [
      nodeResolve(),
      typescript()
    ]
  };
};
