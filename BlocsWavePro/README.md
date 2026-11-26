# 🌊 Blocs Wave Pro for iOS (Swift & SwiftUI)

[![Platform](https://img.shields.io/badge/Platform-iOS%2017.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Language](https://img.shields.io/badge/Swift-5.9%20%2F%206.0-orange.svg)](https://swift.org)
[![Audio](https://img.shields.io/badge/Audio-AVFoundation%20%7C%20Accelerate%2FvDSP-green.svg)](https://developer.apple.com/documentation/avfoundation)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20%40Observable-purple.svg)](https://developer.apple.com/documentation/observation)

**Blocs Wave Pro** là ứng dụng live looping, sáng tác nhạc điện tử và thu âm chuyên nghiệp trên iOS (lấy cảm hứng từ Blocs Wave của Ampify Music / Focusrite). Ứng dụng được thiết kế với kiến trúc hiện đại, đồ họa Canvas đa sắc neon (Neon Cyan, Magenta, Purple, Gold) với độ mượt 60 FPS, cùng lõi Audio Engine độ trễ cực thấp (Low-Latency Audio Session) tối ưu cho biểu diễn trực tiếp và sản xuất âm nhạc chuyên nghiệp.

---

## 🗂 Cấu Trúc Dự Án (Project Architecture)

```
BlocsWavePro/
├── BlocsWavePro.xcodeproj/              # Xcode Project (Open directly in Xcode)
│   └── project.pbxproj
├── Package.swift                        # Swift Package Manager manifest (Swift 5.9+)
├── BlocsWavePro/
│   ├── App/
│   │   ├── BlocsWaveProApp.swift        # @main SwiftUI App entry point
│   │   └── Info.plist                   # Microphone permission & background audio mode
│   ├── AudioEngine/                     # Real-time Core Audio Engine
│   │   ├── AudioEngineController.swift  # Master AVAudioEngine coordinator & clock
│   │   ├── AudioTrackNode.swift         # Track chain: Player -> TimePitch -> EQ -> Mixer
│   │   ├── AudioSessionManager.swift    # 5ms low-latency AVAudioSession configuration
│   │   ├── WaveformExtractor.swift      # Accelerate/vDSP peak decimation & normalization
│   │   ├── AudioRecorder.swift          # Live Mic recording with Bar quantization
│   │   ├── AudioExporter.swift          # Master Mixdown & 8 Stems 44.1kHz 16-bit WAV writer
│   │   ├── AudioProceduralGenerator.swift # 8 procedural stereo music loops (Zero dependencies!)
│   │   └── MetronomeGenerator.swift     # High-precision Downbeat & Regular click generator
│   ├── Models/
│   │   ├── TrackModel.swift             # Model track: sample PCM, BPM, Key, peaks, EQ, Slices
│   │   ├── MusicalKey.swift             # 12 chromatic pitches, Major/Minor & pitch harmonization
│   │   ├── EQSettings.swift             # 3-Band Parametric EQ (Low 120Hz, Mid 1kHz, High 7kHz)
│   │   ├── SliceState.swift             # 8-slice boundaries & slice-targeted looping
│   │   ├── SongSection.swift            # Sections A, B, C, D (Intro, Verse, Chorus, Outro)
│   │   └── ProjectState.swift           # Master BPM, Key, Transport, Metronome, Sections
│   ├── ViewModels/
│   │   └── MainLooperViewModel.swift    # iOS 17 @Observable ViewModel with 60 FPS playhead sync
│   ├── Views/
│   │   ├── MainView.swift               # Root view combining header, waveforms & status
│   │   ├── Header/
│   │   │   ├── TopBarView.swift         # Master Transport, BPM, Key, Metronome, Sections
│   │   │   ├── TapTempoButton.swift     # Haptic pulsing Tap Tempo detector
│   │   │   └── MasterKeyPickerSheet.swift # 12 Chromatic pitch selector & scale mode
│   │   ├── Waveforms/
│   │   │   ├── TouchableWaveformCanvas.swift # Custom SwiftUI Canvas with touch scrubber
│   │   │   ├── SliceOverlayView.swift   # 8-slice trigger pad bar
│   │   │   └── MultiTrackWaveformListView.swift # 8-track scrollable container
│   │   ├── TrackControls/
│   │   │   ├── TrackRowView.swift       # Track row header, Mute/Solo, Waveform, Quick buttons
│   │   │   ├── TrackDetailSheet.swift   # Channel inspector: EQ, Volume, Pan, Slices
│   │   │   └── ParametricEQView.swift   # Interactive 20Hz-20kHz curve & 3-band sliders
│   │   ├── Recording/
│   │   │   ├── RecordTrackModal.swift   # Live mic recording modal with Bar selector
│   │   │   └── InputLevelMeterView.swift # Real-time gradient VU level meter
│   │   ├── Export/
│   │   │   ├── ExportDialogView.swift   # Mixdown vs Stems export dialog
│   │   │   └── ShareSheet.swift         # UIActivityViewController iOS share sheet
│   │   └── Sections/
│   │       └── SectionSelectorView.swift # Song Sections A/B/C/D selector
│   ├── Theme/
│   │   ├── AppColors.swift              # Neon Cyan, Magenta, Purple, Gold color tokens
│   │   └── AppGradients.swift           # Waveform gradients & glassmorphism
│   └── Resources/
│       └── Assets.xcassets/             # App icons & visual catalog
```

---

## ⚡ Các Tính Năng Đột Phá (Key Features)

### 1. 8-Track Live Looping Engine
- **Độc lập trên từng track**: Mỗi track sở hữu chuỗi node âm thanh riêng:
  `AVAudioPlayerNode` ➡️ `AVAudioUnitTimePitch` ➡️ `AVAudioUnitEQ` ➡️ `AVAudioMixerNode` ➡️ `MasterMixer`.
- **Real-time Tempo Stretching**: Thay đổi Master BPM từ 60 đến 200 BPM ngay khi đang phát mà không ngắt nhạc:
  $$\text{rate} = \frac{\text{Master BPM}}{\text{Original BPM}}$$
- **Master Key & Harmonization**: 12 cao độ (C đến B) + Trưởng (Major) / Thứ (Minor). Tự động tính khoảng cách bán cung ngắn nhất ($\Delta \in [-6, 6]$ semitones) và shift pitch của từng track về đúng tông:
  $$\text{pitch (cents)} = \Delta \times 100$$
- **8 Procedural Studio Sound Loops Tích Hợp**: Tự động sinh mã âm thanh 8 track stereo chất lượng cao khi khởi động:
  - Track 1: Kick & Sub Bass (Punchy electronic 4/4 kick + sub transient)
  - Track 2: Snare & Claps (Crisp stereo white noise snare)
  - Track 3: Hi-Hats & Shakers (16th-note rhythmic swing)
  - Track 4: Sub & Acid Synth Bass (C minor syncopated bassline)
  - Track 5: Lush Neon Synth Chords (Warm 7th/9th chord progression)
  - Track 6: Melodic Lead Arp (Plucky arpeggiator)
  - Track 7: Electric Guitar / Pluck (Melodic counterpoint)
  - Track 8: Vocal Chops & FX (Atmospheric riser and chops)

### 2. Touchable Waveform UI (SwiftUI Canvas Renderer)
- **Vẽ đồ họa bằng SwiftUI Canvas**: Tối ưu hiệu năng GPU rendering 60 FPS.
- **Biên độ đa sắc**: Thanh sóng âm dạng cột với gradient Neon Cyan, Magenta, Purple, Gold.
- **Tương tác cảm ứng & Vuốt (Scrubbing)**: Chạm hoặc kéo ngón tay trực tiếp trên dải sóng để nhảy playhead ngay lập tức.
- **Slice Mode (8 lát cắt)**: Chia nhỏ sample thành 8 phần bằng vạch đứt neon, chạm vào lát nào thì loop ngay trong lát cắt đó.

### 3. Song Sections (A, B, C, D)
- Cho phép sắp xếp bài hát thành các đoạn: **A (Intro)**, **B (Verse)**, **C (Chorus)**, **D (Outro)**.
- Chuyển đổi nhanh trạng thái Mute / Solo / Volume của các track chỉ với 1 chạm.

### 4. Thu Âm Trực Tiếp Qua Micro (Live Mic Recording)
- Yêu cầu cấp quyền `NSMicrophoneUsageDescription`.
- Lượng tử hóa theo Bar (1, 2, 4, 8 Bars) dựa trên BPM chủ đạo.
- Đo cường độ tín hiệu mic (VU Meter) thời gian thực.
- Trích xuất đỉnh sóng (Waveform Peaks) bằng thư viện `Accelerate/vDSP` ngay khi kết thúc thu âm và nạp thẳng vào track looper.

### 5. 3-Band Parametric EQ & Export Studio
- **Bộ cân bằng âm thanh 3 dải**:
  - Low Shelf: 120 Hz ($\pm 12\text{ dB}$)
  - Peaking Mid: 1000 Hz ($\pm 12\text{ dB}$, Q=1.0)
  - High Shelf: 7000 Hz ($\pm 12\text{ dB}$)
  - Biểu đồ tần số đáp ứng trực quan (Frequency Response Curve) vẽ bằng Canvas.
- **Xuất Master Mixdown**: Render toàn bộ bản phối thành file Stereo WAV 44.1kHz 16-bit chuẩn phòng thu.
- **Xuất Stems**: Render riêng rẽ 8 file WAV từng track độc lập (`Stem_01_Kick.wav`, `Stem_02_Snare.wav`, ...) để nhập vào DAW (Logic Pro, Ableton Live, FL Studio).
- **iOS ShareSheet**: Chia sẻ file qua AirDrop, Lưu vào Tệp (Files), Drive, Mail,...

---

## 🚀 Hướng Dẫn Mở & Chạy Dự Án Trên Xcode

### Yêu Cầu Hệ Thống:
- macOS 14.0+ (Sonoma) hoặc mới hơn
- Xcode 15.0+ (hỗ trợ Swift 5.9 / 6.0)
- Thiết bị thật iPhone / iPad chạy iOS 17.0+ hoặc iOS Simulator (iPhone 15 Pro / iPad Pro)

### Các Bước Thực Hiện:
1. Sao chép thư mục dự án `BlocsWavePro` sang máy Mac.
2. Mở file dự án:
   ```bash
   open BlocsWavePro/BlocsWavePro.xcodeproj
   ```
   *(Hoặc mở thư mục `BlocsWavePro` trong Xcode như một Swift Package)*.
3. Trong Xcode, chọn Scheme **BlocsWavePro** và chọn Simulator (ví dụ: iPhone 15 Pro) hoặc thiết bị iOS thật.
4. Nhấn **Cmd + R** (Build & Run) để chạy ứng dụng.
5. Ứng dụng sẽ tự động tải 8 track âm thanh studio và bắt đầu phát nhạc ngay khi bạn nhấn **PLAY**!

---

## 🛡 Quản Lý Bộ Nhớ & Tối Ưu Độ Trễ (Audio Engineering Best Practices)

1. **Low-Latency Audio Session**:
   - `preferredIOBufferDuration = 0.005` (5 milliseconds) cho phép phản hồi cảm ứng ngay tức thì không cảm giác trễ âm thanh.
   - Chế độ `AVAudioSession.Category.playAndRecord` kết hợp `.defaultToSpeaker` và `.allowBluetoothA2DP`.
2. **Tránh Memory Leaks & Retain Cycles**:
   - Mọi closure timer, background render, và completion handler đều sử dụng `[weak self]` an toàn.
   - Cơ chế giải phóng PCM Buffer khi track bị ghi đè hoặc app tắt.
3. **Swift Concurrency & Thread Safety**:
   - Xử lý audio DSP trên background thread (`DispatchQueue.global(qos: .userInitiated)`).
   - Cập nhật giao diện `@Observable` và VU Meter trên `@MainActor` / `DispatchQueue.main`.
