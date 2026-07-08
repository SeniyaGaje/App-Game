import SwiftUI

struct QuizRushView: View {
    @StateObject private var vm = QuizRushViewModel()
    @State private var shake: CGFloat = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.05, blue: 0.11),
                    Color.orange.opacity(0.38),
                    Color.red.opacity(0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.orange.opacity(0.16))
                .frame(width: 220, height: 220)
                .blur(radius: 42)
                .offset(x: 140, y: -250)

            Circle()
                .fill(Color.red.opacity(0.10))
                .frame(width: 200, height: 200)
                .blur(radius: 44)
                .offset(x: -140, y: 300)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header

                    stateContent
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Quiz Rush")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            if case .idle = vm.state {
                Task { await vm.load() }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quiz Rush")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("Answer quickly, keep your streak alive.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.78))

            HStack(spacing: 12) {
                StatBlock(title: "Progress", value: vm.progressText)
                StatBlock(title: "Score", value: "\(vm.score)")
                StatBlock(title: "Streak", value: "\(vm.streak)")
            }
        }
        .padding(20)
        .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var stateContent: some View {
        switch vm.state {
        case .idle, .loading:
            VStack(spacing: 16) {
                ProgressView()
                    .tint(.orange)
                    .scaleEffect(1.3)
                Text("Loading trivia questions…")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Connecting to Open Trivia DB")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

        case .failed(let message):
            VStack(spacing: 16) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
                Text("Could not load quiz")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                Button("Retry") {
                    Task { await vm.retry() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

        case .loaded:
            if let question = vm.currentQuestion() {
                VStack(spacing: 20) {
                    // Question
                    Text(question.question)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)

                    let answers = question.answersShuffled

                    VStack(spacing: 10) {
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
                                HStack {
                                    Text(answer)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(answerForegroundColor(isSelected: isSelected, isCorrect: isCorrect))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if vm.isAnswerLocked {
                                        if isCorrect {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        } else if isSelected {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(answerBackground(isSelected: isSelected, isCorrect: isCorrect))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(answerBorderColor(isSelected: isSelected, isCorrect: isCorrect), lineWidth: 1.5)
                                )
                            }
                            .disabled(vm.isAnswerLocked)
                            .offset(x: isWrongSelection ? shake : 0)
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
            }

        case .finished:
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )
                    .shadow(color: .orange.opacity(0.5), radius: 10)

                Text("Quiz Finished!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text(vm.summaryText)
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                    )

                Text("Score: \(vm.score)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.85))

                Button("Play Again") {
                    Task { await vm.load() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.10, green: 0.12, blue: 0.22), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    // Answer button helpers — dark backgrounds so text always readable

    @ViewBuilder
    private func answerBackground(isSelected: Bool, isCorrect: Bool) -> some View {
        if vm.isAnswerLocked {
            if isCorrect {
                Color.green.opacity(0.25)
            } else if isSelected {
                Color.red.opacity(0.25)
            } else {
                Color.white.opacity(0.06)
            }
        } else {
            Color.white.opacity(0.08)
        }
    }

    private func answerForegroundColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if vm.isAnswerLocked {
            if isCorrect { return .green }
            if isSelected { return .red }
        }
        return .white
    }

    private func answerBorderColor(isSelected: Bool, isCorrect: Bool) -> Color {
        if vm.isAnswerLocked {
            if isCorrect { return .green.opacity(0.7) }
            if isSelected { return .red.opacity(0.6) }
            return .white.opacity(0.08)
        }
        return isSelected ? Color.orange.opacity(0.7) : Color.white.opacity(0.1)
    }
}

#if DEBUG
struct QuizRushView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { QuizRushView() }
    }
}
#endif
