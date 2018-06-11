cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(myproject CXX)

option(MYPROJECT_ENABLE_STATIC_EXE "All executables targets are linked as static. This doesn't affect dependencies linkage" ON)
set(MYPROJECT_DEFAULT_BUILD_TYPE "Release" CACHE STRING "default build type used when CMAKE_BUILD_TYPE is not specified")

###
### Set a default build type if none was specified
###
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Setting build type to '${MYPROJECT_DEFAULT_BUILD_TYPE}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${MYPROJECT_DEFAULT_BUILD_TYPE}" CACHE STRING "Default build type" FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

###
### Setup conan
###
if(CONAN_EXPORTED) # in conan local cache, 'developer' mode
    # standard conan installation, deps will be defined in conanfile.py
    # and not necessary to call conan again, conan is already running
    include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    conan_basic_setup(TARGETS)
else() # in user space, 'user' mode
    # 1. Ensure conan.cmake helper is available
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
        message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
        file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/v0.11/conan.cmake"
                      "${CMAKE_BINARY_DIR}/conan.cmake")
    endif()
    # 2. Setup conan
    include(${CMAKE_BINARY_DIR}/conan.cmake)
    # 3. Perform 'conan install'
    # Make sure to use conanfile.py to define dependencies, to stay consistent
    conan_cmake_run(CONANFILE conanfile.py
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)
endif()

###
### Setup common compile features
### Creates target 'myproject::cxxfeatures'
###
add_library(cxxfeatures INTERFACE)
if(cxx_std_17 IN_LIST CMAKE_CXX_COMPILE_FEATURES)
    set_property(TARGET cxxfeatures PROPERTY INTERFACE_COMPILE_FEATURES cxx_std_17)
else()
    if(MSVC)
        set(_cxx_flags  /std:c++17)
    else()
        set(_cxx_flags -std=c++17)
    endif()
    set_property(TARGET cxxfeatures PROPERTY INTERFACE_COMPILE_OPTIONS ${_cxx_flags})
    message(WARNING "Compile features not available for the current toolchain or CMake version, \
setting C++ standard level directly via compiler flags. Please be aware that setting flags doesn't \
check actual support by the underlying toolchain, e.g.: build may fail if the flags are unsupported.")
endif()
# Add target alias for the sake of consistency
add_library(myproject::cxxfeatures ALIAS cxxfeatures)

###
### Setup common warnings level
### Creates target 'myproject::warnings'
###
add_library(warnings INTERFACE)
if(MSVC)
    set(_warn_flags /W4 /WX)
else()
    set(_warn_flags -Wall -pedantic -Werror)
endif()
set_property(TARGET warnings PROPERTY INTERFACE_COMPILE_OPTIONS ${_warn_flags})
# Add target alias for the sake of consistency
add_library(myproject::warnings ALIAS warnings)

### Setup executables linkage
### Please note that this section sets CMAKE_EXE_LINKER_FLAGS
### globally!
### We can't actually create interface targets for
### linker flags until this has been released:
### https://gitlab.kitware.com/cmake/cmake/issues/16543
###
if(MYPROJECT_ENABLE_STATIC_EXE)
    if(MSVC)
        message(WARNING "TODO: MSVC static executables not yet supported.")
    elseif(APPLE)
        message(WARNING "Static executables on macOSX are not supported, falling back to dynamic executables.")
    else()
        set(CMAKE_EXE_LINKER_FLAGS "-static")
    endif()
endif()

###
### Add project targets
###
add_executable(cli src/main.cpp)
set_target_properties(cli PROPERTIES OUTPUT_NAME "myproject-cli")
target_link_libraries(cli
    PUBLIC
        CONAN_PKG::clara
    PRIVATE
        myproject::warnings
        myproject::cxxfeatures)
install(TARGETS cli DESTINATION bin)
# Add target alias for the sake of consistency
add_executable(myproject::cli ALIAS cli)
