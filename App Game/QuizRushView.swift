import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushViewModel()
    @AppStorage("quizRushHighScore") private var highScore: Int = 0
    
    @State private var answerFeedback: AnswerFeedback = .none
    
    enum AnswerFeedback {
        case none
        case correct
        case incorrect
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.orange.opacity(0.5),
                    Color.red.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // If AnimatedStars() is available, overlay it here. Omit if not.
            // AnimatedStars()
            
            VStack(spacing: 16) {
                // Top bar
                HStack {
                    Text("Quiz Rush")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Progress: \(vm.progressText)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Text("Score: \(vm.score)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Text("Streak: \(vm.streak)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Group {
                    switch vm.state {
                    case .idle, .loading:
                        ProgressView("Fetching questions...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                    case .failed:
                        VStack(spacing: 16) {
                            Text("Couldn't load questions. Please try again.")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task {
                                    await vm.load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal)
                    case .loaded:
                        if let question = vm.currentQuestion {
                            VStack(spacing: 24) {
                                Text(question.decodedQuestion())
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                let answers = question.decodedAnswers().shuffled()
                                
                                VStack(spacing: 12) {
                                    ForEach(answers, id: \.self) { answer in
                                        Button {
                                            withAnimation(.spring()) {
                                                vm.answerTapped(answer)
                                                if let correct = vm.lastAnswerWasCorrect {
                                                    answerFeedback = correct ? .correct : .incorrect
                                                    if correct {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            withAnimation {
                                                                answerFeedback = .none
                                                            }
                                                        }
                                                    } else {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            withAnimation {
                                                                answerFeedback = .none
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            Text(answer)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .fill(Color.orange.opacity(0.8))
                                                )
                                        }
                                        .overlay(
                                            Group {
                                                if answerFeedback == .correct {
                                                    Color.green.opacity(0.3)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                        .transition(.opacity)
                                                } else if answerFeedback == .incorrect {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(Color.red, lineWidth: 3)
                                                        .modifier(ShakeEffect(shakes: 2))
                                                        .transition(.opacity)
                                                }
                                            }
                                        )
                                        .disabled(vm.lastAnswerWasCorrect != nil)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    case .finished:
                        VStack(spacing: 24) {
                            Text("Quiz Finished!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Your final score:")
                                .font(.title3)
                                .foregroundColor(.white)
                            Text("\(vm.score)")
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundColor(.yellow)
                            Button("Play Again") {
                                vm.restart()
                                Task {
                                    await vm.load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .onAppear {
                            if vm.score > highScore {
                                highScore = vm.score
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .task {
            await vm.load()
        }
    }
}

// Shake effect for incorrect answer feedback
struct ShakeEffect: GeometryEffect {
    var shakes: Int
    var animatableData: CGFloat

    init(shakes: Int) {
        self.shakes = shakes
        self.animatableData = 0
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            8 * sin(animatableData * .pi * CGFloat(shakes)), y: 0))
    }
}

#if DEBUG
struct QuizRushView_Previews: PreviewProvider {
    static var previews: some View {
        QuizRushView()
    }
}
#endif
