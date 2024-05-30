cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_adat_tx_example)

set(APP_HW_TARGET xk-audio-316-mc.xn)
set(APP_DEPENDENT_MODULES "lib_adat"
                          "lib_sw_pll")
set(APP_COMPILER_FLAGS -g)

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

XMOS_REGISTER_APP()
