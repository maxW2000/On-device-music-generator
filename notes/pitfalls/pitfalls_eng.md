# Some Code Pitfalls
When loading the .env file, you need to call load_dotenv() first, and then use os.getenv().

```
from dotenv import load_dotenv
load_dotenv()

import os
os.getenv(MDOEL_PATH)
```

# Model Training Pitfalls
```
"RuntimeError: Failed to import transformers.models.musicgen.modeling_musicgen because of the following error (look up to see its traceback):
All ufuncs must have type `numpy.ufunc`. Received (<ufunc'sph_legendre_p'>, <ufunc'sph_legendre_p'>, <ufunc'sph_legendre_p')"
```
Downgrading the transformers library to a version lower than 4.37.0 using pip install "transformers<4.37.0" solved the problem.
However, later there was an issue of missing packages, and upgrading the transformers library solved it.
Both .ipynb and .py use the same kernel, but the .ipynb file needs to restart the kernel to update the libraries.

# Model Conversion
The CoreML library does not support Windows very well. It is recommended to use Unix-like systems.
1. Use CoreML to convert the model. And if the target version is higher than iOS15, you can only convert it to "mlprograme" and the format should be .mlpackage.
2. Remember to import all kinds of configurations of the model and perform tokenization, which is used for generating the input of the model (now the transformer-swift library is used).
3. When there was an overflow error during the model conversion, adding config = CT.ComputeUnit.ALL compute_units = config, conpute_precision = ct.recision.FLOAT32 in the convert function solved the problem.
4. CoreML itself does not directly support models from transformers. It is necessary to convert them to torchscript first and then to CoreML.
# Data Processing
A single word in the text token may correspond to several tokens. For example, "80s" -> [2776, 7]
For the text "(80s pop track with bassy drums and synth)", the corresponding tokens are [2775,7,2783,1463,28,7981,63,5253,7,11,13353,1,0]. 
In this model, [1] is used as the end-of-sentence (eos) token and [0] is used as the padding (pad) token. So the attention_mask is [1,1,1,1,1,1,1,1,1,1,1,1,0].

# iOS Development Pitfalls
Text Input
1. You need to implement the logic of converting text to tokens by yourself. You need to check the configuration file of the model to modify the specific logic content.
2. If you want to call a self-added folder, you need to put it in the Assets folder. And after selecting the file in the Assets folder, add the project target in the Target Membership on the right side to access it.
3. When converting the model, you should pay attention to the shape of the input. It should be variable because the user's input text is definitely of variable length.
4. Reading the tokenizer: Read the local tokenzier and tokenizerconfig files -> in the Data format -> Refer to the GitHub Hub library to parse the Data into a dictionary of type [NSString: Any] -> in the Config format (the format in the Transformer library). Refer to GitHub.
```
// In the Config format. There is an implementation in the Hub library. Refer to the GitHub notes for details.
self.tokenizer = try AutoTokenizer.from(
tokenizerConfig: tokenizerConfig, tokenizerData: tokenizerData)
```
Refers:
https://github.com/huggingface/swift-transformers/blob/2eea3158b50ac7e99c9b5d4df60359daed9b832c/Sources/Hub/Hub.swift
https://github.com/huggingface/swift-transformers/issues/76

# Model Output
At first, the output was nan. Later, it was found that it was because the model was not converted properly. Refer to the above point 3 in the model conversion section.
Android Development
