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
1. Linear Layer √ 
2. Attention Layer √
3. Parameterized Conv1d X
```
def _prune_linear(self) -> torch.nn.Module:
        """pruning Linear Layer"""
        print(f"Pruning linear layers with ratio: {self.config.linear_sparsity_ratio}")
        
        for name, module in self.model.named_modules():
            if isinstance(module, torch.nn.Linear):
                prune.l1_unstructured(
                    module,
                    name='weight',
                    amount=self.config.linear_sparsity_ratio
                )
                prune.remove(module, 'weight')
                
        return self.model
    
    def _prune_attention(self) -> torch.nn.Module:
        """pruning Attention Layer"""
        print(f"Pruning attention layers with ratio: {self.config.attention_sparsity_ratio}")
        
        for name, module in self.model.named_modules():
            if "attention" in name:
                for param_name in ['query', 'key', 'value']:
                    if hasattr(module, param_name):
                        prune.l1_unstructured(
                            module,
                            name=param_name,
                            amount=self.config.attention_sparsity_ratio
                        )
                        prune.remove(module, param_name)
            
        return self.model
```
Pruning Result: Worked but the results are not good, but could be used

## Distill
Not Started yet, I think I need **Dataset**, **any method I only need a little data to distill.**

## Mix-precision Inference
enlightened by DeepSeek tech report, trying to figure out HOW :(

## Evaluations
1. FLOPs
2. Parameters counting -> Zeros Vs. Non-Zeros
3. Cosine Similarity for the original model and compressed model
4. 
## Datasets
1. fetch datasets from the large-version model, trying to use it for re-train Compressed Model and distilling
