cmake_minimum_required(VERSION 3.21)
include($ENV{XMOS_CMAKE_PATH}/xcommon.cmake)
project(app_adat_loopback)

set(APP_HW_TARGET xk-audio-316-mc.xn)
set(APP_DEPENDENT_MODULES "lib_adat"
                          "lib_sw_pll")
set(APP_COMPILER_FLAGS -O3 -g -DADAT_TX_USE_SHARED_BUFF)

set(XMOS_SANDBOX_DIR ${CMAKE_CURRENT_LIST_DIR}/../../..)

XMOS_REGISTER_APP()
