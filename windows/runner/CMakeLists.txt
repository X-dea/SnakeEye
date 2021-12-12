cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

find_package(OpenCV REQUIRED PATHS ../../third_party/opencv/build/x64/vc15/lib)

file(GLOB ffi_src
     "../../lib/*.hpp"
     "../../lib/*.cpp"
     "../../lib/include/*.h"
     "../../lib/include/*.cpp"
)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
  ${ffi_src}
)
apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app ${OpenCV_LIBS})
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}" ${OpenCV_INCLUDE_DIRS})
add_dependencies(${BINARY_NAME} flutter_assemble)
