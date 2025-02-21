# 2.21
1. Try to convert MusicGen to TorchScript: Failed. Reason: Have to avoid Audio input, Also, the output from model() is incorrect, have to convert generate Function(**Failed**)
2. Try to convert model from Text(Must)-Audio(Selected, but if convert TorchScript, must have) -> Muisc to Text -> Muisc   
