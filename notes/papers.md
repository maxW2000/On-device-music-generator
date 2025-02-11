# Models
1.  [On-Device Language Models: A Comprehensive Review](https://arxiv.org/pdf/2409.00088)
2.  [Simple and Controllable Music Generation](https://arxiv.org/pdf/2306.05284) 目前在研究这个模型 02/06/2025
```
SMALL 版本
MusicgenForConditionalGeneration: 1 layers, 586,884,674 parameters
T5EncoderModel: 1 layers, 109,628,544 parameters
Embedding: 6 layers, 33,067,392 parameters
T5Stack: 1 layers, 109,628,544 parameters
ModuleList: 27 layers, 647,771,970 parameters
T5Block: 12 layers, 84,953,472 parameters
T5LayerSelfAttention: 12 layers, 28,321,152 parameters
T5Attention: 12 layers, 28,311,936 parameters
Linear: 317 layers, 496,763,904 parameters
T5LayerNorm: 25 layers, 19,200 parameters
Dropout: 37 layers, 0 parameters
T5LayerFF: 12 layers, 56,632,320 parameters
T5DenseActDense: 12 layers, 56,623,104 parameters
ReLU: 12 layers, 0 parameters
EncodecModel: 1 layers, 56,884,674 parameters
EncodecEncoder: 1 layers, 28,441,984 parameters
EncodecConv1d: 24 layers, 13,267,586 parameters
ParametrizedConv1d: 24 layers, 13,267,586 parameters
ModuleDict: 28 layers, 23,290,497 parameters
ParametrizationList: 28 layers, 23,290,497 parameters
_WeightNorm: 28 layers, 0 parameters
EncodecResnetBlock: 8 layers, 1,398,400 parameters
ELU: 26 layers, 0 parameters
Identity: 8 layers, 0 parameters
EncodecLSTM: 2 layers, 33,587,200 parameters
LSTM: 2 layers, 33,587,200 parameters
EncodecDecoder: 1 layers, 28,442,690 parameters
EncodecConvTranspose1d: 4 layers, 10,029,888 parameters
ParametrizedConvTranspose1d: 4 layers, 10,029,888 parameters
EncodecResidualVectorQuantizer: 1 layers, 0 parameters
EncodecVectorQuantization: 4 layers, 0 parameters
EncodecEuclideanCodebook: 4 layers, 0 parameters
MusicgenForCausalLM: 1 layers, 419,584,000 parameters
MusicgenModel: 1 layers, 411,195,392 parameters
MusicgenDecoder: 1 layers, 411,195,392 parameters
MusicgenSinusoidalPositionalEmbedding: 1 layers, 0 parameters
MusicgenDecoderLayer: 24 layers, 402,800,640 parameters
MusicgenSdpaAttention: 48 layers, 201,326,592 parameters
GELUActivation: 24 layers, 0 parameters
LayerNorm: 73 layers, 149,504 parameters
``` 
# Compress Method
1. [One-shot Pruning Technique for Interchangeable Networks (OPTIN) framework ](https://github.com/Skhaki18/optin-transformer-pruning)
- **the efficiency of pre-trained transformer architectures, across many domains, without requiring re-training**
   [The Need for Speed: Pruning Transformers with One Recipe](https://arxiv.org/abs/2403.17921v1)
