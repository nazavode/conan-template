cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(myproject VERSION 1.0.0 LANGUAGES CXX)

# --- Project Configuration Options ---

option(
  MYPROJECT_ENABLE_STATIC_EXE
  "All executables targets are linked as static. This doesn't affect dependencies linkage"
  ON)

set(MYPROJECT_DEFAULT_BUILD_TYPE "Release"
    CACHE STRING "default build type used when CMAKE_BUILD_TYPE is not specified")

# Always enable generation of compilation database
set(CMAKE_EXPORT_COMPILE_COMMANDS ON
    CACHE BOOL "Generate compile commands database for clang tooling"
    FORCE)

# --- Build Type ---
# Make sure to set CMAKE_BUILD_TYPE when none has been specified by the user.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(
    STATUS
      "Setting build type to '${MYPROJECT_DEFAULT_BUILD_TYPE}' as none was specified.")
  set(CMAKE_BUILD_TYPE "${MYPROJECT_DEFAULT_BUILD_TYPE}"
      CACHE STRING "Default build type"
      FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE
               PROPERTY STRINGS
                        "Debug"
                        "Release"
                        "MinSizeRel"
                        "RelWithDebInfo")
endif()

# --- Inclusions ---
# Stuff shipped with CMake
include(CheckCXXCompilerFlag)
# Extra finders
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/find)
# Extra functions
include(cmake/get-target-sources.cmake)

# --- Find external stuff ---
find_package(ClangFormat)
find_package(ClangTidy)

# --- Conan ---
# Setup dependencies and corresponding targets with Conan.
if(CONAN_EXPORTED)
  # --- Conan Developer Mode ---
  # In conan local cache, 'developer' mode. Standard conan installation, deps will be
  # defined in conanfile.py and not necessary to call conan again, conan is already
  # running.
  include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
  conan_basic_setup(TARGETS)
else()
  # --- Conan User Space Mode ---
  # In user space, 'user' mode. CMake drives the build and invokes conan on its own.
  include(cmake/conan.cmake)
  # Perform 'conan install'. Make sure to use conanfile.py to define dependencies, to stay
  # consistent.
  conan_cmake_run(CONANFILE conanfile.py BASIC_SETUP CMAKE_TARGETS BUILD missing)
endif()

# --- C++ Features ---
# Setup common compile features. Creates target 'myproject::cxxfeatures'
add_library(cxxfeatures INTERFACE)
set_property(TARGET cxxfeatures PROPERTY INTERFACE_CXX_EXTENSIONS OFF)
if(cxx_std_17 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
  set_property(TARGET cxxfeatures PROPERTY INTERFACE_COMPILE_FEATURES cxx_std_17)
else()
  if(MSVC)
    set(_cxx_std_flag /std:c++17)
  else()
    set(_cxx_std_flag -std=c++17)
  endif()
  check_cxx_compiler_flag(${_cxx_std_flag} COMPILER_SUPPORTS_CXX_STD17_FLAG)
  if(COMPILER_SUPPORTS_CXX_STD17_FLAG)
    message(STATUS "CMake compile features not available for the current \
toolchain or CMake version, setting C++ standard level directly via compiler \
flags. Please be aware that setting flags doesn't check the actual C++17 \
standard support provided by the underlying toolchain, e.g.: build may fail \
on unsupported features.")
    set_property(TARGET cxxfeatures PROPERTY INTERFACE_COMPILE_OPTIONS ${_cxx_std_flag})
  else()
    message(WARNING "Compiler seems to be unable to accept '${_cxx_std_flag}',
build will probably fail. Please set CMAKE_CXX_FLAGS to some sensible value for \
your toolchain.")
  endif()
endif()
# Add target alias for the sake of consistency
add_library(myproject::cxxfeatures ALIAS cxxfeatures)

# --- Compiler Warnings ---
# Setup common warnings level. Creates target 'myproject::warnings'
add_library(warnings INTERFACE)
if(MSVC)
  set(_warn_flags /W4 /WX)
else()
  set(_warn_flags -Wall -pedantic -Werror)
endif()
set_property(TARGET warnings PROPERTY INTERFACE_COMPILE_OPTIONS ${_warn_flags})
# Add target alias for the sake of consistency
add_library(myproject::warnings ALIAS warnings)

# --- Executables Linkage ---
# Please note that this section modifies CMAKE_EXE_LINKER_FLAGS globally! We can't
# actually create interface targets for linker flags until this has been released:
# https://gitlab.kitware.com/cmake/cmake/issues/16543
if(MYPROJECT_ENABLE_STATIC_EXE)
  if(MSVC)
    message(WARNING "TODO: MSVC static executables not yet supported, \
keeping default link flags.")
  elseif(APPLE)
    message(WARNING "Static executables on macOSX are not supported, \
keeping default link flags.")
  else()
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
  endif()
endif()

# --- Project Targets ---
add_executable(cli src/main.cpp)
set_target_properties(cli PROPERTIES OUTPUT_NAME "myproject-cli")
target_link_libraries(cli
                      PUBLIC CONAN_PKG::clara myproject::cxxfeatures
                      PRIVATE myproject::warnings)
install(TARGETS cli DESTINATION bin)
# Add target alias for the sake of consistency
add_executable(myproject::cli ALIAS cli)

# --- Tooling ---

get_target_sources(all_sources myproject::cli)

if(CLANG_FORMAT_FOUND)
  message("clang-format found: ${CLANG_FORMAT_EXECUTABLE}")
  add_custom_target(format-fix
                    COMMAND ${CLANG_FORMAT_EXECUTABLE} -style=file -i ${all_sources}
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
else()
  message("clang-format not found")
endif()

if(CLANG_TIDY_FOUND)
  message("clang-tidy found: ${CLANG_TIDY_EXECUTABLE}")
  set(tidy_cmd ${CLANG_TIDY_EXECUTABLE} -p ${CMAKE_BINARY_DIR} -warnings-as-errors=*)
  add_custom_target(tidy
                    COMMAND ${tidy_cmd} ${all_sources}
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
  add_custom_target(tidy-fix
                    COMMAND ${tidy_cmd} -fix ${all_sources}
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
else()
  message("clang-tidy not found")
endif()
