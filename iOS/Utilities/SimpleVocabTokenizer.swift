import Foundation

/// 一个简单的自定义 Tokenizer 实现，试图模拟原始模型的tokenizer行为
class SimpleVocabTokenizer {
    // 词汇表：从tokens到ids的映射
    private var vocab: [String: Int] = [:]
    // 反向映射：从ids到tokens的映射
    private var reverseVocab: [Int: String] = [:]
    
    // 特殊标记
    private let padToken = "<pad>"
    private let unkToken = "<unk>"
    private let startToken = "<s>"
    private let endToken = "</s>"
    
    /// 从词汇表文件初始化
    /// - Parameter vocabPath: 词汇表JSON文件路径
    init(vocabPath: URL) throws {
        let vocabData = try Data(contentsOf: vocabPath)
        
        // 尝试解析JSON格式的词汇表
        if let jsonDict = try JSONSerialization.jsonObject(with: vocabData) as? [String: Any],
           let modelDict = jsonDict["model"] as? [String: Any],
           let vocabDict = modelDict["vocab"] as? [String: Int] {
            // 处理嵌套结构 - vocab.json 中可能是 { "model": { "vocab": {...} } }
            self.vocab = vocabDict
            
            // 创建反向映射
            for (token, id) in vocabDict {
                reverseVocab[id] = token
            }
        } else if let vocabDict = try JSONSerialization.jsonObject(with: vocabData) as? [String: Int] {
            self.vocab = vocabDict
            
            // 创建反向映射
            for (token, id) in vocabDict {
                reverseVocab[id] = token
            }
        }
        
        print("已加载词汇表，包含 \(vocab.count) 个单词")
    }
    
    /// 将文本转换为token IDs，使用更复杂的分词策略
    /// - Parameter text: 输入文本
    /// - Returns: token ID数组
    func encode(_ text: String) -> [Int] {
        // 先添加开始标记
        var tokens = [Int]()
        if let id = vocab[startToken] {
            tokens.append(id)
        } else {
            tokens.append(0) // 默认为0
        }
        
        // 字节级处理，类似于BPE tokenizer的预处理
        // 将文本拆分为Unicode标量
        let unicodeScalars = text.unicodeScalars
        var currentToken = ""
        
        for scalar in unicodeScalars {
            // 处理空格 - 添加Ġ前缀（\u0120）
            if scalar == " " {
                if !currentToken.isEmpty {
                    addTokenToList(currentToken, to: &tokens)
                    currentToken = ""
                }
                currentToken = "\u{0120}" // 添加特殊前缀表示空格
            } else if isPunctuation(scalar) {
                // 标点符号单独处理
                if !currentToken.isEmpty {
                    addTokenToList(currentToken, to: &tokens)
                    currentToken = ""
                }
                
                // 直接查找标点符号
                let punctuation = String(scalar)
                addTokenToList(punctuation, to: &tokens)
            } else {
                // 其他字符直接加到当前token
                currentToken.append(Character(scalar))
            }
        }
        
        // 处理最后一个token
        if !currentToken.isEmpty {
            addTokenToList(currentToken, to: &tokens)
        }
        
        // 添加结束标记
        if let id = vocab[endToken] {
            tokens.append(id)
        } else {
            tokens.append(2) // 默认为2
        }
        
        return tokens
    }
    
    /// 将token添加到列表中
    private func addTokenToList(_ token: String, to tokens: inout [Int]) {
        if let id = vocab[token] {
            tokens.append(id)
        } else {
            // 尝试使用前缀匹配
            var found = false
            
            // 遍历词汇表查找最长匹配
            var currentString = token
            while !currentString.isEmpty {
                if let id = vocab[currentString] {
                    tokens.append(id)
                    
                    // 处理余下部分
                    let remainingOffset = currentString.count
                    if remainingOffset < token.count {
                        let remaining = String(token[token.index(token.startIndex, offsetBy: remainingOffset)...])
                        if !remaining.isEmpty {
                            addTokenToList(remaining, to: &tokens)
                        }
                    }
                    
                    found = true
                    break
                }
                // 移除最后一个字符，尝试更短的子串
                currentString = String(currentString.dropLast())
            }
            
            // 如果没有找到匹配，则使用unk token
            if !found {
                if let unkId = vocab[unkToken] {
                    tokens.append(unkId)
                } else {
                    tokens.append(3) // 默认unk token ID
                }
            }
        }
    }
    
    /// 检查是否为标点符号
    private func isPunctuation(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.punctuationCharacters.contains(scalar)
    }
    
    /// 将token IDs转换回文本
    /// - Parameter tokens: token ID数组
    /// - Returns: 解码后的文本
    func decode(tokens: [Int]) -> String {
        var result = ""
        
        for token in tokens {
            if let word = reverseVocab[token] {
                // 移除特殊前缀\u{0120}（表示前面有空格）
                if word.hasPrefix("\u{0120}") {
                    let index = word.index(word.startIndex, offsetBy: 1)
                    result += " " + String(word[index...])
                } else if word != startToken && word != endToken && word != padToken {
                    result += word
                }
            }
        }
        
        return result
    }
    
    /// 提供类似函数调用的语法糖
    /// - Parameter text: 输入文本
    /// - Returns: token ID数组
    func callAsFunction(_ text: String) -> [Int] {
        return encode(text)
    }
    
    /// 获取词汇表大小
    var vocabularySize: Int {
        return vocab.count
    }
    
    /// 获取特殊token的ID
    var padTokenId: Int? {
        return vocab[padToken]
    }
    
    var unkTokenId: Int? {
        return vocab[unkToken]
    }
    
    var startTokenId: Int? {
        return vocab[startToken]
    }
    
    var endTokenId: Int? {
        return vocab[endToken]
    }
}
