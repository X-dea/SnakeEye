#include "common.hpp"

#include "include/dart_api_dl.h"

FFI_EXPORT void InitializeDartApi(void *data) { Dart_InitializeApiDL(data); }