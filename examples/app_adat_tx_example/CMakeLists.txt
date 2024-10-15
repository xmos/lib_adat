cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_adat_tx_example)

set(APP_HW_TARGET xk-audio-316-mc.xn)
include(${CMAKE_CURRENT_LIST_DIR}/../deps.cmake)
set(APP_COMPILER_FLAGS -g)

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

XMOS_REGISTER_APP()
