import SwiftUI
// need to import FoundationModels in order to access PCC
import FoundationModels
import Foundation

// getting more structured tools works the same with on-device and server models using @Generable. this allows you to switch between models without re-writing code
@Generable
struct ArticleSummary: Codable {
    let oneLineSummary: String
    let keyPoints: [String]
}



struct FindRelatedArticlesTool: Tool {
    // properties for using this tool would go here
}

struct ArticleSummarizationView: View {
    @State private var summary: String = ""
    private var model = PrivateCloudComputeLanguageModel()
    var article: String = ""
    // adding 'model: PrivateCloudComputeLanguageModel()' is the only thing different from using on-device Foundation model, gives user access to much larger server model with larger context and more complex reasoning capabilities
    let session = LanguageModelSession(
        model: PrivateCloudComputeLanguageModel(),
        tools: [FindRelatedArticlesTool()]
    )
    
    var body: some View {
        
        // important to check if device has Apple Intelligence capability and handle instances when it doesn't
        if model.isAvailable {
            // show UI for making request
        } else {
            // fall back
        }
        
        // can check to see if user's quota has been reached for usage
        if model.quotaUsage.isLimitReached {
            Text("Usage limit exceeded.")
                .foregroundStyle(Color.red)
        }
        
        // if limit has been exceeded you can give them an option to increase limit by upgrading account
        if let suggestion = model.quotaUsage.limitIncreaseSuggestion {
            Button("Show Optiosn") {
                suggestion.show()
            }
        }
        Text(summary.isEmpty ? "Loading..." : summary)
            .task {
                do {
                    // using PCC to create a response
                    let response = try await session.respond(
                        to: "Summarize this article: \(article)",
                        generating: ArticleSummary.self,
                        // can set reasoning level for response
                        contextOptions: ContextOptions(reasoningLevel: .light)
                    )
                    self.summary = String(describing: response)
                } catch {
                    self.summary = "Failed to summarize: \(error.localizedDescription)"
                }
            }
    }
}

// Apple added API so you can check the context size for a model
// SystemLanguageModel().contextSize
// 4096
// PrivateCloudComputeLanguageModel().contextSize
// 32768

#Preview {
    ArticleSummarizationView()
}
