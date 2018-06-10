cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(myconanprj CXX)

# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(default_build_type "Release")
    message(STATUS "Setting build type to '${default_build_type}' as none was specified.")
    set(CMAKE_BUILD_TYPE "${default_build_type}" CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# 1. Ensure conan-cmake submodule is available
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/cmake-conan/conan.cmake")
    message(STATUS "Retrieving cmake-conan from git submodule...")
    find_package(Git REQUIRED)
    execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init -- external/cmake-conan
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
endif()

# 2. Setup conan
include(${CMAKE_SOURCE_DIR}/external/cmake-conan/conan.cmake)

# 3. Perform 'conan install' using existing conanfile.txt
conan_cmake_run(CONANFILE conanfile.txt
                BASIC_SETUP CMAKE_TARGETS
                BUILD missing)