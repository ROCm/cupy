cdef extern from *:
    ctypedef int OutputMode 'cudaOutputMode_t'

cpdef enum:
    cudaKeyValuePair = 0
    cudaCSV = 1

IF CUPY_HIP_VERSION == 0:
    cpdef initialize(str config_file, str output_file, int output_mode)
    cpdef start()
    cpdef stop()
