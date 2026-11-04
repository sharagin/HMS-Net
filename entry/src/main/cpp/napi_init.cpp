#include "napi/native_api.h"
#include <stdint.h>

extern "C" {
    int StartEngine(int fd, const char* targetAddr);
    int StopEngine();
}

static napi_value StartCore(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t fd = 0;
    napi_get_value_int32(env, args[0], &fd);

    char addr[512] = {0};
    size_t addr_len = 0;
    napi_get_value_string_utf8(env, args[1], addr, sizeof(addr), &addr_len);

    int res = StartEngine(fd, addr);

    napi_value result;
    napi_create_int32(env, res, &result);
    return result;
}

static napi_value StopCore(napi_env env, napi_callback_info info) {
    int res = StopEngine();
    napi_value result;
    napi_create_int32(env, res, &result);
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        { "startCore", nullptr, StartCore, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "stopCore", nullptr, StopCore, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module hmsBridgeModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "hms_bridge",
    .nm_priv = ((void*)0),
    .reserved = { 0 }
};

extern "C" __attribute__((constructor)) void RegisterModule(void) {
    napi_module_register(&hmsBridgeModule);
}
