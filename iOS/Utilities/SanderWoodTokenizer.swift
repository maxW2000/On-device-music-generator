//
//  SanderWoodTokenizer.swift
//  ondevicetext2music
//
//  Created by Max Fr on 3/6/25.
//

import Foundation
import CoreML

public class SanderWoodTokenizer {
    struct TokenizerConfig{
        let eosTokenId: Int32
        let padTokenId: Int32
        let decoderStartTokenId: Int32
    }
    
    private var tokenizer: SimpleVocabTokenizer?
    private var tokenizerConfig: TokenizerConfig!
    
    // MARK: Init
    public init() {
        do{
            guard let tokenizerDirURL = Bundle.main.url(forResource: "model_config", withExtension: nil)
            else {
                throw NSError(domain: "TokenizerURLError", code: 404, userInfo: nil)
            }
            
            let vocabPath = tokenizerDirURL.appendingPathComponent("vocab.json")
            
            self.tokenizer = try SimpleVocabTokenizer(vocabPath: vocabPath)
            print("✅ Successfully loaded tokenzier")
            
            // config config
            self.tokenizerConfig = TokenizerConfig(
                eosTokenId: 2,   // </s> token ID
                padTokenId: 1,   // <pad> token ID
                decoderStartTokenId: 2  // 从0修改为2，与原模型配置中的decoder_start_token_id匹配
            )
        }
        catch{
            print("❌ Failed to initialize tokenizer: \(error)")
        }
    }
    
    // MARK: - tokenize
    public func tokenize(text: String) throws -> (MLMultiArray, MLMultiArray) {
        print("🔤 SanderWoodTokenizer: 开始tokenize文本: \(text)")
        
        guard let tokenizer = tokenizer else {
            print("🔤 SanderWoodTokenizer: ❌ 错误: tokenizer未初始化")
            throw MLServiceError.tokenizerNotInitialized
        }
        
        // 使用新的tokenizer编码
        print("🔤 SanderWoodTokenizer: 使用SimpleVocabTokenizer编码")
        let tokens = tokenizer.encode(text)
        print("🔤 SanderWoodTokenizer: 编码完成，得到\(tokens.count)个token")
        
        // padding token (0)
        // token出来的自己就带一个(1)
        let tokensArray = tokens.map { NSNumber(value: $0) }
        let length = tokens.count
        
        // 确保长度不为0
        if length == 0 {
            print("🔤 SanderWoodTokenizer: ⚠️ 警告: token长度为0")
        }
        
        print("🔤 SanderWoodTokenizer: 创建MLMultiArray，形状: [1, \(length)]")
        
        // 使用安全的方式创建MLMultiArray
        let inputIds: MLMultiArray
        let attentionMask: MLMultiArray
        
        do {
            // 尝试创建input_ids
            inputIds = try MLMultiArray(shape: [1, NSNumber(value: length)], dataType: .int32)
            print("🔤 SanderWoodTokenizer: 成功创建inputIds MLMultiArray")
            // 尝试创建attention_mask
            attentionMask = try MLMultiArray(shape: [1, NSNumber(value: length)], dataType: .int32)
            print("🔤 SanderWoodTokenizer: 成功创建attentionMask MLMultiArray")
        } catch {
            print("🔤 SanderWoodTokenizer: ❌ 创建MLMultiArray失败: \(error)")
            throw error
        }
        
        // 填充 input_ids 和 attention_mask
        print("🔤 SanderWoodTokenizer: 填充MLMultiArray")
        for i in 0..<length {
            do {
                let index = i
                inputIds[index] = tokensArray[i]
                // 只有 padding token (0) 对应的 attention mask 为 0
                attentionMask[index] = tokens[i] == 0 ? 0 : 1
            } catch {
                print("🔤 SanderWoodTokenizer: ❌ 访问MLMultiArray索引\(i)失败: \(error)")
                throw error
            }
        }
        // 强制设置成1
        attentionMask[0] = 1
        print(inputIds)
        print(attentionMask)
        print("🔤 SanderWoodTokenizer: 成功填充MLMultiArray")
        return (inputIds, attentionMask)
    }
    
    // MARK: - decode
    public func decode(tokens: [Int32]) throws -> String {
        guard let tokenizer = tokenizer else {
            throw MLServiceError.tokenizerNotInitialized
        }
        
        return tokenizer.decode(tokens: tokens.map { Int($0) })
    }
}
