cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(lib_adat)

# Get a list of all subdirectories in the current directory
file(GLOB subdirs RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} */)

# Loop through each subdirectory and add it if it contains a CMakeLists.txt file
foreach(subdir ${subdirs})
    if(IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${subdir} AND EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${subdir}/CMakeLists.txt)
        add_subdirectory(${subdir})
    endif()
endforeach()

