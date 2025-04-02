# 如何查看模型源码
1. 查看模型的modeling.py文件
2. 一个模型会有何很多实现方法，但是只会有一个基础模型 剩下的都是基于基础模型进行改动 所以去看每个的init函数看初始化的方法
3. 查看模型的forward函数
具体教程查看(https://www.bilibili.com/video/BV1qj411y7kF?spm_id_from=333.788.videopod.sections&vd_source=234c80191af506a33d1391d3242014c4)讲的很好

# Generate Function
1. 继承自 **GenerationMixin** 类，模型会对generate方法进行重写
2. 几个重要看的函数  <br> _prepare_model_inputs <br> _prepare_text_encoder_kwargs_for_generation (目前仅限musicgen 因为musicgen的encoder是用的T5)
3. <br> _prepare_decoder_input_ids_for_generation <br> _prepare_generated_length <br> build_delay_pattern_mask (对于musicgen 参考论文其delaypatternmask的实现模式)
4. <br> get_generation_mode <br> _get_logits_processor
