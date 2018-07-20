#
# .rst: FindClangTidy
# ---------------
# cmake-format: off
#
# The module defines the following variables
#
# ``CLANG_TIDY_EXECUTABLE``
#   Path to clang-format executable
# ``CLANG_TIDY_FOUND``
#   True if the clang-format executable was found.
#
# Example usage:
#
# .. code-block:: cmake
#
#    find_package(ClangFormat)
#    if(CLANG_TIDY_FOUND)
#      message("clang-format executable found: ${CLANG_TIDY_EXECUTABLE}\n"
#              "version: ${CLANG_TIDY_VERSION}")
#    endif()
# cmake-format: on

find_program(CLANG_TIDY_EXECUTABLE
             NAMES clang-tidy
                   clang-tidy-7.0
                   clang-tidy-6.0
                   clang-tidy-5.0
                   clang-tidy-4.0
                   clang-tidy-3.9
                   clang-tidy-3.8
                   clang-tidy-3.7
                   clang-tidy-3.6
                   clang-tidy-3.5
                   clang-tidy-3.4
                   clang-tidy-3.3
                   clang-tidy-3.2
                   clang-tidy-3.1
                   clang-tidy-3.0
             DOC "clang-tidy executable")
mark_as_advanced(CLANG_TIDY_EXECUTABLE)

if(CLANG_TIDY_EXECUTABLE)
  set(CLANG_TIDY_FOUND TRUE)
else()
  set(CLANG_TIDY_FOUND FALSE)
endif()
