//
//  ONNXService.swift
//  ondevicetext2music
//
//  Created by Max Fr on 3/6/25.
//

import Foundation
import onnxruntime_objc
import CoreML

// 错误类型定义
public enum ONNXModelError: Error {
    case modelFileNotFound
    case modelInferenceError
    case onnxTokenizerNotInitialized
    case inputProcessingError
    case sessionCreationError
    case invalidOutputShape
}

public class ONNXMusicService {
    // MARK: - Properties
    private let ortEnv: ORTEnv
    private var encoderSession: ORTSession?
    private var decoderSession: ORTSession?
    private var tokenizer: SanderWoodTokenizer?
    
    // 生成配置
    struct GenerationConfig {
        let maxLength: Int
        let temperature: Float
        let topP: Float
        let eosTokenId: Int32
        let padTokenId: Int32
        let decoderStartTokenId: Int32
    }
    
    private let generationConfig: GenerationConfig
    
    // 启用详细日志
    private let debugMode = true
    
    // MARK: - Initialization
    public init() throws {
        // 创建ONNX Runtime环境
        self.ortEnv = try ORTEnv(loggingLevel: .warning)
        
        // 默认生成配置
        self.generationConfig = GenerationConfig(
            maxLength: 512,
            temperature: 0.7,
            topP: 0.9,
            eosTokenId: 2,   // </s> token ID
            padTokenId: 1,   // <pad> token ID
            decoderStartTokenId: 0  // decoder_start_token_id
        )
        
        // 加载模型和分词器
        try loadModels()
        try loadTokenizer()
    }
    
    // MARK: - Private Methods
    private func loadModels() throws {
        // 加载编码器模型
        guard let encoderPath = Bundle.main.path(forResource: "encoder_model", ofType: "onnx") else {
            print("❌ Failed to find encoder model file")
            throw ONNXModelError.modelFileNotFound
        }
        print("✅ Successfully found encoder model: \(encoderPath)")
        
        // 加载解码器模型
        guard let decoderPath = Bundle.main.path(forResource: "decoder_model", ofType: "onnx") else {
            print("❌ Failed to find decoder model file")
            throw ONNXModelError.modelFileNotFound
        }
        print("✅ Successfully found decoder model: \(decoderPath)")
        
        // 检查文件大小
        let encoderFileSize = try FileManager.default.attributesOfItem(atPath: encoderPath)[.size] as? Int ?? 0
        let decoderFileSize = try FileManager.default.attributesOfItem(atPath: decoderPath)[.size] as? Int ?? 0
        
        print("📊 Encoder model size: \(encoderFileSize / 1024 / 1024) MB")
        print("📊 Decoder model size: \(decoderFileSize / 1024 / 1024) MB")
        
        // create session options
        let sessionOptions = try ORTSessionOptions()
        
        // set threads
        try sessionOptions.setIntraOpNumThreads(1)  // 设置线程数
        
        // Start creating sessions
        do {
            self.encoderSession = try ORTSession(env: ortEnv, modelPath: encoderPath, sessionOptions: sessionOptions)
            self.decoderSession = try ORTSession(env: ortEnv, modelPath: decoderPath, sessionOptions: sessionOptions)
            
            // input: input_ids and attention_mask
            // output: last_hidden_state
            if let encoderSession = self.encoderSession {
                print("✨ 编码器输入名称:")
                for inputName in try encoderSession.inputNames() {
                    print("  - \(inputName)")
                }
            
                print("✨ 编码器输出名称:")
                for outputName in try encoderSession.outputNames() {
                    print("  - \(outputName)")
                }
            }
            
            // input: input_ids, encoder_hidden_states, encoder_attention_mask
            // output: logits
            if let decoderSession = self.decoderSession {
                print("✨ 解码器输入名称:")
                for inputName in try decoderSession.inputNames() {
                    print("  - \(inputName)")
                }
            
                print("✨ 解码器输出名称:")
                for outputName in try decoderSession.outputNames() {
                    print("  - \(outputName)")
                }
            }
            
            print("✅ success to create sessions")
        } catch {
            print("❌ failed to create sessions: \(error)")
            throw ONNXModelError.sessionCreationError
        }
    }
    
    private func loadTokenizer() {
        // 使用SanderWoodTokenizer的初始化方法
        self.tokenizer = SanderWoodTokenizer()
        print("✅ 成功加载Tokenizer")
    }
    
    // MARK: - Prediction
    public func generateMusic(from text: String) async throws -> String {
        print("🔍 ONNX: 开始生成音乐，输入文本: \(text)")
        
        // 保证不在主线程上运行
        if Thread.isMainThread {
            print("⚠️ 警告: generateMusic在主线程上运行，这可能导致UI冻结")
        }
        
        guard let tokenizer = self.tokenizer else {
            print("🔍 ONNX: ❌ 错误: Tokenizer未初始化")
            throw ONNXModelError.onnxTokenizerNotInitialized
        }
        
        guard let encoderSession = self.encoderSession, let decoderSession = self.decoderSession else {
            print("🔍 ONNX: ❌ 错误: ONNX会话未初始化")
            throw ONNXModelError.sessionCreationError
        }
        
        // 添加try-catch包装关键操作
        do {
            print("🔍 ONNX: 开始tokenize文本")
            let (inputIdsMultiArray, attentionMaskMultiArray) = try tokenizer.tokenize(text: text)
            print("🔍 ONNX: Tokenize成功，token长度: \(inputIdsMultiArray.count / inputIdsMultiArray.shape[0].intValue)")
            
            // 2. 将MultiArray转换为Int64数组
            let length = inputIdsMultiArray.count / inputIdsMultiArray.shape[0].intValue
            var inputIdsArray = [Int64]()
            var attentionMaskArray = [Int64]()
            
            for i in 0..<length {
                inputIdsArray.append(Int64(inputIdsMultiArray[i].intValue))
                attentionMaskArray.append(Int64(attentionMaskMultiArray[i].intValue))
            }
            print("🔍 ONNX: 转换为Int64数组成功")
            
            // 创建输入Tensor
            let inputIdsShape: [NSNumber] = [1, NSNumber(value: length)]
            print("🔍 ONNX: 创建输入Tensor，形状: \(inputIdsShape)")
            
            // 安全地创建NSMutableData
            guard inputIdsArray.count > 0 else {
                print("🔍 ONNX: ❌ 错误: 输入ID数组为空")
                throw ONNXModelError.inputProcessingError
            }
            
            // Convert to NSMutableData - 这里可能有问题
            let inputIdsData = NSMutableData(bytes: inputIdsArray, length: inputIdsArray.count * MemoryLayout<Int64>.size)
            print("🔍 ONNX: 创建inputIdsData成功，大小: \(inputIdsData.length)字节")
            
            // 以下是可能崩溃的点，添加更多安全检查
            do {
                print("🔍 ONNX: 创建inputIdsTensor")
                guard let inputIdsTensor = try? ORTValue(
                    tensorData: inputIdsData,
                    elementType: ORTTensorElementDataType.int64,
                    shape: inputIdsShape
                ) else {
                    print("🔍 ONNX: ❌ 错误: 无法创建inputIdsTensor")
                    throw ONNXModelError.inputProcessingError
                }
                
                print("🔍 ONNX: 创建attentionMaskData")
                let attentionMaskData = NSMutableData(bytes: attentionMaskArray, length: attentionMaskArray.count * MemoryLayout<Int64>.size)
                
                print("🔍 ONNX: 创建attentionMaskTensor")
                guard let attentionMaskTensor = try? ORTValue(
                    tensorData: attentionMaskData,
                    elementType: ORTTensorElementDataType.int64,
                    shape: inputIdsShape
                ) else {
                    print("🔍 ONNX: ❌ 错误: 无法创建attentionMaskTensor")
                    throw ONNXModelError.inputProcessingError
                }
                
                // 2. 运行编码器
                print("🔍 ONNX: 准备运行编码器")
                
                // 检查输入名称
                do {
                    let inputNames = try encoderSession.inputNames()

                    
                    // 修正输入名称
                    var encoderInputs: [String: ORTValue] = [:]
                    for name in inputNames {
                        if name.contains("input_id") {
                            encoderInputs[name] = inputIdsTensor
                            print("🔍 ONNX: 将inputIdsTensor分配给输入'\(name)'")
                        } else if name.contains("attention") || name.contains("mask") {
                            encoderInputs[name] = attentionMaskTensor
                            print("🔍 ONNX: 将attentionMaskTensor分配给输入'\(name)'")
                        }
                    }
                    
                    if encoderInputs.isEmpty {
                        // 使用原始名称
                        encoderInputs = [
                            "input_ids": inputIdsTensor,
                            "attention_mask": attentionMaskTensor
                        ]
                        print("🔍 ONNX: 使用默认输入名称")
                    }
                    
                    // 运行时添加更多错误处理
                    let outputNames = try encoderSession.outputNames()
                    // 尝试运行模型
                    print("🔍 ONNX: 开始运行编码器...")
                    let encoderOutputs = try encoderSession.run(
                        withInputs: encoderInputs, 
                        outputNames: Set(outputNames),
                        runOptions: nil
                    )
                    print("🔍 ONNX: 编码器运行成功，输出: \(encoderOutputs.keys)")
                    
                    // 获取编码器的输出
                    guard let encoderHiddenStates = encoderOutputs["last_hidden_state"] else {
                        print("🔍 ONNX: ❌ 错误: 找不到编码器输出 'encoder_hidden_states'")
                        print("🔍 ONNX: 可用输出: \(encoderOutputs.keys)")
                        throw ONNXModelError.modelInferenceError
                    }
    
                    // 继续解码阶段...
                    print("🔍 ONNX: 开始解码阶段")
                    
                    // 使用嵌套数组表示[batch_size=1, seq_len=1]的结构
                    var decoderInputIds = [[Int64(generationConfig.decoderStartTokenId)]]
                    var generatedTokens = [Int32]()
                    
                    print("🔍 ONNX: 初始解码器输入IDs: \(decoderInputIds)")
                    
                    // 生成循环
                    for i in 0..<generationConfig.maxLength {
                        print("🔍 ONNX: 解码步骤 \(i+1)")
                        
                        // 从二维数组中获取当前序列
                        let currentSequence = decoderInputIds[0]
                        
                        // 创建解码器输入张量
                        let decoderInputShape: [NSNumber] = [1, NSNumber(value: currentSequence.count)]
                        
                        // 创建NSMutableData
                        let decoderInputData = NSMutableData(bytes: currentSequence, 
                                                            length: currentSequence.count * MemoryLayout<Int64>.size)
                        
                        // 将NSMutableData转换为ORTValue
                        guard let decoderInputTensor = try? ORTValue(
                            tensorData: decoderInputData,
                            elementType: ORTTensorElementDataType.int64,
                            shape: decoderInputShape
                        ) else {
                            print("🔍 ONNX: ❌ 错误: 无法创建decoderInputTensor")
                            throw ONNXModelError.inputProcessingError
                        }
                        
                        // 设置解码器输入 - 确保与Python版本输入一致
                        let decoderInputs: [String: ORTValue] = [
                            "input_ids": decoderInputTensor, // 使用ORTValue而不是NSMutableData
                            "encoder_hidden_states": encoderHiddenStates,
                            "encoder_attention_mask": attentionMaskTensor
                        ]
                        
                        // 运行解码器
                        do {
                            let decoderOutputs = try decoderSession.run(
                                withInputs: decoderInputs,
                                outputNames: Set(["logits"]),
                                runOptions: nil)
                            
                            guard let logits = decoderOutputs["logits"] else {
                                print("🔍 ONNX: ❌ 错误: 找不到解码器输出 'logits'")
                                throw ONNXModelError.modelInferenceError
                            }
                            
                            // 处理logits - 修改为与Python版本一致
                            do {
                                let logitsData = try logits.tensorData() as Data
                                let logitsBuffer = logitsData.withUnsafeBytes { $0.bindMemory(to: Float.self) }
                                
                                // 获取logits形状信息
                                guard let logitsShape = try? logits.tensorTypeAndShapeInfo().shape,
                                      logitsShape.count == 3 else {
                                    print("🔍 ONNX: ❌ 错误: 无效的logits形状")
                                    throw ONNXModelError.invalidOutputShape
                                }
                                
                                // batch_size, seq_len, vocab_size
                                //print("🔍 ONNX: logits形状: \(logitsShape)")
                                
                                // 计算最后一个token的logits - 关键修复
                                let batchSize = Int(logitsShape[0].intValue)
                                let seqLen = Int(logitsShape[1].intValue)
                                let vocabSize = Int(logitsShape[2].intValue)
                                
                                // 取最后一个位置的logits，对应Python中的logits[0, -1, :]
                                let lastTokenIdx = seqLen - 1
                                var nextTokenLogits = [Float]()
                                
                                // 计算最后一个token的起始偏移量
                                let startOffset = (0 * seqLen + lastTokenIdx) * vocabSize
                                
                                // 提取最后一个token的所有logits (所有vocab_size个值)
                                for i in 0..<vocabSize {
                                    let idx = startOffset + i
                                    if idx < logitsBuffer.count {
                                        nextTokenLogits.append(logitsBuffer[idx])
                                    } else {
                                        print("🔍 ONNX: ❌ 错误: 访问logitsBuffer越界")
                                        throw ONNXModelError.invalidOutputShape
                                    }
                                }
                                
                                // 应用softmax
                                let maxLogit = nextTokenLogits.max() ?? 0
                                let expLogits = nextTokenLogits.map { exp($0 - maxLogit) }
                                let sumExp = expLogits.reduce(0, +)
                                if sumExp.isZero || sumExp.isNaN {
                                    print("🔍 ONNX: ❌ 警告: softmax计算问题，sumExp=\(sumExp)")
                                    continue // 跳过此轮
                                }
                                
                                let probs = expLogits.map { $0 / sumExp }
                                
                                // 应用采样策略，与Python版本一致
                                let filteredProbs = topPSampling(probs: probs, topP: generationConfig.topP)
                                let sampledId = temperatureSampling(
                                    probs: filteredProbs,
                                    temperature: generationConfig.temperature
                                )
                                
                                print("🔍 ONNX: 采样结果: \(sampledId)")
                                print("🔍 ONNX: 更新后的解码器输入IDs: \(decoderInputIds)")
                                // 终止条件判断
                                if sampledId == Int(generationConfig.eosTokenId) {
                                    print("🔍 ONNX: 遇到EOS token，停止生成")
                                    break
                                }
                                
                                // 采样获得新token后，更新decoderInputIds
                                // 将新token添加到序列中 - 保持二维结构
                                decoderInputIds[0].append(Int64(sampledId))
                                generatedTokens.append(Int32(sampledId))
                                
                                
                                
                            } catch {
                                print("🔍 ONNX: ❌ 处理logits时出错: \(error)")
                                throw error
                            }
                        } catch {
                            print("🔍 ONNX: ❌ 运行解码器时出错: \(error)")
                            throw error
                        }
                    }
                    
                    // 4. 解码生成结果
                    print("🔍 ONNX: 生成完成，解码结果")
                    let decodedText: String
                    do {
                        decodedText = try tokenizer.decode(tokens: generatedTokens)
                        print("🔍 ONNX: 解码成功，长度: \(decodedText.count)字符")
                    } catch {
                        print("🔍 ONNX: ❌ 解码tokens时出错: \(error)")
                        throw error
                    }
                    
                    let abcNotation = "X:1\n" + decodedText
                        .replacingOccurrences(of: "<pad>", with: "")
                        .replacingOccurrences(of: "<s>", with: "")
                        .replacingOccurrences(of: "</s>", with: "")
                    
                    // 清理ABC记谱法
                    let cleanedNotation = cleanABCNotation(abcNotation)
                    
                    print("🔍 ONNX: 返回最终结果，长度: \(cleanedNotation.count)字符")
                    print(cleanedNotation)
                    return cleanedNotation
                    
                } catch {
                    print("🔍 ONNX: ❌ 准备或运行编码器时出错: \(error)")
                    throw error
                }
            } catch {
                print("🔍 ONNX: ❌ 创建张量时出错: \(error)")
                throw error
            }
        } catch {
            print("🔍 ONNX: ❌ 处理输入时出错: \(error)")
            throw error
        }
    }
    
    // temperature sampling方法
    private func temperatureSampling(probs: [Float], temperature: Float) -> Int {
        let scaledProbs = probs.map { powf($0, 1.0 / temperature) }
        let sum = scaledProbs.reduce(0, +)
        let normalizedProbs = scaledProbs.map { $0 / sum }
        
        let randomValue = Float.random(in: 0..<1)
        var cumulative: Float = 0.0
        for (i, prob) in normalizedProbs.enumerated() {
            cumulative += prob
            if cumulative >= randomValue {
                return i
            }
        }
        return normalizedProbs.indices.last!
    }
    
    // 改进的topP采样函数，更接近Python实现
    private func topPSampling(probs: [Float], topP: Float) -> [Float] {
        // 边界条件处理：如果topP >= 1，直接返回原始概率
        if topP >= 1.0 {
            return probs
        }
        
        // 排序索引，从高到低
        let sortedIndices = probs.indices.sorted { probs[$0] > probs[$1] }
        var cumulative: Float = 0.0
        var selectedIndices = [Int]()
        
        // 选择累积概率不超过topP的最高概率token
        for i in sortedIndices {
            cumulative += probs[i]
            selectedIndices.append(i)
            if cumulative >= topP {
                break
            }
        }
        
        // 过滤概率
        var filteredProbs = probs
        for i in 0..<filteredProbs.count {
            if !selectedIndices.contains(i) {
                filteredProbs[i] = 0.0
            }
        }
        
        // 重新归一化概率分布
        let sum = filteredProbs.reduce(0, +)
        if sum > 0 && abs(sum - 1.0) > 1e-6 {
            for i in 0..<filteredProbs.count {
                filteredProbs[i] /= sum
            }
        }
        
        return filteredProbs
    }
    
    // 添加日志方法
    private func log(_ message: String) {
        if debugMode {
            print("🔍 ONNX: \(message)")
        }
    }
    
    // 清理ABC记谱法，删除非法字符
    private func cleanABCNotation(_ input: String) -> String {
        // 定义允许的字符集
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789|/:[]()=_,.~'\"-<>^ \n\t")
        
        // 创建一个可变字符串
        var cleanedString = ""
        
        // 遍历每个字符，仅保留允许的字符
        for char in input {
            let unicodeScalars = String(char).unicodeScalars
            let isAllowed = unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
            if isAllowed {
                cleanedString.append(char)
            }
        }
        
        return cleanedString
    }
}


