# 2.21
1. Try to convert MusicGen to TorchScript: Failed. Reason: Have to avoid Audio input, Also, the output from model() is incorrect, have to convert generate Function(**Failed**)
2. Try to convert model from Text(Must)-Audio(Selected, but if convert TorchScript, must have) -> Muisc to Text -> Muisc   

# 2.22
1. Try new Model sander_wood https://huggingface.co/sander-wood/text-to-music
2. convert to Onnx Successful ✔️

# 2.23 - 2.24
1. Try convert sander-wood onnx to coreml and sander-wood pytorch to sander-wood. Still have problem
2. complete the structure of iOS on-device generator. I need to find more models

# 2.25
Try to find more models and GGUFs. 

# 2.27 - 3.2
1. learn how to use LLama.cpp 
2. Try to convert GGUF, three models in **candidate_models** only the third one is supported
3. The third model, is still a LLM but can only generate some text about lyrics and melody

# 3.4 
1. I learned the main structure of MusicGen(forward and generate where are they and how they worked) and tried to convert them separately. Still failed XD
2. convert to ONNX, [reference small_tools_AND_guide.md Huggingface to ONNX](https://github.com/maxW2000/On-device-music-generator/blob/main/notes/small_tools_AND_guide.md) and (https://github.com/huggingface/optimum/pull/1779) **--task = text-to-audio**

# 3.6 
successfully convert ONNX for Sander-wood model and deploy on iOS

# 3.11
sucessfully implement the generation function of Musicgen, by Debug and go through the whole Generation Function of MusicGen

# 3.19
Distill Musicgen small

# 3.22
Generate music using ONNX, (using decoder_model.onnx )
# Next step
still find more models, maybe I have to convert by myself to re-write the underlying codes
