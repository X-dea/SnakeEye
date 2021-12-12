#pragma once

#include <cstdint>

#ifdef _MSC_VER
#include <Windows.h>
#define FFI_EXPORT extern "C" __declspec(dllexport)
#else
#define FFI_EXPORT \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif
