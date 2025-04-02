# 如何查看模型源码
1. 查看模型的modeling.py文件
2. 一个模型会有何很多实现方法，但是只会有一个基础模型 剩下的都是基于基础模型进行改动 所以去看每个的init函数看初始化的方法
3. 查看模型的forward函数
具体教程查看(https://www.bilibili.com/video/BV1qj411y7kF?spm_id_from=333.788.videopod.sections&vd_source=234c80191af506a33d1391d3242014c4)讲的很好

# Generate Function
1. 继承自 **GenerationMixin** 类，模型会对generate方法进行重写
2. 几个重要看的函数  <br> _prepare_model_inputs() <br> _prepare_text_encoder_kwargs_for_generation() (目前仅限musicgen 因为musicgen的encoder是用的T5)
<br> _prepare_decoder_input_ids_for_generation() <br> _prepare_generated_length() <br> build_delay_pattern_mask() (对于musicgen 参考论文其delaypatternmask的实现模式)
<br> get_generation_mode <br> _get_logits_processor <br> _get_stopping_criteria

## _sample 函数 from GenerationMixin class
这个函数实现了调用decoder的具体方法 需要认真查看 <br> 包括 
1. prepare_inputs_for_generation ()
2. model_forward()
3. logits_processor() 处理logit
具体方法可以查看 (https://www.bilibili.com/video/BV1rGBZYeEuH/?spm_id_from=333.999.0.0) 大模型的所有解码策略
4. do_sample
具体查看大模型的生成模式(https://www.bilibili.com/video/BV16RfHYQErF?spm_id_from=333.788.videopod.sections&vd_source=234c80191af506a33d1391d3242014c4)
5. generate with past key value. 若使用kvcache **此时decoderinput 只需要输入最新生成的token即可 因为之前的token都被记录下来了**


