# 一些代码小坑
1. 加载env的时候需要先load_dotenv(), 再os.getenv()
```
from dotenv import load_dotenv
load_dotenv()

import os
os.getenv(MDOEL_PATH)
```
# 模型训练坑
```
"RuntimeError: Failed to import transformers.models.musicgen.modeling_musicgen because of the following error (look up to see its traceback):
All ufuncs must have type `numpy.ufunc`. Received (<ufunc 'sph_legendre_p'>, <ufunc 'sph_legendre_p'>, <ufunc 'sph_legendre_p')"
```
pip install "transformers<4.37.0" 降级了transformer解决了
但是后续有遇到没有包的问题 又升级了transformer解决了
**ipynb和py用同一个kernel****但是ipynb需要重启一下kernel才会更新库**

## 模型转换
**CoreML库不太支持Windows, 用unix类系统**
1. 使用CoreML对模型进行转换 且 若目标版本高于iOS15 只能是convert to "mlprograme"且格式为.mlpackage
2. 还记得要把模型的各种config导入 并且进行分词，用于模型的input生成 (现在用transformer-swift库了)
3. 模型转换中报错溢出问题 在convert函数加入了 config = CT.ComputeUnit.ALL compute_units = config, conpute_precision = ct.recision.FLOAT32解决了
4. coreml本身不直接支持transformer过来的 需要转换成torchscript -> Coreml


## 数据处理
**文本的token可能一个词对应好几个 比如80s -> [2776，7]**
（80s pop track with bassy drums and synth）[2775,7,2783,1463,28,7981,63,5253,7,11,13353,1,0] 此模型用[1]为eos [0]为pad 所以attention_MASK为[1,1,1,1,1,1,1,1,1,1,1,1,0]
# ios开发坑

## 文本输入
1. **需要自己实现text转换token逻辑** 要去看模型的配置文件去更改具体逻辑内容
2. 自行添加的文件夹想要调用 需要放到Assets中 并且在Assets中选中文件 在右侧的Target Memebership中添加项目Target才能获得
3. 转换模型时应该注意input的shape 需要为可变的 因为用户输入text的时候肯定是可变长的文本

## 模型输出
1. 一开始输出为nan 后面发现是因为**模型没有转换好** 参看上，上面模型转换第**3**点

# 安卓开发
