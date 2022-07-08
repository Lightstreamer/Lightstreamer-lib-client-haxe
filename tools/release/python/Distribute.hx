import Sys.println;

function main() {
  // NB the current directory must be the root of the project
  println("
To upload the package on Test PyPi, run the following commands (from the folder 'dist/python/lightstreamer-client'):
$ python3 -m build
$ twine upload -r testpypi dist/*

To upload the package on PyPi, run the following commands (from the folder 'dist/python/lightstreamer-client'):
$ python3 -m build
$ twine upload dist/*

To install 'build' and 'twine', run this command:
$ python3 -m pip install build twine
");
}