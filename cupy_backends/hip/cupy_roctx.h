#ifndef INCLUDE_GUARD_HIP_CUPY_ROCTX_H
#define INCLUDE_GUARD_HIP_CUPY_ROCTX_H

#ifndef CUPY_NO_NVTX
    #include <roctx.h>
#endif // #ifndef CUPY_NO_NVTX

// This is to ensure we use non-"Ex" APIs like roctxMarkA etc
#define NVTX_VERSION (100 * ROCTX_VERSION_MAJOR + 10 * ROCTX_VERSION_MINOR)

extern "C" {

// Define NVTX compatible types and functions if NVTX is not available
typedef enum nvtxColorType_t {
    NVTX_COLOR_UNKNOWN  = 0,
    NVTX_COLOR_ARGB     = 1
} nvtxColorType_t;

typedef enum nvtxMessageType_t {
    NVTX_MESSAGE_UNKNOWN          = 0,
    NVTX_MESSAGE_TYPE_ASCII       = 1,
    NVTX_MESSAGE_TYPE_UNICODE     = 2,
} nvtxMessageType_t;

typedef union nvtxMessageValue_t {
    const char* ascii;
    const wchar_t* unicode;
} nvtxMessageValue_t;

typedef struct nvtxEventAttributes_v1 {
    uint16_t version;
    uint16_t size;
    uint32_t category;
    int32_t colorType;
    uint32_t color;
    int32_t payloadType;
    int32_t reserved0;
    union payload_t {
        uint64_t ullValue;
        int64_t llValue;
        double dValue;
    } payload;
    int32_t messageType;
    nvtxMessageValue_t message;
} nvtxEventAttributes_v1;

typedef nvtxEventAttributes_v1 nvtxEventAttributes_t;

// Fallback functions for NVTX using ROCtx

void nvtxMarkA(const char* message) {
    roctxMarkA(message);
}

void nvtxMarkEx(const nvtxEventAttributes_t* attrib) {
    roctxMarkA(attrib->message.ascii); // ROCtx doesn't support attributes, only message
}

int nvtxRangePushA(const char* message) {
    return roctxRangePushA(message);
}

int nvtxRangePushEx(const nvtxEventAttributes_t* attrib) {
    return roctxRangePushA(attrib->message.ascii); // ROCtx doesn't support attributes, only message
}

int nvtxRangePop() {
    return roctxRangePop();
}

uint64_t nvtxRangeStartEx(const nvtxEventAttributes_t* attrib) {
    return roctxRangePushA(attrib->message.ascii); // Using range push as ROCtx does not have start
}


} // extern "C"

#endif // INCLUDE_GUARD_HIP_CUPY_ROCTX_H
