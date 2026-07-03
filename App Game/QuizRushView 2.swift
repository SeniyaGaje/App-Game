import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushViewModel()
    @State private var answerFeedback: AnswerFeedback = .none
    @State private var shake: CGFloat = 0

    enum AnswerFeedback {
        case none
        case correct
        case incorrect
    }

    var body: some View {
        NavigationView {
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

                // AnimatedStars() can be placed here if available
                // AnimatedStars()

                VStack(spacing: 16) {
                    switch vm.state {
                    case .idle:
                        EmptyView()
                            .onAppear {
                                Task {
                                    await vm.load()
                                }
                            }
                    case .loading:
                        ProgressView("Loading trivia…")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                    case .failed(let message):
                        VStack(spacing: 16) {
                            Text(message)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                Task {
                                    await vm.retry()
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

                                Text("Progress: \(vm.progressText)")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                Text("Streak: \(vm.streak)")
                                    .foregroundColor(.white)
                                    .font(.subheadline)

                                let answers = question.decodedAnswers().shuffled()

                                VStack(spacing: 12) {
                                    ForEach(answers, id: \.self) { answer in
                                        Button {
                                            withAnimation(.spring()) {
                                                vm.answer(answer)
                                                if let correct = vm.lastAnswerWasCorrect {
                                                    answerFeedback = correct ? .correct : .incorrect
                                                    if !correct {
                                                        withAnimation(.default) {
                                                            shake = 10
                                                        }
                                                        withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                                                            shake = 0
                                                        }
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                        withAnimation {
                                                            answerFeedback = .none
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
                                                        .fill(buttonBackgroundColor(for: answer))
                                                )
                                        }
                                        .disabled(vm.lastAnswerWasCorrect != nil)
                                        .offset(x: answerFeedback == .incorrect && vm.lastAnswerWasCorrect == false ? shake : 0)
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
                                Task {
                                    vm.restart()
                                    await vm.load()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Quiz Rush")
        }
    }

    private func buttonBackgroundColor(for answer: String) -> Color {
        if let correctAnswer = vm.currentQuestion?.decodedCorrectAnswer() {
            if vm.lastAnswerWasCorrect != nil {
                if answer == correctAnswer {
                    return Color.green.opacity(0.8)
                } else if answerFeedback == .incorrect && vm.lastSelectedAnswer == answer {
                    return Color.red.opacity(0.8)
                }
            }
        }
        return Color.orange.opacity(0.8)
    }
}

#if DEBUG
struct QuizRushView_Previews: PreviewProvider {
    static var previews: some View {
        QuizRushView()
    }
}
#endif
