# 🌊 Blocs Wave Pro for iOS (Swift & SwiftUI)

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/Swift-5.9%20%2F%206.0-orange.svg)](https://swift.org)
[![Audio](https://img.shields.io/badge/Audio-AVFoundation%20%7C%20Accelerate%2FvDSP-green.svg)](https://developer.apple.com/documentation/avfoundation)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20%40Observable-purple.svg)](https://developer.apple.com/documentation/observation)

**Blocs Wave Pro** là ứng dụng live looping, sáng tác nhạc điện tử và thu âm chuyên nghiệp trên iOS (lấy cảm hứng từ Blocs Wave của Ampify Music / Focusrite).

Mã nguồn đầy đủ nằm trong thư mục: [`BlocsWavePro/`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/)

---

## 🗂 Cấu Trúc Dự Án (Project Architecture)

- **Xcode Project**: [`BlocsWavePro/BlocsWavePro.xcodeproj`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro.xcodeproj)
- **Swift Package**: [`BlocsWavePro/Package.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/Package.swift)
- **Audio Engine**:
  - [`AudioEngineController.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioEngineController.swift): Master AVAudioEngine coordinator, metronome, tap tempo, clock sync.
  - [`AudioTrackNode.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioTrackNode.swift): Signal chain độc lập (Player ➡️ TimePitch ➡️ EQ ➡️ Mixer), slice mode, tempo stretching & key transposition.
  - [`AudioSessionManager.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioSessionManager.swift): Cấu hình 5ms low-latency buffer, microphone permission.
  - [`WaveformExtractor.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/WaveformExtractor.swift): Trích xuất đỉnh biên độ bằng Accelerate/vDSP.
  - [`AudioRecorder.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioRecorder.swift): Thu âm micro lượng tử hóa theo Bar.
  - [`AudioExporter.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioExporter.swift): Render Master Mixdown & 8 Stems chuẩn WAV 44.1kHz 16-bit.
  - [`AudioProceduralGenerator.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/AudioEngine/AudioProceduralGenerator.swift): Sinh mã 8 loop âm thanh nhạc cụ chân thực (Kick, Snare, Hats, Bass, Chords, Lead, Pluck, Vocal FX) sẵn sàng chơi ngay.
- **Models**:
  - [`TrackModel.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/TrackModel.swift)
  - [`MusicalKey.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/MusicalKey.swift)
  - [`EQSettings.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/EQSettings.swift)
  - [`SliceState.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/SliceState.swift)
  - [`SongSection.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/SongSection.swift)
  - [`ProjectState.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Models/ProjectState.swift)
- **ViewModel**:
  - [`MainLooperViewModel.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/ViewModels/MainLooperViewModel.swift) với Swift `@Observable` macro và 60 FPS playhead clock.
- **Views & UI**:
  - [`MainView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/MainView.swift)
  - [`TouchableWaveformCanvas.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Waveforms/TouchableWaveformCanvas.swift): SwiftUI Canvas với playhead 60fps mượt mà, touch scrubber và 8-slice overlays.
  - [`TrackRowView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/TrackControls/TrackRowView.swift)
  - [`TrackDetailSheet.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/TrackControls/TrackDetailSheet.swift) & [`ParametricEQView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/TrackControls/ParametricEQView.swift)
  - [`TopBarView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Header/TopBarView.swift) & [`TapTempoButton.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Header/TapTempoButton.swift)
  - [`MasterKeyPickerSheet.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Header/MasterKeyPickerSheet.swift)
  - [`RecordTrackModal.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Recording/RecordTrackModal.swift) & [`InputLevelMeterView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Recording/InputLevelMeterView.swift)
  - [`ExportDialogView.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Export/ExportDialogView.swift) & [`ShareSheet.swift`](file:///c:/Users/ASUS/Downloads/ios-appmusicpro/BlocsWavePro/BlocsWavePro/Views/Export/ShareSheet.swift)
