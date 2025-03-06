import SwiftUI
import CoreML

struct MLTestView: View {
    @State private var inputText: String = ""
    @State private var outputResult: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 属性初始化器无法抛出错误 所以不能直接在属性中初始化
    // 初始化函数在下面 onAppear处
    @State private var onnxService: ONNXMusicService?
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("ML Model Test")
                .font(.title)
                .padding()
            
            // Input Section
            VStack(alignment: .leading) {
                Text("Input Text:")
                    .font(.headline)
                
                ZStack(alignment: .topTrailing) {
                    TextEditor(text: $inputText)
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                    
                    Button(action: pasteFromClipboard) {
                        Image(systemName: "doc.on.clipboard")
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
                .padding(.bottom)
                
                // 可选：添加清除按钮
                HStack {
                    Button("清除") {
                        inputText = ""
                    }
                    .disabled(inputText.isEmpty)
                    
                    Spacer()
                    
                    Text("\(inputText.count) 字符")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Test Button
            Button(action: testModel) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Test Model")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .disabled(inputText.isEmpty || isLoading || onnxService == nil)
            
            // Output Section
            VStack(alignment: .leading) {
                Text("Model Output:")
                    .font(.headline)
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text(outputResult)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            initializeService()
        }
    }
    
    private func initializeService() {
        do {
            self.onnxService = try ONNXMusicService()
        } catch {
            self.errorMessage = "无法初始化ONNX服务: \(error.localizedDescription)"
        }
    }
    
    private func testModel() {
        print("⚠️ 按钮被点击 - 开始测试")
        
        guard let onnxService = onnxService else {
            errorMessage = "ONNX服务未初始化"
            print("❌ ONNX服务未初始化")
            return
        }
        print("✅ ONNX服务已初始化")
        
        isLoading = true
        errorMessage = nil
        
        print("🔄 开始异步任务...")
        
        Task {
            do {
                print("🔍 在Task内部，准备调用generateMusic...")
                let output = try await onnxService.generateMusic(from: inputText)
                print("✅ 音乐生成成功!")
                await MainActor.run {
                    outputResult = output 
                    isLoading = false
                }
            } catch {
                print("❌ 音乐生成错误: \(error)")
                await MainActor.run {
                    errorMessage = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
        
        print("✅ 按钮点击处理完成，异步任务已开始")
    }
    
    private func formatMLOutput(_ output: MLMultiArray) -> String {
        // 将 MLMultiArray 转换为可读格式
        var result = "Shape: \(output.shape)\n"
        result += "Datatype: \(output.dataType)\n"
        result += "First few values:\n"
        
        // 显示前10个值作为示例
        for i in 0..<min(10, output.count) {
            if let value = try? output[i].doubleValue {
                result += String(format: "[%d]: %.4f\n", i, value)
            }
        }
        
        return result
    }
    
    private func pasteFromClipboard() {
        if let pasteboardString = UIPasteboard.general.string {
            inputText = pasteboardString
            print("从剪贴板粘贴了 \(pasteboardString.count) 个字符")
        } else {
            print("剪贴板中没有文本内容")
        }
    }
}

#Preview {
    MLTestView()
} 
