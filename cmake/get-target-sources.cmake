# get_target_sources : returns all the source files (including headers) associated to the
# given targets.
#
# --- Arguments ---
#
# * output: the output variable in which the list of sources will be stored in parent
#   scope
# * targets...: an arbitrary list of targets
#
function(get_target_sources output)
  set(sources "")
  foreach(target ${ARGN})
    foreach(property
            SOURCES
            INTERFACE_SOURCES
            PUBLIC_HEADER
            INTERFACE_HEADER
            PRIVATE_HEADER)
      get_target_property(result ${target} ${property})
      if(NOT (${result} STREQUAL "result-NOTFOUND" OR ${result} STREQUAL ""))
        list(APPEND sources ${result})
      endif()
    endforeach()
  endforeach()
  set(${output} ${sources} PARENT_SCOPE)
endfunction(get_target_sources)
