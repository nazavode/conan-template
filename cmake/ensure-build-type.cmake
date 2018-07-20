# * Ensures that a CMAKE_BUILD_TYPE is set
#
# ensure_build_type(<var> [<fallbacksetvar>])
#
# If a CMAKE_BUILD_TYPE hasn't been set, sets it to the provided value. If the optional
# <fallbacksetvar> argument is provided, sets the contained variable to TRUE if the
# fallback value has been used.
#
# Copyright 2018 Federico Ficarelli
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# cmake-format: on

if(__ensure_build_type_defined)
  return()
endif()
set(__ensure_build_type_defined ON)

function(ensure_build_type _fallback_build_type)
  if(NOT DEFINED __FALLBACK_BUILD_TYPE_SET)
    set(__FALLBACK_BUILD_TYPE_SET OFF CACHE INTERNAL "")
  endif()
  # cmake-format: off
  if(NOT __FALLBACK_BUILD_TYPE_SET AND
     NOT CMAKE_BUILD_TYPE AND
     NOT CMAKE_CONFIGURATION_TYPES)
# cmake-format: on
    set(CMAKE_BUILD_TYPE "${_fallback_build_type}"
        CACHE STRING "Build type set from default"
        FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE
                 PROPERTY STRINGS
                          "Debug"
                          "Release"
                          "MinSizeRel"
                          "RelWithDebInfo")
    set(__FALLBACK_BUILD_TYPE_SET ON
        CACHE INTERNAL "CMAKE_BUILD_TYPE set from fallback value")
  endif()
  # Make sure to inform the caller whether the fallback value has been set or not
  if(ARGV1)
    set(${ARGV1} ${__FALLBACK_BUILD_TYPE_SET} PARENT_SCOPE)
  endif()
endfunction(ensure_build_type)
