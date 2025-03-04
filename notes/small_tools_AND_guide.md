# yaml and argparse
读取yaml文件 并且使用argparse去加载yaml_config 就可以实现类似于dataclass的功能 这样可以把所有需要的配置放到一个文件中
<br> 比如下面的代码 
```
# config.yaml
param1: value1
param2: 123
param3: [item1, item2, item3]
```
```
param1: value1
param2: 123
param3: ['item1', 'item2', 'item3']
```
```
try:
        with open(yaml_file_path, "r") as yaml_file:
            yaml_config = yaml.safe_load(yaml_file)
        # 创建 argparse.Namespace 对象
        args = argparse.Namespace(**yaml_config)
        # print argument 
        for arg, value in vars(args).items():
            print(f"{arg}: {value}")
    except FileNotFoundError:
        print(f"no yaml file found: {yaml_file_path}")
    except yaml.YAMLError as e:
        print(f"prase yaml file failed: {e}")
    pass
```
# CoreMLTools教程
用于将模型转换成Coreml(苹果适用) <br>
[可变长的input和output]设定(https://apple.github.io/coremltools/docs-guides/source/flexible-inputs.html) <br>
[LLMs转换](https://apple.github.io/coremltools/docs-guides/source/convert-openelm.html)

# Swift-transformers
(用于在swift中使用transformer的swift库)[https://github.com/huggingface/swift-transformers]s
具体导入File -> Add Package Dependencies -> 搜索这个github就可以导入了

# NOTES
1. model() 与 model.generate()的区别
model():方法主要用于获取模型的原始输出，通常是模型最后一层的隐藏状态、对数概率（logits）等。这些输出是模型在处理输入数据时内部计算的中间结果，需要进一步处理才能得到有意义的文本 <br>
model.generate(): 方法是专门用于文本生成的高级接口，它会自动处理模型的输出，根据输入生成连续的文本序列。该方法内部实现了多种文本生成策略，如贪心搜索、束搜索、采样等，可以通过参数进行灵活配置。<br>
generate see here ->(https://blog.csdn.net/weixin_44826203/article/details/129928897)<br>
see here -> [大模型推理两种实现方式的区别：model.generate()和model()](https://blog.csdn.net/qq_61980594/article/details/138341382) <br>
**model.generate**是对model()的一种高级封装, 封装了完整的生成流程（如 beam search、采样、终止条件等），直接返回生成结果。内置多种生成策略（如贪心搜索、top-k/top-p 采样、beam search），简化了代码复杂度

# TorchScript 与 Onnx
可以用于其他平台部署的模型形式 

## Onnx
### Huggingface to Onnx
Huggingface to Onnx具体如何操作查看 ->(https://zhuanlan.zhihu.com/p/715163290)写的比较详细 **包括里面的参数 ！！！**，对于sander-wood模型**本身由encoder-decoder组成，encoder负责文本，decoder负责auto-agressive产出结果并借由tokenizer.decode最终结果，所以把模型拆成两部分进行onnx转换**   <br> 
Sander-wood(Text2Text类型下进行的转换) -> Encoder.onnx + Decoder.onnx 

但是有一些坑遇到的 请查看 ->

# Android 
## Dependency and package
how to import dependency and sync -> see here (https://blog.csdn.net/qq_36158551/article/details/135384497)


# Popular Edge-only frameworks
## Llama.cpp to GGUF

### install llama.cpp
[How to build](https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md) **linux可以直接参考** Windows 和 macos需要额外的一些配置 具体之后再补充

### using llama.cpp to run gguf models
1. build: 参考上面的文档，linux系统可以直接通过非常方便
2. 运行gguf与具体参数 参考 [guide](https://github.com/ggml-org/llama.cpp/blob/master/examples/main/README.md) **main在新版本没了** -> **变成了llama-cli**
### hf to gguf guide
[Tutorial: How to convert HuggingFace model to GGUF format  [UPDATED]](https://github.com/ggml-org/llama.cpp/discussions/7927) <br>
**注意 把里面的convert.py 改成 convert_hf_to_gguf.py**
[Tutorial: How to convert HuggingFace model to GGUF format](https://github.com/ggml-org/llama.cpp/discussions/2948) <br> 

## MNN

## PowerInfer

## ExecuTorch

## MediaPipe


