cmake_minimum_required(VERSION 3.14)
project(shutdown_messenger_test LANGUAGES CXX)

# Standalone: does not require a WebView2 runtime or a running Flutter engine.
set(FLUTTER_WRAPPER_INCLUDE_DIR "" CACHE PATH "Flutter cpp_client_wrapper/include")
if(NOT EXISTS "${FLUTTER_WRAPPER_INCLUDE_DIR}/flutter/binary_messenger.h")
  message(FATAL_ERROR "Set FLUTTER_WRAPPER_INCLUDE_DIR to cpp_client_wrapper/include")
endif()

enable_testing()
add_executable(shutdown_aware_messenger_test ../shutdown_aware_messenger_test.cpp)
target_compile_features(shutdown_aware_messenger_test PRIVATE cxx_std_17)
target_include_directories(shutdown_aware_messenger_test PRIVATE "${FLUTTER_WRAPPER_INCLUDE_DIR}")
if(MSVC)
  target_compile_options(shutdown_aware_messenger_test PRIVATE /W4 /WX /UNDEBUG)
else()
  target_compile_options(shutdown_aware_messenger_test PRIVATE -Wall -Wextra -Werror -UNDEBUG)
endif()
add_test(NAME shutdown_aware_messenger COMMAND shutdown_aware_messenger_test)