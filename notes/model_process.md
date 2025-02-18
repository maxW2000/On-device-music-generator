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
   #different method
   1. model = model.half() float32 -> float16 #half storage
   2.  compressed_model = torch.quantization.quantize_dynamic(
            model,  # model
            {torch.nn.Linear},  # module type
            dtype=torch.qint8  
        )  #linear turn to int8 only 800mb but horrible 
  ```
  2.11: method 1 > method 2

## Pruning
  
## Evaluations
1. FLOPs
2. Parameters counting -> Zeros Vs. Non-Zeros  
## Datasets
1. how and where to fetch datasets
