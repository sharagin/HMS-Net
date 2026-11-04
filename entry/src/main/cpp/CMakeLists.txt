cmake_minimum_required(VERSION 3.4.1)
project(hms_bridge)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
)

add_library(hmsnet_core SHARED IMPORTED)
set_target_properties(hmsnet_core PROPERTIES IMPORTED_LOCATION
    ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/libhmsnet_core.so
)

add_library(hms_bridge SHARED napi_init.cpp)

target_link_libraries(hms_bridge PUBLIC
    hmsnet_core
    libace_napi.z.so
    libhilog_ndk.z.so
)
