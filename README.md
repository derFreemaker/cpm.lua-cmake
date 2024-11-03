# NOT FEATURE COMPLETE
This Plugin is developed as needed there for not every cpm feature is supported.

# cpm.lua-cmake
[lua-cmake](https://github.com/derFreemaker/lua-cmake) plugin for cpm

## Usage
Only file you need from here is `cpm.lua`.

If you don't put CPM.cmake in the same folder as cpm.lua then you also need to get the CPM.cmake to load it with `cmake.cpm.load(<path>)` (does not check if it is the right file, uses `cmake.include(...)`).
