# Conan template project

This is an attempt at understanding how to make [Conan](https://conan.io/)
and CMake work toghether *smoothly*.

1. [Install Conan](https://docs.conan.io/en/latest/installation.html).
2. Add the [bincrafters](https://bintray.com/bincrafters/public-conan) repository to
   [Conan remotes](https://docs.conan.io/en/latest/uploading_packages/remotes.html):
   ```console
   $ conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan
   ```
   Please note that this step is needed only if you have specified dependencies
   in `conanfile.py` that are available on remotes other than
   [conan-center](https://bintray.com/conan/conan-center).
3. Build as usual via `cmake`:
   ```console
   $ cd conan-template
   $ mkdir build && cd build
   $ cmake ..
   ```

Please note that building via `cmake` is considered *user* mode while this
`CMakeLists.txt` supports *developer* mode as well following the
[official approach](https://github.com/conan-io/cmake-conan#creating-packages):
```console
$ cd conan-template
$ mkdir build && cd build
$ conan install ..  # you can customize options and settings here
$ conan build ..
```
