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

NB Before uploading the package, change the version number in the file 'pyproject.toml'.
If the upload is to Test PyPi, use as the version number a string such as '1.0.0.dev<year><month><day>'.
");
}