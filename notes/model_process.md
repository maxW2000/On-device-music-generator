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
