# 2.21
1. Try to convert MusicGen to TorchScript: Failed. Reason: Have to avoid Audio input, Also, the output from model() is incorrect, have to convert generate Function(**Failed**)
2. Try to convert model from Text(Must)-Audio(Selected, but if convert TorchScript, must have) -> Muisc to Text -> Muisc   

# 2.22
1. Try new Model sander_wood https://huggingface.co/sander-wood/text-to-music
2. convert to Onnx Successful &#x2713
