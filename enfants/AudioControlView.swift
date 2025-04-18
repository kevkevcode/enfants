import SwiftUI
import AVFoundation

struct AudioControlView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        VStack {
            if let audioData = viewModel.audioData {
                // Barre de progression
                Slider(
                    value: $viewModel.progress,
                    in: 0...1,
                    step: 0.01,
                    onEditingChanged: { editing in
                        if !editing {
                            ElevenLabsService.shared.seekToPercentage(viewModel.progress)
                        }
                    }
                )
                .tint(.blue)
                
                // Temps écoulé et durée totale
                HStack {
                    Text(formatTime(viewModel.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formatTime(viewModel.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Contrôles de lecture
                HStack(spacing: 20) {
                    Button(action: {
                        ElevenLabsService.shared.skipBackward()
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        viewModel.toggleAudio()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.primaryPurple)
                    }
                    
                    Button(action: {
                        ElevenLabsService.shared.skipForward()
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioControlView(viewModel: AudioViewModel())
} 