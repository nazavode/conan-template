# * returns all the source files (including headers) associated to the given targets.
#
# get_target_sources(<sourcesvar> <target> [<target>...])
#
# Collects all the source files associated to the given targets and sets the collected
# list in <sourcesvar>. An arbitrary number of targets following the first, mandatory one
# can be passed.
#
# Source files are collected from the following target properties:
#
# * SOURCES
# * INTERFACE_SOURCES
# * PUBLIC_HEADER
# * INTERFACE_HEADER
# * PRIVATE_HEADER
#
# cmake-format: off
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

if(__get_target_sources_defined)
  return()
endif()
set(__get_target_sources_defined ON)

function(get_target_sources _outvar _target)
  set(sources "")
  foreach(tgt ${_target} ${ARGN})
    foreach(property
            SOURCES
            INTERFACE_SOURCES
            PUBLIC_HEADER
            INTERFACE_HEADER
            PRIVATE_HEADER)
      get_target_property(result ${tgt} ${property})
      if(NOT (${result} STREQUAL "result-NOTFOUND" OR ${result} STREQUAL ""))
        list(APPEND sources ${result})
      endif()
    endforeach()
  endforeach()
  set(${_outvar} ${sources} PARENT_SCOPE)
endfunction(get_target_sources)
