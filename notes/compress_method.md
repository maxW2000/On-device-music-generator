# 剪枝方法 pruning
| 参数名 | 库 | 作用 |
|:----:|:----:|:----:|
|pruning_method|PyTorch,|指定剪枝方法，如l1_unstructured, l2_structured, random_unstructured等|
|sparsity|PyTorch|指定模型的稀疏度，即希望保留多少比例的参数|
|amount|PyTorch|指定模型的稀疏度，即希望保留多少比例的参数|
|pruning_algorithm|Hugging Face Transformers|指定剪枝算法，如magnitude, movement等|
|pruning_threshold|Hugging Face Transformers|指定剪枝的阈值，低于该阈值的权重将被剪枝|
|pruning_steps|Hugging Face Transformers|指定剪枝的步骤数，通常用于逐步剪枝|
