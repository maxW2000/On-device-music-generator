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
1. I learned the whole structure of MusicGen and tried to convert them separately. Still failed XD
2. convert to ONNX, [reference small_tools_AND_guide.md Huggingface to ONNX](https://github.com/maxW2000/On-device-music-generator/blob/main/notes/small_tools_AND_guide.md) **--task = text-to-audio**
# Next step
still find more models, maybe I have to convert by myself to re-write the underlying codes
