# distutils: language = c++

"""Thin wrapper of cuDNN."""
# NOTE: This wrapper does not cover all APIs of cuDNN v4.
cimport cython  # NOQA
from libcpp cimport vector

from cupy_backends.cuda.api cimport driver
from cupy_backends.cuda.api cimport runtime
from cupy_backends.cuda cimport stream as stream_module

###############################################################################
# Extern
###############################################################################

cdef extern from '../../cupy_miopen.h' nogil:
    # Types
    ctypedef int ActivationMode 'miopenActivationMode_t'
    ctypedef int BatchNormMode 'miopenBatchNormMode_t'
    ctypedef int ConvolutionBwdDataAlgo 'miopenConvBwdDataAlgorithm_t'
    ctypedef int ConvolutionBwdFilterAlgo 'miopenConvBwdWeightsAlgorithm_t'
    ctypedef int ConvolutionFwdAlgo 'miopenConvFwdAlgorithm_t'
    ctypedef int ConvolutionMode 'miopenConvolutionMode_t'
    ctypedef int DataType 'miopenDataType_t'
    ctypedef int DirectionMode 'miopenRNNDirectionMode_t'
    ctypedef int NanPropagation 'miopenNanPropagation_t'
    ctypedef int PoolingMode 'miopenPoolingMode_t'
    ctypedef int RNNInputMode 'miopenRNNInputMode_t'
    ctypedef int CTCLossAlgo 'miopenCTCLossAlgo_t'
    ctypedef int RNNMode 'miopenRNNMode_t'
    ctypedef int RNNAlgo 'miopenRNNAlgo_t'
    ctypedef int RNNDataLayout 'miopenRNNBaseLayout_t'
    ctypedef int RNNPaddingMode 'miopenRNNPaddingMode_t'
    ctypedef int SoftmaxAlgorithm 'miopenSoftmaxAlgorithm_t'
    ctypedef int SoftmaxMode 'miopenSoftmaxMode_t'
    ctypedef int Status 'miopenStatus_t'
    ctypedef int TensorFormat 'miopenTensorLayout_t'
    ctypedef int OpTensorOp 'miopenTensorOp_t'
	
    ctypedef int ReduceTensorOp 'miopenReduceTensorOp_t'
    ctypedef int ReduceTensorIndices 'miopenReduceTensorIndices_t'
    ctypedef int IndicesType 'miopenIndicesType_t'
    ctypedef void* ActivationDescriptor 'miopenActivationDescriptor_t'
    ctypedef void* ConvolutionDescriptor 'miopenConvolutionDescriptor_t'
    ctypedef void* DropoutDescriptor 'miopenDropoutDescriptor_t'
    ctypedef void* Handle 'miopenHandle_t'
    ctypedef void* PoolingDescriptor 'miopenPoolingDescriptor_t'
    ctypedef void* CTCLossDescriptor 'miopenCTCLossDescriptor_t'
    ctypedef void* RNNDescriptor 'miopenRNNDescriptor_t'
    ctypedef void* RNNDataDescriptor 'miopenRNNDataDescriptor_t'
    ctypedef void* TensorDescriptor 'miopenTensorDescriptor_t'
    ctypedef void* FilterDescriptor 'miopenTensorDescriptor_t'
    ctypedef void* OpTensorDescriptor 'miopenTensorDescriptor_t'
    ctypedef void* ReduceTensorDescriptor 'miopenReduceTensorDescriptor_t'

    # Error handling
    const char* miopenGetErrorString(Status status)

    # Version
    #size_t miopenGetVersion()

    # Runtime error checking
    #int cudnnQueryRuntimeError(Handle handle, Status *rstatus,
    #                           ErrQueryMode mode, RuntimeTag *tag)

    # Initialization and CUDA cooperation
    int miopenCreate(Handle* handle)
    int miopenDestroy(Handle handle)
    int miopenSetStream(Handle handle, driver.Stream stream)
    int miopenGetStream(Handle handle, driver.Stream* stream)

    # Tensor manipulation
    int miopenCreateTensorDescriptor(TensorDescriptor* descriptor)
    int miopenSet4dTensorDescriptor(
        TensorDescriptor tensorDesc, 
        DataType dataType, int n, int c, int h, int w)
    int miopenSet4dTensorDescriptorEx(
        TensorDescriptor tensorDesc, DataType dataType,
        int n, int c, int h, int w,
        int nStride, int cStride, int hStride, int wStride)
    int miopenGet4dTensorDescriptor(
        TensorDescriptor tensorDesc, DataType* dataType,
        int* n, int* c, int* h, int* w,
        int* nStride, int* cStride, int* hStride, int* wStride)
    int miopenDestroyTensorDescriptor(TensorDescriptor tensorDesc)

    # Tensor operations
    int miopenOpTensor(
        Handle handle, OpTensorDescriptor opTensorDesc, void* alpha1,
        TensorDescriptor aDesc, void* A, void* alpha2,
        TensorDescriptor bDesc, void* B, void* beta,
        TensorDescriptor cDesc, void* C)

    # Tensor reductions
    int miopenCreateReduceTensorDescriptor(
        ReduceTensorDescriptor* reduceTensorDesc)
    int miopenSetReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc, ReduceTensorOp reduceTensorOp,
        DataType reduceTensorCompType, NanPropagation reduceTensorNanOpt,
        ReduceTensorIndices reduceTensorIndices,
        IndicesType reduceTensorIndicesType)
    int miopenGetReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc,
        ReduceTensorOp* reduceTensorOp, DataType* reduceTensorCompType,
        NanPropagation* reduceTensorNanOpt,
        ReduceTensorIndices* reduceTensorIndices,
        IndicesType* reduceTensorIndicesType)
    int miopenDestroyReduceTensorDescriptor(
        ReduceTensorDescriptor reduceTensorDesc)
    int miopenGetReductionIndicesSize(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc,
        TensorDescriptor aDesc, TensorDescriptor cDesc, size_t* sizeInBytes)
    int miopenGetReductionWorkspaceSize(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc,
        TensorDescriptor aDesc, TensorDescriptor cDesc, size_t* sizeInBytes)
    int miopenReduceTensor(
        Handle handle, ReduceTensorDescriptor reduceTensorDesc, void* indices,
        size_t indicesSizeInBytes, void* workspace,
        size_t workspaceSizeInBytes, void* alpha, TensorDescriptor aDesc,
        void* A, void* beta, TensorDescriptor cDesc, void* c)
    int miopenSetTensor(
        Handle handle, TensorDescriptor yDesc, void* y, void* valuePtr)
    int miopenScaleTensor(
        Handle handle, TensorDescriptor yDesc, void* y, void* alpha)

    # Filter manipulation

    # Convolution
    int miopenCreateConvolutionDescriptor(ConvolutionDescriptor* convDesc)
    int miopenSetConvolutionGroupCount(
        ConvolutionDescriptor convDesc, int groupCount)
    int miopenGetConvolutionGroupCount(
        ConvolutionDescriptor convDesc, int *groupCount)
    int miopenDestroyConvolutionDescriptor(ConvolutionDescriptor conDesc)
    int miopenConvolutionForwardGetWorkSpaceSize(
        Handle handle, TensorDescriptor srcDesc,
        FilterDescriptor filterDesc, ConvolutionDescriptor convDesc,
        TensorDescriptor destDesc,
        size_t* sizeInBytes)
    int miopenConvolutionBackwardDataGetWorkSpaceSize(
        Handle handle, FilterDescriptor filterDesc,
        TensorDescriptor diffDesc,
        ConvolutionDescriptor convDesc, TensorDescriptor gradDesc,
        size_t* sizeInBytes)

    # Pooling
    int miopenCreatePoolingDescriptor(PoolingDescriptor* desc)
    int miopenDestroyPoolingDescriptor(PoolingDescriptor poolingDesc)
    # Batch Normalization
    int miopenDeriveBNTensorDescriptor(
        TensorDescriptor derivedBnDesc, TensorDescriptor xDesc,
        BatchNormMode mode)
    int miopenBatchNormalizationForwardTraining(
        Handle handle, BatchNormMode mode,
        void* alpha, void* beta, TensorDescriptor xDesc,
        void* x, TensorDescriptor yDesc, void* y,
        TensorDescriptor bnScaleBiasMeanVarDesc, void* bnScale,
        void* bnBias, double exponentialAverageFactor,
        void* resultRunningMean, void* resultRunningVariance,
        double epsilon, void* resultSaveMean,
        void* resultSaveInvVariance)
    int miopenBatchNormalizationForwardInference(
        Handle handle, BatchNormMode mode,
        void* alpha, void* beta, TensorDescriptor xDesc,
        void* x, TensorDescriptor yDesc, void* y,
        TensorDescriptor bnScaleBiasMeanVarDesc, void* bnScale,
        void* bnBias, void* estimatedMean, void* estimatedVariance,
        double epsilon)
    int miopenBatchNormalizationBackward(
        Handle handle, BatchNormMode mode,
        void* alphaDataDiff, void* betaDataDiff,
        void* alphaParamDiff, void* betaParamDiff,
        TensorDescriptor xDesc, void* x,
        TensorDescriptor dyDesc, void* dy,
        TensorDescriptor dxDesc, void* dx,
        TensorDescriptor dBnScaleBiasDesc, void* bnScale,
        void* dBnScaleResult, void* dBnBiasResult,
        double epsilon, void* savedMean, void* savedInvVariance)


    # Activation
    int miopenCreateActivationDescriptor(
        ActivationDescriptor* activationDesc)
    int cudnnSetActivationDescriptor(
        ActivationDescriptor activationDesc, ActivationMode mode,
        NanPropagation reluNanOpt, double reluCeiling)
    int miopenDestroyActivationDescriptor(
        ActivationDescriptor activationDesc)
    int miopenSoftmaxForward(
        Handle handle, 
        void* alpha, TensorDescriptor srcDesc, void* srcData,
        void* beta, TensorDescriptor dstDesc, void* dstData)
    int miopenSoftmaxBackward(
        Handle handle, 
        void* alpha, TensorDescriptor srcDesc, void* srcData,
        TensorDescriptor srcDiffDesc, void* srcDiffData, void* beta,
        TensorDescriptor destDiffDesc, void* destDiffData)

    # Dropout
    int miopenCreateDropoutDescriptor(DropoutDescriptor* desc)
    int miopenDestroyDropoutDescriptor(DropoutDescriptor dropoutDesc)
    int miopenDropoutGetStatesSize(Handle handle, size_t* sizeInBytes)
    int miopenDropoutGetReserveSpaceSize(
        TensorDescriptor xDesc, size_t* sizeInBytes)

    # CTC
    int miopenCreateCTCLossDescriptor(CTCLossDescriptor* ctcLossDesc)
    int miopenDestroyCTCLossDescriptor(CTCLossDescriptor ctcLossDesc)
    int miopenGetCTCLossWorkspaceSize(
        Handle handle, TensorDescriptor probsDesc,
        TensorDescriptor gradientsDesc, int* labels,
        int* labelLengths, int* inputLengths, CTCLossAlgo algo,
        CTCLossDescriptor ctcLossDesc, size_t* sizeInBytes)
    int miopenCTCLoss(
        Handle handle, TensorDescriptor probsDesc,
        void* probs, int* labels, int* labelLengths, int* inputLengths,
        void* costs, TensorDescriptor gradientsDesc, void* gradients,
        CTCLossAlgo algo, CTCLossDescriptor ctcLossDesc,
        void* workspace, size_t workSpaceSizeInBytes)
    # RNN
    int miopenCreateRNNDescriptor(RNNDescriptor* rnnDesc)
    int miopenDestroyRNNDescriptor(RNNDescriptor rnnDesc)
    int miopenGetRNNWorkspaceSize(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, size_t* sizeInBytes)
    int miopenGetRNNTrainingReserveSize(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, size_t* sizeInBytes)
    int miopenGetRNNParamsSize(
        Handle handle, RNNDescriptor rnnDesc, TensorDescriptor xDesc,
        size_t* sizeInBytes, DataType dataType)
    int miopenRNNForwardInference(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc,
        void* x, TensorDescriptor hxDesc, void* hx, TensorDescriptor cxDesc,
        void* cx, FilterDescriptor wDesc, void* w, TensorDescriptor* yDesc,
        void* y, TensorDescriptor hyDesc, void* hy, TensorDescriptor cyDesc,
        void* cy, void* workspace, size_t workSpaceSizeInBytes)
    int miopenRNNForwardTraining(
        Handle handle, RNNDescriptor rnnDesc, int seqLength,
        TensorDescriptor* xDesc, void* x,
        TensorDescriptor hxDesc, void* hx, TensorDescriptor cxDesc, void* cx,
        FilterDescriptor wDesc, void* w, TensorDescriptor* yDesc, void* y,
        TensorDescriptor hyDesc, void* hy, TensorDescriptor cyDesc, void* cy,
        void* workspace, size_t workSpaceSizeInBytes, void* reserveSpace,
        size_t reserveSpaceSizeInBytes)

    # Build-time version
    int HIP_VERSION

    # Constants
    double _EPSILON 'EPSILON'
"""
cdef class CuDNNAlgoPerf:

    def __init__(self, algo, status, time, memory, determinism, mathType):
        self.algo = algo
        self.status = status
        self.time = time
        self.memory = memory
        self.determinism = determinism
        self.mathType = mathType
"""

###############################################################################
# Error handling
###############################################################################

class CuDNNError(RuntimeError):

    def __init__(self, int status):
        self.status = status
        msg = miopenGetErrorString(<Status>status)
        super(CuDNNError, self).__init__(
            'cuDNN Error: {}'.format(msg.decode()))
        self._infos = []

    def add_info(self, info):
        assert isinstance(info, str)
        self._infos.append(info)

    def add_infos(self, infos):
        assert isinstance(infos, list)
        self._infos.extend(infos)

    def __str__(self):
        base = super(CuDNNError, self).__str__()
        return base + ''.join(
            '\n  ' + info for info in self._infos)

    def __reduce__(self):
        return (type(self), (self.status,))


@cython.profile(False)
cpdef inline check_status(int status):
    if status != 0:
        raise CuDNNError(status)


###############################################################################
# Build-time version
###############################################################################

def get_build_version():
    return CUPY_HIP_VERSION


###############################################################################
# Version
###############################################################################

cpdef size_t getVersion() except? 0:
    return CUPY_HIP_VERSION


###############################################################################
# Runtime error checking
###############################################################################

#cpdef queryRuntimeError(intptr_t handle, int mode):
#    cdef Status rstatus
#    with nogil:
#        status = cudnnQueryRuntimeError(<Handle>handle, &rstatus,
#                                        <ErrQueryMode>mode, <RuntimeTag*>0)
#    check_status(status)
#    return rstatus


###############################################################################
# Initialization and CUDA cooperation
###############################################################################

cpdef intptr_t create() except? 0:
    cdef Handle handle
    with nogil:
        status = miopenCreate(&handle)
    check_status(status)
    return <intptr_t>handle


cpdef destroy(intptr_t handle):
    with nogil:
        status = miopenDestroy(<Handle>handle)
    check_status(status)


cpdef size_t createDropoutDescriptor() except? 0:
    cdef DropoutDescriptor desc
    status = miopenCreateDropoutDescriptor(&desc)
    check_status(status)
    return <size_t>desc

cpdef destroyDropoutDescriptor(size_t dropoutDesc):
    status = miopenDestroyDropoutDescriptor(<DropoutDescriptor>dropoutDesc)
    check_status(status)


cpdef Py_ssize_t dropoutGetStatesSize(intptr_t handle) except? -1:
    cdef size_t sizeInBytes
    status = miopenDropoutGetStatesSize(
        <Handle>handle, &sizeInBytes)
    check_status(status)
    return <Py_ssize_t>sizeInBytes
	
cpdef size_t getDropoutReserveSpaceSize(size_t xDesc) except? 0:
    cdef size_t sizeInBytes
    status = miopenDropoutGetReserveSpaceSize(
        <TensorDescriptor>xDesc, &sizeInBytes)
    check_status(status)
    return sizeInBytes
