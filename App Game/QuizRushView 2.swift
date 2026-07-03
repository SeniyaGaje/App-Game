import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushViewModel()
    @State private var shake: CGFloat = 0

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

            VStack(spacing: 20) {
                header

                Spacer(minLength: 0)

                stateContent
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if case .idle = vm.state {
                Task { await vm.load() }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Quiz Rush")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Open Trivia DB")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(vm.progressText)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Score \(vm.score)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Streak \(vm.streak)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch vm.state {
        case .idle, .loading:
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text("Loading 10 trivia questions…")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Connecting to Open Trivia DB")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

        case .failed(let message):
            VStack(spacing: 16) {
                Text("Could not load quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await vm.retry() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))

        case .loaded:
            if let question = vm.currentQuestion() {
                VStack(spacing: 20) {
                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    let answers = question.answersShuffled

                    VStack(spacing: 12) {
                        ForEach(answers, id: \.self) { answer in
                            let isSelected = vm.selectedAnswer == answer
                            let isCorrect = vm.revealedCorrectAnswer == answer
                            let isWrongSelection = isSelected && vm.answerFeedback == .incorrect

                            Button {
                                if vm.isAnswerLocked { return }
                                withAnimation(.spring()) { vm.answer(answer) }
                                if vm.answerFeedback == .incorrect {
                                    withAnimation(.default) { shake = 10 }
                                    withAnimation(.easeOut(duration: 0.3).delay(0.3)) { shake = 0 }
                                }
                            } label: {
                                Text(answer)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(answerBackgroundColor(isSelected: isSelected, isCorrect: isCorrect))
                                    )
                            }
                            .disabled(vm.isAnswerLocked)
                            .offset(x: isWrongSelection ? shake : 0)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            }

        case .finished:
            VStack(spacing: 18) {
                Text("Quiz Finished!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Summary")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                Text(vm.summaryText)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(.yellow)
                Text("Score: \(vm.score)")
                    .font(.headline)
                    .foregroundColor(.white)
                Button("Play Again") {
                    Task { await vm.load() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    private func answerBackgroundColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if vm.isAnswerLocked {
            if isCorrect {
                return Color.green.opacity(0.9)
            }

            if isSelected {
                return Color.red.opacity(0.9)
            }
        }

        return Color.orange.opacity(0.88)
    }
}

#if DEBUG
struct QuizRushView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { QuizRushView() }
    }
}
#endif
