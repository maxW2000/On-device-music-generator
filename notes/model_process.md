# Main Goal
**light-weight model to better fit mobile devices**

## Methods:
1. Pruning
2. Quantization
3. Knowledge Distillation
   - Teacher model -> soft labels
   - Student model -> inference
   - Loss = Lsoft + LHard 
   - Lsoft = KL LHard = CrossEntropy

4. Mix-precision Inference

# Steps and Rethink

## Quantization
  ```
   #不同方法
   1. model = model.half() float32 -> float16 #存储大小减半
   2.  compressed_model = torch.quantization.quantize_dynamic(
            model,  # 要量化的模型
            {torch.nn.Linear},  # 要量化的模块类型
            dtype=torch.qint8  # 量化后的数据类型
        )  #linear层变成int8格式 存储大小更小only 800mb 但是效果太差
  ```
  2月11： 效果方法一 明显 好于 方法2
  
## Datasets
1. how and where to fetch datasets
