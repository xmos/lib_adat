cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(lib_adat)
add_subdirectory(app_adat_rx_example)
add_subdirectory(app_adat_tx_example)
add_subdirectory(app_adat_tx_direct_example)
add_subdirectory(app_adat_loopback)

