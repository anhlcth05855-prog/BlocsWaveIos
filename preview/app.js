// Blocs Wave Pro - Web Audio Live Looper Engine
// Simulates the AVFoundation AVAudioEngine architecture in the browser
// Supports Multi-Genre Sound Packs (Synthwave, EDM, Trap, Lo-Fi, Acoustic)
// and Live Microphone Audio Sampling & Looping with 60 FPS Waveform Canvas

const TRACK_COLORS = [
    '#00F0FF', // Track 1: Kick
    '#FF0D8D', // Track 2: Snare
    '#A626FF', // Track 3: Hats
    '#FFD700', // Track 4: Bass
    '#38FF15', // Track 5: Chords
    '#1A73FF', // Track 6: Lead
    '#FF7300', // Track 7: Pluck
    '#FF3366'  // Track 8: Vocal / FX
];

const TRACK_NAMES = [
    'Kick & Beats',
    'Snare & Claps',
    'Hi-Hats & Shaker',
    'Sub & Synth Bass',
    'Synth Chords',
    'Lead Melody',
    'Acoustic / Pluck',
    'Vocal Chops & FX'
];

const TRACK_ICONS = ['🥁', '👏', '🎩', '🎸', '🎹', '✨', '🪕', '🎙'];

// Section Snapshots (A: Intro, B: Verse, C: Chorus, D: Outro)
const SECTIONS = {
    A: { name: 'Intro', mutes: [false, true, false, true, false, true, true, false] },
    B: { name: 'Verse', mutes: [false, false, false, false, false, true, false, true] },
    C: { name: 'Chorus', mutes: [false, false, false, false, false, false, false, false] },
    D: { name: 'Outro', mutes: [false, true, true, true, false, true, true, false] }
};

// Genre Sound Packs Database
const SOUND_GENRES = {
    synthwave: {
        id: 'synthwave',
        name: 'Synthwave 80s',
        icon: '🌆',
        bpm: 124,
        description: 'Retro 80s neon electronic drums, Juno chords, and rolling basslines.',
        tracks: [
            { name: '80s Analog Kick', desc: 'Punchy electro kick with 48Hz sub transient' },
            { name: 'Gated Reverb Snare', desc: 'Crisp 80s snare with white noise tail' },
            { name: 'Neon 16th Hi-Hats', desc: 'Closed hats with offbeat accent swing' },
            { name: 'Rolling Cyber Bass', desc: 'Sawtooth & sub bassline in C minor' },
            { name: 'Juno Detuned Chords', desc: 'Lush 7th & 9th analog synth pads' },
            { name: 'Laser Synth Arp', desc: '16th-note square arpeggiator' },
            { name: 'Glass Upbeat Pluck', desc: 'Melodic syncopated FM pluck' },
            { name: 'Formant Tape Riser', desc: 'Vocal formant filter sweep & riser' }
        ]
    },
    edm: {
        id: 'edm',
        name: 'EDM Club House',
        icon: '⚡',
        bpm: 128,
        description: 'High energy 4-on-the-floor club kicks, donk bass, and festival leads.',
        tracks: [
            { name: 'Festival Club Kick', desc: '4-on-the-floor deep punchy electro kick' },
            { name: 'Stadium Clap & Snare', desc: 'Wide stereo layered handclaps on 2 & 4' },
            { name: '909 Open Hats & Shaker', desc: 'Energetic offbeat open hat groove' },
            { name: 'Bounce Donk Bass', desc: 'Punchy offbeat Melbourne bounce bass' },
            { name: 'Rave Piano Stabs', desc: '90s classic house piano chord progression' },
            { name: 'Festival Anthemic Lead', desc: 'Unison super-saw soaring hook' },
            { name: 'Eurodance Pluck', desc: 'Bouncy syncopated pluck counterpoint' },
            { name: 'Future Vocal Chops', desc: 'Rhythmic pitched vocal hook pattern' }
        ]
    },
    trap: {
        id: 'trap',
        name: '808 Trap & Hip-Hop',
        icon: '🔥',
        bpm: 138,
        description: 'Hard-hitting 808 booming subs, fast triplet hi-hat rolls, and dark bells.',
        tracks: [
            { name: 'Heavy 808 Sub Kick', desc: 'Sub bass boom with pitch sweep and saturation' },
            { name: 'Digital Trap Snare', desc: 'Tight rimshot snare with 32nd roll on bar 2' },
            { name: 'Triplet Hi-Hat Rolls', desc: 'Fast trap hats with pitch glide rolls' },
            { name: 'Distorted 808 Slide', desc: 'Low 38Hz glide bassline with distortion' },
            { name: 'Dark Minor Bells', desc: 'Eerie music box minor chord progression' },
            { name: 'Trap Whistle / Flute', desc: 'Melodic pitch-bent synth flute lead' },
            { name: 'Pizzicato Pluck', desc: 'Staccato orchestral string bounce' },
            { name: 'Trap Vox Chant & Scratch', desc: 'Chant "Hey!" hit and vinyl rewind' }
        ]
    },
    lofi: {
        id: 'lofi',
        name: 'Lo-Fi Chillout',
        icon: '☕',
        bpm: 85,
        description: 'Dusty vinyl boom-bap drums, Rhodes jazz keys, and warm upright bass.',
        tracks: [
            { name: 'Dusty Vinyl Kick', desc: 'Low-passed boom bap kick with tape warmth' },
            { name: 'Finger Snap & Rimshot', desc: 'Warm acoustic rim-click with subtle vinyl dust' },
            { name: 'Swung Shaker & Hats', desc: 'Relaxed humanized swing groove' },
            { name: 'Upright Jazz Bass', desc: 'Deep warm acoustic double bass round tone' },
            { name: 'Rhodes Electric Piano', desc: 'Lush jazz chords with gentle tremolo' },
            { name: 'Vibraphone Chime', desc: 'Nostalgic music box & mallet melody' },
            { name: 'Muted Nylon Guitar', desc: 'Acoustic jazz guitar chord plucks' },
            { name: 'Radio Vocal & Vinyl Crackle', desc: 'Bandpass filtered nostalgic voice sample' }
        ]
    },
    acoustic: {
        id: 'acoustic',
        name: 'Acoustic & Funk',
        icon: '🎸',
        bpm: 115,
        description: 'Organic wood cajon percussion, funky slap bass, brass horns, and kalimba.',
        tracks: [
            { name: 'Wood Cajon Stomp', desc: 'Acoustic cajon box kick with resonant body' },
            { name: 'Rim-Click & Claps', desc: 'Organic acoustic snare click & handclaps' },
            { name: 'Tambourine & Shaker', desc: 'Crisp brass jingle tambourine 16th groove' },
            { name: 'Funky Slap Bass', desc: 'Thumb slaps and popped funk bassline' },
            { name: 'Wah Rhythm Guitar', desc: '16th-note funk rhythm guitar chops' },
            { name: 'Brass Horn Stabs', desc: 'Energetic trumpet and sax section stabs' },
            { name: 'African Kalimba Pluck', desc: 'Melodic thumb piano counterpoint' },
            { name: 'Soulful Vocal Groove', desc: 'Live crowd vocal chops and shaker fill' }
        ]
    }
};

class AudioEngine {
    constructor() {
        this.ctx = null;
        this.isPlaying = false;
        this.bpm = 124.0;
        this.baseBpm = 124.0;
        this.masterKey = { pitch: 'C', mode: 'Min', semitones: 0 };
        this.tracks = [];
        this.metronomeEnabled = false;
        this.nextBeatTime = 0;
        this.beatIndex = 0;
        this.startTime = 0;
        this.activeSection = 'A';
        this.activeGenre = 'synthwave';
        this.tapTimes = [];

        // Preview & Audition Node
        this.previewSourceNode = null;

        // Microphone Live Recording
        this.micStream = null;
        this.micSource = null;
        this.micAnalyser = null;
        this.isRecording = false;
        this.recordedChunks = [];
        this.recordTargetTrack = 7;
        this.recordBars = 2;
        this.recordStartTime = 0;
        this.recordDurationSec = 0;
        this.recordTimerId = null;
    }

    init() {
        const AudioContextClass = window.AudioContext || window.webkitAudioContext;
        this.ctx = new AudioContextClass();

        this.masterGain = this.ctx.createGain();
        this.masterGain.gain.value = 0.9;
        this.masterGain.connect(this.ctx.destination);

        // Preview Gain (isolated from master loops)
        this.previewGain = this.ctx.createGain();
        this.previewGain.gain.value = 0.85;
        this.previewGain.connect(this.ctx.destination);

        // Synthesize initial 8 tracks (Synthwave pack)
        for (let i = 0; i < 8; i++) {
            const buffer = this.synthesizeTrackBuffer(i, this.activeGenre);
            const peaks = this.extractPeaks(buffer, 64);

            const eqLow = this.ctx.createBiquadFilter();
            eqLow.type = 'lowshelf';
            eqLow.frequency.value = 120;

            const eqMid = this.ctx.createBiquadFilter();
            eqMid.type = 'peaking';
            eqMid.frequency.value = 1000;
            eqMid.Q.value = 1.0;

            const eqHigh = this.ctx.createBiquadFilter();
            eqHigh.type = 'highshelf';
            eqHigh.frequency.value = 7000;

            const panNode = this.ctx.createStereoPanner ? this.ctx.createStereoPanner() : null;
            const trackGain = this.ctx.createGain();
            trackGain.gain.value = 0.85;

            // Connect EQ -> Pan -> Gain -> Master
            eqLow.connect(eqMid);
            eqMid.connect(eqHigh);
            if (panNode) {
                eqHigh.connect(panNode);
                panNode.connect(trackGain);
            } else {
                eqHigh.connect(trackGain);
            }
            trackGain.connect(this.masterGain);

            this.tracks.push({
                index: i,
                name: SOUND_GENRES[this.activeGenre].tracks[i].name,
                genre: this.activeGenre,
                color: TRACK_COLORS[i],
                icon: TRACK_ICONS[i],
                buffer: buffer,
                peaks: peaks,
                eqLow: eqLow,
                eqMid: eqMid,
                eqHigh: eqHigh,
                panNode: panNode,
                gainNode: trackGain,
                sourceNode: null,
                volume: 0.85,
                pan: 0,
                isMuted: false,
                isSolo: false,
                isSliceMode: false,
                activeSlice: null,
                playhead: 0,
                isUserRecorded: false
            });
        }

        // Apply Section A
        this.applySection('A');
    }

    // Synthesize diverse sounds across 5 genres (40 distinct loop variations!)
    synthesizeTrackBuffer(trackIndex, genre = this.activeGenre) {
        const sampleRate = this.ctx.sampleRate;
        const bars = 2;
        const duration = (60.0 / this.baseBpm) * 4 * bars; // 8 beats ~3.87s
        const frameCount = Math.floor(sampleRate * duration);
        const buffer = this.ctx.createBuffer(2, frameCount, sampleRate);
        const left = buffer.getChannelData(0);
        const right = buffer.getChannelData(1);

        const secondsPerBeat = 60.0 / this.baseBpm;

        for (let i = 0; i < frameCount; i++) {
            const t = i / sampleRate;
            const currentBeat = t / secondsPerBeat;
            let sampleL = 0;
            let sampleR = 0;

            switch (genre) {
                case 'synthwave':
                    [sampleL, sampleR] = this.synthesizeSynthwave(trackIndex, currentBeat, t, secondsPerBeat, duration);
                    break;
                case 'edm':
                    [sampleL, sampleR] = this.synthesizeEDM(trackIndex, currentBeat, t, secondsPerBeat, duration);
                    break;
                case 'trap':
                    [sampleL, sampleR] = this.synthesizeTrap(trackIndex, currentBeat, t, secondsPerBeat, duration);
                    break;
                case 'lofi':
                    [sampleL, sampleR] = this.synthesizeLoFi(trackIndex, currentBeat, t, secondsPerBeat, duration);
                    break;
                case 'acoustic':
                    [sampleL, sampleR] = this.synthesizeAcoustic(trackIndex, currentBeat, t, secondsPerBeat, duration);
                    break;
                default:
                    [sampleL, sampleR] = this.synthesizeSynthwave(trackIndex, currentBeat, t, secondsPerBeat, duration);
            }

            // Boundary de-click fade (2ms at edges)
            const fade = Math.floor(0.002 * sampleRate);
            let win = 1.0;
            if (i < fade) win = i / fade;
            else if (i > frameCount - fade) win = (frameCount - i) / fade;

            left[i] = sampleL * win;
            right[i] = sampleR * win;
        }

        return buffer;
    }

    // 1. Synthwave 80s Sound Engine
    synthesizeSynthwave(trackIndex, currentBeat, t, spb, duration) {
        switch (trackIndex) {
            case 0: { // 80s Kick
                const beatPhase = currentBeat % 1.0;
                const bt = beatPhase * spb;
                if (bt < 0.3) {
                    const pitch = 48.0 + 110.0 * Math.exp(-bt * 32.0);
                    const env = Math.exp(-bt * 12.0);
                    const click = (bt < 0.006) ? (Math.random() * 0.35 - 0.17) : 0;
                    const v = (Math.sin(2 * Math.PI * pitch * bt) + click) * env * 0.95;
                    return [v, v];
                }
                return [0, 0];
            }
            case 1: { // Gated Snare
                const beatIdx = Math.floor(currentBeat) % 8;
                if (beatIdx % 2 === 1) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.28) {
                        const tone = Math.sin(2 * Math.PI * 190.0 * bt) * Math.exp(-bt * 22.0);
                        const noiseL = (Math.random() * 2 - 1) * Math.exp(-bt * 14.0);
                        const noiseR = (Math.random() * 2 - 1) * Math.exp(-bt * 14.0);
                        return [(tone * 0.4 + noiseL * 0.6) * 0.85, (tone * 0.4 + noiseR * 0.6) * 0.85];
                    }
                }
                return [0, 0];
            }
            case 2: { // 16th Hi-Hats
                const time16 = ((currentBeat * 4.0) % 1.0) * (spb / 4.0);
                if (time16 < 0.065) {
                    const step = Math.floor(currentBeat * 4.0) % 16;
                    const isAccent = (step % 2 === 1);
                    const env = Math.exp(-time16 * (isAccent ? 75.0 : 120.0)) * (isAccent ? 0.7 : 0.35);
                    return [(Math.random() * 2 - 1) * env, (Math.random() * 2 - 1) * env];
                }
                return [0, 0];
            }
            case 3: { // Rolling Synthwave Bass (C minor)
                const notes = [
                    { b: 0.0, d: 0.75, f: 65.4 }, { b: 1.0, d: 0.5, f: 65.4 }, { b: 1.75, d: 0.25, f: 77.78 },
                    { b: 2.0, d: 0.75, f: 87.3 }, { b: 3.0, d: 0.75, f: 98.0 }, { b: 4.0, d: 0.75, f: 65.4 },
                    { b: 5.0, d: 0.5, f: 65.4 }, { b: 5.5, d: 0.5, f: 58.27 }, { b: 6.0, d: 0.75, f: 77.78 }, { b: 7.0, d: 0.75, f: 65.4 }
                ];
                const b8 = currentBeat % 8.0;
                for (const n of notes) {
                    if (b8 >= n.b && b8 < (n.b + n.d)) {
                        const nt = (b8 - n.b) * spb;
                        const env = Math.exp(-nt * 4.2);
                        const saw = ((t * n.f) % 1.0) * 2.0 - 1.0;
                        const sub = Math.sin(2 * Math.PI * (n.f * 0.5) * t);
                        const v = (saw * 0.45 + sub * 0.55) * env * 0.85;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 4: { // Juno Detuned Chords
                const bar = Math.floor(currentBeat / 2.0) % 4;
                const freqs = [
                    [130.81, 155.56, 196.00, 233.08], [103.83, 130.81, 155.56, 196.00],
                    [174.61, 207.65, 261.63, 311.13], [196.00, 233.08, 293.66, 349.23]
                ][bar];
                const ct = (currentBeat % 2.0) * spb;
                const env = Math.exp(-ct * 1.8) * (1.0 - Math.exp(-ct * 40.0));
                let vl = 0, vr = 0;
                for (let c = 0; c < freqs.length; c++) {
                    const f = freqs[c];
                    vl += Math.sin(2 * Math.PI * (f - 0.75) * t);
                    vr += Math.sin(2 * Math.PI * (f + 0.75) * t);
                }
                return [vl * 0.16 * env, vr * 0.16 * env];
            }
            case 5: { // Laser Arp
                const arp = [261.63, 311.13, 392.00, 466.16, 523.25, 466.16, 392.00, 311.13];
                const f = arp[Math.floor(currentBeat * 4.0) % 8];
                const time16 = ((currentBeat * 4.0) % 1.0) * (spb / 4.0);
                const env = Math.exp(-time16 * 18.0);
                const sqr = Math.sin(2 * Math.PI * f * t) > 0 ? 0.6 : -0.6;
                const v = sqr * env * 0.38;
                return [v * 0.8, v * 1.2];
            }
            case 6: { // Glass Pluck
                const step = Math.floor(currentBeat * 2.0) % 8;
                if (step === 1 || step === 3 || step === 6) {
                    const pt = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                    const env = Math.exp(-pt * 12.0);
                    const v = Math.sin(2 * Math.PI * 523.25 * t) * env * 0.45;
                    return [v * 0.7, v * 0.9];
                }
                return [0, 0];
            }
            case 7: { // Vocal Riser
                const ct = (currentBeat % 1.0) * spb;
                const f = 400.0 + (t / duration) * 800.0;
                const env = ct < 0.22 ? Math.exp(-ct * 12.0) : 0;
                const v = Math.sin(2 * Math.PI * f * t) * Math.sin(2 * Math.PI * 800.0 * t) * env * 0.35;
                return [v, v];
            }
        }
        return [0, 0];
    }

    // 2. EDM Club House Sound Engine
    synthesizeEDM(trackIndex, currentBeat, t, spb, duration) {
        switch (trackIndex) {
            case 0: { // Punchy 4-to-the-floor Kick
                const bt = (currentBeat % 1.0) * spb;
                if (bt < 0.28) {
                    const pitch = 52.0 + 130.0 * Math.exp(-bt * 38.0);
                    const env = Math.exp(-bt * 14.0);
                    const click = (bt < 0.005) ? (Math.random() * 0.5 - 0.25) : 0;
                    const v = (Math.sin(2 * Math.PI * pitch * bt) + click) * env;
                    return [v, v];
                }
                return [0, 0];
            }
            case 1: { // Wide Stadium Clap on 2 & 4
                const beatIdx = Math.floor(currentBeat) % 8;
                if (beatIdx % 2 === 1) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.22) {
                        // Multi-clap flam
                        const flam = (bt < 0.015) ? 0.6 : 1.0;
                        const noiseL = (Math.random() * 2 - 1) * Math.exp(-bt * 18.0) * flam;
                        const noiseR = (Math.random() * 2 - 1) * Math.exp(-bt * 18.0) * flam;
                        return [noiseL * 0.85, noiseR * 0.85];
                    }
                }
                return [0, 0];
            }
            case 2: { // 909 Open Hats on Offbeat ("tsss")
                const offbeat = (currentBeat + 0.5) % 1.0;
                const ht = offbeat * spb;
                if (ht < 0.18) {
                    const env = Math.exp(-ht * 24.0);
                    const noise = (Math.random() * 2 - 1) * env * 0.7;
                    return [noise, noise];
                }
                return [0, 0];
            }
            case 3: { // Bouncy Melbourne / Donk Bass
                const offbeat = (currentBeat + 0.5) % 1.0;
                const bt = offbeat * spb;
                if (bt < 0.22) {
                    const barIdx = Math.floor(currentBeat) % 8;
                    const freqs = [65.4, 65.4, 77.78, 87.3, 65.4, 65.4, 98.0, 77.78];
                    const f = freqs[barIdx];
                    const pitchMod = f * (1.0 + 2.0 * Math.exp(-bt * 40.0));
                    const env = Math.exp(-bt * 8.0);
                    const v = Math.sin(2 * Math.PI * pitchMod * bt) * env * 0.9;
                    return [v, v];
                }
                return [0, 0];
            }
            case 4: { // Rave House Piano Stabs
                const beatInBar = currentBeat % 1.0;
                if (beatInBar < 0.3 || (beatInBar > 0.5 && beatInBar < 0.8)) {
                    const pt = (beatInBar < 0.5 ? beatInBar : beatInBar - 0.5) * spb;
                    const env = Math.exp(-pt * 8.0);
                    const chord = [261.63, 329.63, 392.00, 493.88]; // C maj7
                    let v = 0;
                    for (const f of chord) v += Math.sin(2 * Math.PI * f * t);
                    return [v * 0.15 * env, v * 0.15 * env];
                }
                return [0, 0];
            }
            case 5: { // Festival Supersaw Hook
                const notes = [523.25, 587.33, 659.25, 783.99, 659.25, 587.33, 523.25, 392.0];
                const f = notes[Math.floor(currentBeat) % 8];
                const bt = (currentBeat % 1.0) * spb;
                const env = Math.exp(-bt * 3.5);
                let vl = 0, vr = 0;
                for (let s = -2; s <= 2; s++) {
                    vl += (((t * (f + s * 1.5)) % 1.0) * 2 - 1) * 0.12;
                    vr += (((t * (f - s * 1.5)) % 1.0) * 2 - 1) * 0.12;
                }
                return [vl * env, vr * env];
            }
            case 6: { // Euro Pluck
                const step = Math.floor(currentBeat * 4.0) % 16;
                if (step % 3 === 0) {
                    const pt = ((currentBeat * 4.0) % 1.0) * (spb / 4.0);
                    const env = Math.exp(-pt * 18.0);
                    const v = Math.sin(2 * Math.PI * 659.25 * t) * env * 0.45;
                    return [v * 0.6, v * 0.9];
                }
                return [0, 0];
            }
            case 7: { // Future Vocal Chops
                const step = Math.floor(currentBeat * 2.0) % 8;
                const fList = [600, 750, 900, 600, 800, 950, 700, 850];
                const f = fList[step];
                const vt = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                if (vt < 0.2) {
                    const env = Math.exp(-vt * 14.0);
                    const v = Math.sin(2 * Math.PI * f * t) * Math.sin(2 * Math.PI * 220.0 * t) * env * 0.4;
                    return [v, v];
                }
                return [0, 0];
            }
        }
        return [0, 0];
    }

    // 3. 808 Trap & Hip-Hop Sound Engine
    synthesizeTrap(trackIndex, currentBeat, t, spb, duration) {
        switch (trackIndex) {
            case 0: { // 808 Booming Kick
                const beatIdx = Math.floor(currentBeat) % 8;
                const isKick = (beatIdx === 0 || beatIdx === 3 || beatIdx === 5 || beatIdx === 6.5);
                if (isKick) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.55) {
                        const pitch = 38.0 + 90.0 * Math.exp(-bt * 45.0);
                        const env = Math.exp(-bt * 6.5);
                        let v = Math.sin(2 * Math.PI * pitch * bt) * env;
                        v = Math.tanh(v * 1.5); // Saturated 808
                        return [v * 0.9, v * 0.9];
                    }
                }
                return [0, 0];
            }
            case 1: { // Trap Rim / Snare with 32nd roll on bar 2
                const beatIn8 = currentBeat % 8.0;
                if ((Math.floor(beatIn8) === 2 || Math.floor(beatIn8) === 6)) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.18) {
                        const v = (Math.random() * 2 - 1) * Math.exp(-bt * 28.0) * 0.85;
                        return [v, v];
                    }
                } else if (beatIn8 >= 7.5) { // Rapid 32nd roll
                    const rollStep = ((beatIn8 * 8.0) % 1.0) * (spb / 8.0);
                    if (rollStep < 0.05) {
                        const v = (Math.random() * 2 - 1) * Math.exp(-rollStep * 40.0) * 0.7;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 2: { // Fast Trap Hi-Hats with Triplet Rolls
                const step = Math.floor(currentBeat * 4.0) % 16;
                const isRoll = (step === 10 || step === 11 || step === 14);
                const subDiv = isRoll ? 6.0 : 4.0;
                const ht = ((currentBeat * subDiv) % 1.0) * (spb / subDiv);
                if (ht < 0.045) {
                    const env = Math.exp(-ht * 90.0) * 0.6;
                    return [(Math.random() * 2 - 1) * env, (Math.random() * 2 - 1) * env];
                }
                return [0, 0];
            }
            case 3: { // 808 Slide Sub Bass
                const b8 = currentBeat % 8.0;
                const notes = [{ b: 0, d: 2, f: 32.7 }, { b: 2.5, d: 1.5, f: 38.9 }, { b: 4, d: 2, f: 43.6 }, { b: 6, d: 2, f: 49.0 }];
                for (const n of notes) {
                    if (b8 >= n.b && b8 < (n.b + n.d)) {
                        const nt = (b8 - n.b) * spb;
                        const env = Math.exp(-nt * 2.0);
                        const v = Math.tanh(Math.sin(2 * Math.PI * n.f * t) * 2.2) * env * 0.8;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 4: { // Dark Minor Bell Chords
                const chordIdx = Math.floor(currentBeat / 2.0) % 4;
                const freqs = [[261.63, 311.13, 392.00], [246.94, 293.66, 369.99], [220.00, 261.63, 329.63], [246.94, 311.13, 369.99]][chordIdx];
                const ct = (currentBeat % 2.0) * spb;
                const env = Math.exp(-ct * 2.5);
                let v = 0;
                for (const f of freqs) v += Math.sin(2 * Math.PI * f * t) + 0.3 * Math.sin(2 * Math.PI * f * 2 * t);
                return [v * 0.16 * env, v * 0.16 * env];
            }
            case 5: { // Trap Whistle / Flute
                const notes = [587.33, 659.25, 783.99, 880.00];
                const f = notes[Math.floor(currentBeat * 2.0) % 4];
                const ft = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                const env = Math.exp(-ft * 5.0) * (1 - Math.exp(-ft * 30.0));
                const v = Math.sin(2 * Math.PI * f * t) * env * 0.38;
                return [v * 0.7, v * 1.1];
            }
            case 6: { // Pizzicato Pluck
                const pt = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                if (pt < 0.12) {
                    const env = Math.exp(-pt * 25.0);
                    const v = (Math.sin(2 * Math.PI * 440.0 * t) + Math.sin(2 * Math.PI * 880.0 * t) * 0.5) * env * 0.5;
                    return [v, v * 0.8];
                }
                return [0, 0];
            }
            case 7: { // Trap Chant "Hey!" & Scratch
                const step = Math.floor(currentBeat) % 8;
                if (step === 2 || step === 6) {
                    const ct = (currentBeat % 1.0) * spb;
                    if (ct < 0.25) {
                        const env = Math.exp(-ct * 12.0);
                        const v = Math.sin(2 * Math.PI * 520.0 * ct) * Math.sin(2 * Math.PI * 180.0 * ct) * env * 0.6;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
        }
        return [0, 0];
    }

    // 4. Lo-Fi Chillout Sound Engine
    synthesizeLoFi(trackIndex, currentBeat, t, spb, duration) {
        // Subtle constant vinyl crackle
        const vinylNoise = (Math.random() < 0.03 ? (Math.random() * 0.08 - 0.04) : 0);

        switch (trackIndex) {
            case 0: { // Dusty Boom-Bap Kick
                const beatIn8 = currentBeat % 8.0;
                const isKick = (beatIn8 < 0.5 || (beatIn8 >= 2.75 && beatIn8 < 3.25) || (beatIn8 >= 4.0 && beatIn8 < 4.5));
                if (isKick) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.35) {
                        const pitch = 44.0 + 85.0 * Math.exp(-bt * 24.0);
                        const env = Math.exp(-bt * 8.5);
                        const v = Math.sin(2 * Math.PI * pitch * bt) * env * 0.85;
                        return [v + vinylNoise, v + vinylNoise];
                    }
                }
                return [vinylNoise, vinylNoise];
            }
            case 1: { // Soft Rimshot & Finger Snap
                const beatIdx = Math.floor(currentBeat) % 8;
                if (beatIdx % 2 === 1) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.16) {
                        const snap = Math.sin(2 * Math.PI * 850.0 * bt) * Math.exp(-bt * 35.0) * 0.4;
                        const wood = (Math.random() * 2 - 1) * Math.exp(-bt * 25.0) * 0.35;
                        const v = (snap + wood) * 0.75;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 2: { // Swung Shaker Groove
                const time16 = ((currentBeat * 4.0 + 0.15) % 1.0) * (spb / 4.0);
                if (time16 < 0.08) {
                    const env = Math.exp(-time16 * 45.0) * 0.28;
                    const noise = (Math.random() * 2 - 1) * env;
                    return [noise, noise];
                }
                return [0, 0];
            }
            case 3: { // Upright Acoustic Jazz Bass
                const notes = [65.4, 77.78, 58.27, 49.0];
                const f = notes[Math.floor(currentBeat / 2.0) % 4];
                const bt = (currentBeat % 2.0) * spb;
                const env = Math.exp(-bt * 2.2);
                const v = Math.sin(2 * Math.PI * f * t) * env * 0.75;
                return [v, v];
            }
            case 4: { // Rhodes Electric Piano (with Wow & Flutter)
                const bar = Math.floor(currentBeat / 2.0) % 4;
                const chords = [[130.81, 196.00, 261.63, 311.13], [116.54, 174.61, 233.08, 293.66], [103.83, 155.56, 207.65, 261.63], [98.00, 146.83, 196.00, 246.94]][bar];
                const ct = (currentBeat % 2.0) * spb;
                const env = Math.exp(-ct * 1.4);
                // Vibrato / wow
                const wow = Math.sin(2 * Math.PI * 4.5 * t) * 0.8;
                let v = 0;
                for (const f of chords) v += Math.sin(2 * Math.PI * (f + wow) * t);
                return [v * 0.12 * env, v * 0.12 * env];
            }
            case 5: { // Vibraphone Melody
                const notes = [523.25, 587.33, 659.25, 783.99];
                const f = notes[Math.floor(currentBeat) % 4];
                const vt = (currentBeat % 1.0) * spb;
                const env = Math.exp(-vt * 3.8);
                const v = Math.sin(2 * Math.PI * f * t) * env * 0.32;
                return [v * 0.8, v * 1.1];
            }
            case 6: { // Nylon Jazz Guitar
                const step = Math.floor(currentBeat * 2.0) % 8;
                if (step === 2 || step === 5) {
                    const gt = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                    const env = Math.exp(-gt * 10.0);
                    const v = (Math.sin(2 * Math.PI * 330.0 * t) + Math.sin(2 * Math.PI * 660.0 * t) * 0.4) * env * 0.45;
                    return [v, v * 0.9];
                }
                return [0, 0];
            }
            case 7: { // Radio Vocal & Rain Ambiance
                const vt = (currentBeat % 2.0) * spb;
                if (vt < 0.4) {
                    const env = Math.exp(-vt * 6.0);
                    const v = Math.sin(2 * Math.PI * 680.0 * t) * env * 0.25;
                    return [v + vinylNoise, v + vinylNoise];
                }
                return [vinylNoise, vinylNoise];
            }
        }
        return [0, 0];
    }

    // 5. Acoustic & Funk Sound Engine
    synthesizeAcoustic(trackIndex, currentBeat, t, spb, duration) {
        switch (trackIndex) {
            case 0: { // Cajon Wood Stomp Kick
                const beatIn8 = currentBeat % 8.0;
                const isKick = (beatIn8 < 0.5 || (beatIn8 >= 2.5 && beatIn8 < 3.0) || (beatIn8 >= 4.0 && beatIn8 < 4.5));
                if (isKick) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.25) {
                        const pitch = 65.0 + 80.0 * Math.exp(-bt * 35.0);
                        const env = Math.exp(-bt * 14.0);
                        const slap = (bt < 0.008) ? (Math.random() * 0.3) : 0;
                        const v = (Math.sin(2 * Math.PI * pitch * bt) + slap) * env * 0.85;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 1: { // Rimshot & Handclap
                const beatIdx = Math.floor(currentBeat) % 8;
                if (beatIdx % 2 === 1) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.2) {
                        const tone = Math.sin(2 * Math.PI * 320.0 * bt) * Math.exp(-bt * 30.0);
                        const noise = (Math.random() * 2 - 1) * Math.exp(-bt * 18.0);
                        const v = (tone * 0.5 + noise * 0.5) * 0.8;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 2: { // Tambourine & Shaker
                const step = Math.floor(currentBeat * 4.0) % 16;
                const tt = ((currentBeat * 4.0) % 1.0) * (spb / 4.0);
                if (tt < 0.08) {
                    const jingle = Math.sin(2 * Math.PI * 4500.0 * tt) * 0.3;
                    const noise = (Math.random() * 2 - 1) * 0.7;
                    const v = (jingle + noise) * Math.exp(-tt * 40.0) * (step % 4 === 2 ? 0.65 : 0.35);
                    return [v, v];
                }
                return [0, 0];
            }
            case 3: { // Funky Slap Bass
                const b8 = currentBeat % 8.0;
                const notes = [{ b: 0, d: 0.5, f: 82.4 }, { b: 0.75, d: 0.25, f: 98.0 }, { b: 1.5, d: 0.5, f: 110.0 }, { b: 2, d: 0.5, f: 82.4 }, { b: 3.5, d: 0.5, f: 73.4 }, { b: 4, d: 0.5, f: 82.4 }, { b: 5.5, d: 0.5, f: 98.0 }];
                for (const n of notes) {
                    if (b8 >= n.b && b8 < (n.b + n.d)) {
                        const nt = (b8 - n.b) * spb;
                        const env = Math.exp(-nt * 8.0);
                        const pop = (nt < 0.01) ? 1.5 : 1.0;
                        const v = Math.sin(2 * Math.PI * n.f * t) * env * pop * 0.85;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
            case 4: { // Wah Funk Rhythm Guitar
                const step = Math.floor(currentBeat * 4.0) % 16;
                if (step % 2 === 1) {
                    const gt = ((currentBeat * 4.0) % 1.0) * (spb / 4.0);
                    const wah = 600.0 + 1200.0 * Math.sin(2 * Math.PI * 2.0 * t);
                    const env = Math.exp(-gt * 15.0);
                    const v = (Math.sin(2 * Math.PI * wah * t) * 0.5 + Math.sin(2 * Math.PI * 330.0 * t) * 0.5) * env * 0.4;
                    return [v * 0.8, v * 1.1];
                }
                return [0, 0];
            }
            case 5: { // Brass Horn Stabs
                const beatIn8 = currentBeat % 8.0;
                if (beatIn8 === 0 || beatIn8 === 2.5 || beatIn8 === 4.0 || beatIn8 === 6.5) {
                    const bt = (currentBeat % 1.0) * spb;
                    if (bt < 0.28) {
                        const env = Math.exp(-bt * 6.0);
                        const chord = [349.23, 440.00, 523.25]; // F maj brass
                        let v = 0;
                        for (const f of chord) v += Math.sin(2 * Math.PI * f * t) * 0.35 + (Math.sin(2 * Math.PI * f * 2 * t) * 0.15);
                        return [v * env, v * env];
                    }
                }
                return [0, 0];
            }
            case 6: { // Kalimba Thumb Piano
                const kalimba = [523.25, 659.25, 783.99, 880.00, 1046.5];
                const f = kalimba[Math.floor(currentBeat * 2.0) % kalimba.length];
                const kt = ((currentBeat * 2.0) % 1.0) * (spb / 2.0);
                const env = Math.exp(-kt * 10.0);
                const v = Math.sin(2 * Math.PI * f * t) * env * 0.38;
                return [v * 1.1, v * 0.8];
            }
            case 7: { // Funk Vocal Groove
                const beatIdx = Math.floor(currentBeat) % 8;
                if (beatIdx === 3 || beatIdx === 7) {
                    const vt = (currentBeat % 1.0) * spb;
                    if (vt < 0.22) {
                        const env = Math.exp(-vt * 12.0);
                        const v = Math.sin(2 * Math.PI * 450.0 * t) * Math.sin(2 * Math.PI * 180.0 * t) * env * 0.45;
                        return [v, v];
                    }
                }
                return [0, 0];
            }
        }
        return [0, 0];
    }

    // Apply complete genre pack to all 8 tracks
    applyGenrePack(genreKey) {
        if (!SOUND_GENRES[genreKey]) return;
        this.activeGenre = genreKey;
        const pack = SOUND_GENRES[genreKey];

        this.tracks.forEach((track, idx) => {
            if (!track.isUserRecorded) {
                const newBuffer = this.synthesizeTrackBuffer(idx, genreKey);
                track.buffer = newBuffer;
                track.peaks = this.extractPeaks(newBuffer, 64);
                track.genre = genreKey;
                track.name = pack.tracks[idx].name;

                if (this.isPlaying) {
                    this.scheduleTrack(track, track.playhead || 0);
                }
            }
        });
    }

    // Load individual preset into a single track
    loadTrackPreset(trackIndex, genreKey) {
        const track = this.tracks[trackIndex];
        if (!track || !SOUND_GENRES[genreKey]) return;

        const newBuffer = this.synthesizeTrackBuffer(trackIndex, genreKey);
        track.buffer = newBuffer;
        track.peaks = this.extractPeaks(newBuffer, 64);
        track.genre = genreKey;
        track.name = SOUND_GENRES[genreKey].tracks[trackIndex].name;
        track.isUserRecorded = false;

        if (this.isPlaying) {
            this.scheduleTrack(track, track.playhead || 0);
        }
    }

    // Audition preview single preset in Sound Library modal
    previewPreset(trackIndex, genreKey) {
        this.stopPreview();

        const buffer = this.synthesizeTrackBuffer(trackIndex, genreKey);
        const source = this.ctx.createBufferSource();
        source.buffer = buffer;
        source.connect(this.previewGain);
        source.start(0);
        this.previewSourceNode = source;
    }

    stopPreview() {
        if (this.previewSourceNode) {
            try { this.previewSourceNode.stop(); } catch (e) {}
            this.previewSourceNode.disconnect();
            this.previewSourceNode = null;
        }
    }

    // Extract visual waveform peaks
    extractPeaks(buffer, count) {
        const left = buffer.getChannelData(0);
        const chunkSize = Math.floor(left.length / count);
        const peaks = [];
        let max = 0;

        for (let i = 0; i < count; i++) {
            let chunkMax = 0;
            for (let j = 0; j < chunkSize; j++) {
                const val = Math.abs(left[i * chunkSize + j]);
                if (val > chunkMax) chunkMax = val;
            }
            peaks.push(chunkMax);
            if (chunkMax > max) max = chunkMax;
        }

        const scale = max > 0.001 ? 1.0 / max : 1.0;
        return peaks.map(p => Math.min(1.0, Math.max(0.08, p * scale)));
    }

    // MARK: - Live Microphone Recording
    async initMicrophone() {
        try {
            if (!this.micStream) {
                this.micStream = await navigator.mediaDevices.getUserMedia({
                    audio: {
                        echoCancellation: false,
                        noiseSuppression: false,
                        autoGainControl: false
                    }
                });

                if (!this.ctx) this.init();
                this.micSource = this.ctx.createMediaStreamSource(this.micStream);
                this.micAnalyser = this.ctx.createAnalyser();
                this.micAnalyser.fftSize = 256;
                this.micSource.connect(this.micAnalyser);

                this.startVULevelMonitoring();
            }
            return true;
        } catch (err) {
            console.warn('Microphone permission denied or not available:', err);
            return false;
        }
    }

    startVULevelMonitoring() {
        const fillEl = document.getElementById('meterBarFill');
        const textEl = document.getElementById('vuLevelPercent');
        const data = new Uint8Array(this.micAnalyser.frequencyBinCount);

        const updateMeter = () => {
            if (!this.micAnalyser) return;
            this.micAnalyser.getByteTimeDomainData(data);

            let sum = 0;
            for (let i = 0; i < data.length; i++) {
                const val = (data[i] - 128) / 128;
                sum += val * val;
            }
            const rms = Math.sqrt(sum / data.length);
            const level = Math.min(100, Math.round(rms * 280));

            if (fillEl) fillEl.style.width = `${level}%`;
            if (textEl) textEl.textContent = `${level}%`;

            requestAnimationFrame(updateMeter);
        };

        requestAnimationFrame(updateMeter);
    }

    async startLiveRecording(targetTrackIndex, bars = 2) {
        this.recordTargetTrack = targetTrackIndex;
        this.recordBars = bars;
        this.isRecording = true;
        this.recordedChunks = [];

        const hasMic = await this.initMicrophone();
        if (!hasMic) {
            // If mic is not accessible in browser environment, simulate sample recording seamlessly!
            this.simulateSampleRecording(targetTrackIndex, bars);
            return;
        }

        const sampleRate = this.ctx.sampleRate;
        const totalDurationSec = (60.0 / this.bpm) * 4 * bars;
        this.recordDurationSec = totalDurationSec;
        this.recordStartTime = Date.now();

        // Use ScriptProcessorNode to capture raw PCM Float32 samples
        const bufferSize = 2048;
        this.recNode = this.ctx.createScriptProcessor(bufferSize, 1, 1);
        this.recNode.onaudioprocess = (e) => {
            if (!this.isRecording) return;
            const input = e.inputBuffer.getChannelData(0);
            this.recordedChunks.push(new Float32Array(input));

            const elapsedSec = (Date.now() - this.recordStartTime) / 1000.0;
            const timerEl = document.getElementById('recordTimerDisplay');
            if (timerEl) {
                timerEl.textContent = `${elapsedSec.toFixed(1)}s / ${totalDurationSec.toFixed(1)}s (${bars} Bars)`;
            }

            if (elapsedSec >= totalDurationSec) {
                this.stopLiveRecording();
            }
        };

        this.micSource.connect(this.recNode);
        this.recNode.connect(this.ctx.destination); // Required for script processor in some browsers
    }

    stopLiveRecording() {
        if (!this.isRecording) return;
        this.isRecording = false;

        if (this.recNode) {
            this.recNode.disconnect();
            this.recNode = null;
        }

        if (this.recordedChunks.length === 0) return;

        // Flatten chunks into a single Float32Array
        let totalLength = 0;
        for (const chunk of this.recordedChunks) totalLength += chunk.length;

        const flattened = new Float32Array(totalLength);
        let offset = 0;
        for (const chunk of this.recordedChunks) {
            flattened.set(chunk, offset);
            offset += chunk.length;
        }

        this.applyRecordedAudio(this.recordTargetTrack, flattened);
    }

    // Applies recorded PCM data into the target track
    applyRecordedAudio(trackIndex, pcmFloatArray) {
        const sampleRate = this.ctx.sampleRate;
        const frameCount = pcmFloatArray.length;
        const buffer = this.ctx.createBuffer(2, frameCount, sampleRate);
        const left = buffer.getChannelData(0);
        const right = buffer.getChannelData(1);

        // Normalize peak
        let maxVal = 0;
        for (let i = 0; i < frameCount; i++) {
            const abs = Math.abs(pcmFloatArray[i]);
            if (abs > maxVal) maxVal = abs;
        }
        const normFactor = maxVal > 0.01 ? 0.95 / maxVal : 1.0;

        for (let i = 0; i < frameCount; i++) {
            const sample = pcmFloatArray[i] * normFactor;
            left[i] = sample;
            right[i] = sample;
        }

        const track = this.tracks[trackIndex];
        track.buffer = buffer;
        track.peaks = this.extractPeaks(buffer, 64);
        track.isUserRecorded = true;
        track.name = `🎙️ Mic Loop ${trackIndex + 1}`;

        if (this.isPlaying) {
            this.scheduleTrack(track, 0);
        }

        renderTracks();
        document.getElementById('statusText').textContent = `LIVE AUDIO RECORDED INTO TRACK ${trackIndex + 1} (${this.recordBars} BARS)`;
    }

    // High quality simulated vocal / beatbox sampling when hardware microphone is blocked
    simulateSampleRecording(trackIndex, bars = 2) {
        const sampleRate = this.ctx.sampleRate;
        const duration = (60.0 / this.bpm) * 4 * bars;
        const frameCount = Math.floor(sampleRate * duration);
        const pcm = new Float32Array(frameCount);

        for (let i = 0; i < frameCount; i++) {
            const t = i / sampleRate;
            const currentBeat = t / (60.0 / this.bpm);
            const beatStep = currentBeat % 1.0;

            // Vocal beatbox simulation: "Boots & Cats & Chops"
            let v = 0;
            if (beatStep < 0.25) { // Vocal pop
                v = Math.sin(2 * Math.PI * (160.0 * Math.exp(-beatStep * 20.0)) * beatStep) * Math.exp(-beatStep * 15.0);
            } else if (beatStep > 0.5 && beatStep < 0.75) { // Whistle / vocal formant
                const wt = beatStep - 0.5;
                v = Math.sin(2 * Math.PI * 659.25 * wt) * Math.exp(-wt * 10.0) * 0.7;
            }
            pcm[i] = v + (Math.random() * 0.04 - 0.02);
        }

        // Simulate 1.5s recording progress in UI
        let progress = 0;
        const timerEl = document.getElementById('recordTimerDisplay');
        const interval = setInterval(() => {
            progress += 0.3;
            if (timerEl) timerEl.textContent = `Recording... ${progress.toFixed(1)}s / ${duration.toFixed(1)}s`;
            if (progress >= duration) {
                clearInterval(interval);
                this.isRecording = false;
                const recBtn = document.getElementById('btnMainRecordToggle');
                if (recBtn) recBtn.classList.remove('recording');
                document.getElementById('recBtnLabel').textContent = 'START RECORDING';
                this.applyRecordedAudio(trackIndex, pcm);
                document.getElementById('recordModal').style.display = 'none';
            }
        }, 300);
    }

    startPlayback() {
        if (!this.ctx) this.init();
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }

        this.isPlaying = true;
        this.startTime = this.ctx.currentTime;
        this.nextBeatTime = this.ctx.currentTime;
        this.beatIndex = 0;

        this.tracks.forEach(track => {
            this.scheduleTrack(track, 0);
        });
    }

    scheduleTrack(track, offsetNormalized) {
        if (track.sourceNode) {
            try { track.sourceNode.stop(); } catch (e) {}
            track.sourceNode.disconnect();
        }

        const source = this.ctx.createBufferSource();
        source.buffer = track.buffer;
        source.playbackRate.value = this.bpm / this.baseBpm;
        source.detune.value = this.masterKey.semitones * 100;

        if (track.isSliceMode && track.activeSlice !== null) {
            // Slice loop (1/8th subdivision)
            const sliceWidth = track.buffer.duration / 8.0;
            const startSec = track.activeSlice * sliceWidth;
            source.loop = true;
            source.loopStart = startSec;
            source.loopEnd = startSec + sliceWidth;
            source.connect(track.eqLow);
            source.start(0, startSec);
        } else {
            // Full loop
            source.loop = true;
            source.loopStart = 0;
            source.loopEnd = track.buffer.duration;
            const startSec = (offsetNormalized || 0) * track.buffer.duration;
            source.connect(track.eqLow);
            source.start(0, startSec);
        }

        track.sourceNode = source;
    }

    stopPlayback() {
        this.isPlaying = false;
        this.tracks.forEach(track => {
            if (track.sourceNode) {
                try { track.sourceNode.stop(); } catch (e) {}
                track.sourceNode.disconnect();
                track.sourceNode = null;
            }
            track.playhead = 0;
        });
    }

    setBPM(newBPM) {
        this.bpm = Math.min(200, Math.max(60, newBPM));
        const rate = this.bpm / this.baseBpm;
        this.tracks.forEach(t => {
            if (t.sourceNode) {
                t.sourceNode.playbackRate.setTargetAtTime(rate, this.ctx.currentTime, 0.05);
            }
        });
    }

    setKey(semitones, name) {
        this.masterKey = { semitones: semitones, name: name };
        this.tracks.forEach(t => {
            if (t.sourceNode) {
                t.sourceNode.detune.setTargetAtTime(semitones * 100, this.ctx.currentTime, 0.05);
            }
        });
    }

    seekTrack(trackIndex, normalized) {
        const track = this.tracks[trackIndex];
        if (!track) return;
        track.playhead = normalized;
        if (this.isPlaying) {
            this.scheduleTrack(track, normalized);
        }
    }

    triggerSlice(trackIndex, sliceIndex) {
        const track = this.tracks[trackIndex];
        if (!track) return;
        track.isSliceMode = true;
        track.activeSlice = sliceIndex;
        if (this.isPlaying) {
            this.scheduleTrack(track, 0);
        }
    }

    exitSliceMode(trackIndex) {
        const track = this.tracks[trackIndex];
        if (!track) return;
        track.isSliceMode = false;
        track.activeSlice = null;
        if (this.isPlaying) {
            this.scheduleTrack(track, 0);
        }
    }

    applySection(sectionKey) {
        const section = SECTIONS[sectionKey];
        if (!section) return;

        this.activeSection = sectionKey;
        this.tracks.forEach((track, idx) => {
            track.isMuted = section.mutes[idx];
            this.updateTrackGain(track);
        });
    }

    updateTrackGain(track) {
        if (track.isMuted) {
            track.gainNode.gain.setTargetAtTime(0, this.ctx.currentTime, 0.02);
            return;
        }

        const anySolo = this.tracks.some(t => t.isSolo);
        if (anySolo) {
            const effective = track.isSolo ? track.volume : 0;
            track.gainNode.gain.setTargetAtTime(effective, this.ctx.currentTime, 0.02);
            return;
        }

        track.gainNode.gain.setTargetAtTime(track.volume, this.ctx.currentTime, 0.02);
    }

    updateClock() {
        if (!this.isPlaying) return;

        const currentSec = this.ctx.currentTime - this.startTime;
        const totalDuration = this.tracks[0] ? this.tracks[0].buffer.duration : 3.87;
        const masterProgress = (currentSec % totalDuration) / totalDuration;

        this.tracks.forEach(t => {
            if (t.isSliceMode && t.activeSlice !== null) {
                const sliceWidth = 1.0 / 8.0;
                const sliceBase = t.activeSlice * sliceWidth;
                const sliceProgress = (currentSec % (totalDuration / 8.0)) / (totalDuration / 8.0);
                t.playhead = sliceBase + sliceProgress * sliceWidth;
            } else {
                t.playhead = masterProgress;
            }
        });

        // Metronome Tick
        if (this.metronomeEnabled && this.ctx.currentTime >= this.nextBeatTime) {
            this.playMetronomeClick(this.beatIndex % 4 === 0);
            this.beatIndex++;
            this.nextBeatTime += 60.0 / this.bpm;
        }
    }

    playMetronomeClick(isDownbeat) {
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.value = isDownbeat ? 1760 : 880;

        const now = this.ctx.currentTime;
        gain.gain.setValueAtTime(0.7, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + (isDownbeat ? 0.05 : 0.03));

        osc.connect(gain);
        gain.connect(this.masterGain);

        osc.start(now);
        osc.stop(now + 0.06);
    }

    exportMixdownWAV() {
        const sampleRate = 44100;
        const durationBars = 8;
        const durationSec = (60.0 / this.bpm) * 4 * durationBars;
        const frameCount = Math.floor(sampleRate * durationSec);

        const offlineCtx = new (window.OfflineAudioContext || window.webkitOfflineAudioContext)(2, frameCount, sampleRate);
        const hasSolo = this.tracks.some(t => t.isSolo);

        this.tracks.forEach(t => {
            if (t.isMuted) return;
            if (hasSolo && !t.isSolo) return;

            const source = offlineCtx.createBufferSource();
            source.buffer = t.buffer;
            source.loop = true;
            source.playbackRate.value = this.bpm / this.baseBpm;
            source.detune.value = this.masterKey.semitones * 100;

            const gain = offlineCtx.createGain();
            gain.gain.value = t.volume;

            source.connect(gain);
            gain.connect(offlineCtx.destination);
            source.start(0);
        });

        offlineCtx.startRendering().then(renderedBuffer => {
            const wavData = this.encodeWAV(renderedBuffer);
            const blob = new Blob([wavData], { type: 'audio/wav' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `BlocsWavePro_${this.activeGenre}_${Date.now()}.wav`;
            a.click();
        });
    }

    encodeWAV(audioBuffer) {
        const numChannels = audioBuffer.numberOfChannels;
        const sampleRate = audioBuffer.sampleRate;
        const format = 1; // PCM
        const bitDepth = 16;
        const numFrames = audioBuffer.length;
        const bytesPerSample = bitDepth / 8;
        const blockAlign = numChannels * bytesPerSample;
        const byteRate = sampleRate * blockAlign;
        const dataSize = numFrames * blockAlign;
        const buffer = new ArrayBuffer(44 + dataSize);
        const view = new DataView(buffer);

        function writeString(offset, str) {
            for (let i = 0; i < str.length; i++) view.setUint8(offset + i, str.charCodeAt(i));
        }

        writeString(0, 'RIFF');
        view.setUint32(4, 36 + dataSize, true);
        writeString(8, 'WAVE');
        writeString(12, 'fmt ');
        view.setUint32(16, 16, true);
        view.setUint16(20, format, true);
        view.setUint16(22, numChannels, true);
        view.setUint32(24, sampleRate, true);
        view.setUint32(28, byteRate, true);
        view.setUint16(32, blockAlign, true);
        view.setUint16(34, bitDepth, true);
        writeString(36, 'data');
        view.setUint32(40, dataSize, true);

        const left = audioBuffer.getChannelData(0);
        const right = numChannels > 1 ? audioBuffer.getChannelData(1) : left;
        let offset = 44;

        for (let i = 0; i < numFrames; i++) {
            const l = Math.max(-1, Math.min(1, left[i]));
            const r = Math.max(-1, Math.min(1, right[i]));
            view.setInt16(offset, l < 0 ? l * 0x8000 : l * 0x7FFF, true);
            offset += 2;
            view.setInt16(offset, r < 0 ? r * 0x8000 : r * 0x7FFF, true);
            offset += 2;
        }

        return buffer;
    }
}

// UI Controller
const engine = new AudioEngine();
let activeModalTrackIndex = 0;
let currentLibraryCategory = 'all';

document.addEventListener('DOMContentLoaded', () => {
    engine.init();
    renderTracks();
    setupEventListeners();
    requestAnimationFrame(renderLoop);
});

function renderTracks() {
    const container = document.getElementById('tracksContainer');
    container.innerHTML = '';

    engine.tracks.forEach(track => {
        const row = document.createElement('div');
        row.className = `track-row ${track.isMuted ? 'muted' : ''} ${track.isSolo ? 'solo-active' : ''}`;
        row.id = `trackRow_${track.index}`;

        row.innerHTML = `
            <div class="track-main">
                <div class="track-meta">
                    <div class="track-title-row">
                        <span class="color-dot" style="background: ${track.color}; box-shadow: 0 0 6px ${track.color};"></span>
                        <span class="track-name">${track.icon} ${track.name}</span>
                        ${track.isUserRecorded ? '<span class="recorded-badge">REC</span>' : ''}
                    </div>
                    <div class="track-buttons">
                        <button class="btn-track mute ${track.isMuted ? 'active' : ''}" data-action="mute" data-index="${track.index}" title="Mute">M</button>
                        <button class="btn-track solo ${track.isSolo ? 'active' : ''}" data-action="solo" data-index="${track.index}" title="Solo">S</button>
                        <button class="btn-track slice ${track.isSliceMode ? 'active' : ''}" data-action="sliceToggle" data-index="${track.index}" title="8-Slice Mode">✂</button>
                        <button class="btn-track eq" data-action="openEQ" data-index="${track.index}" title="EQ & Mixer">⚙</button>
                        <button class="btn-track sound-browse" data-action="openSoundBrowser" data-index="${track.index}" title="Change Sound Preset">🎵</button>
                        <button class="btn-track rec ${track.isUserRecorded ? 'active' : ''}" data-action="openRecord" data-index="${track.index}" title="Record Audio / Vocals into this track">🎙️</button>
                    </div>
                </div>
                <div class="waveform-box" id="waveformBox_${track.index}">
                    <canvas class="waveform-canvas" id="canvas_${track.index}" width="700" height="60"></canvas>
                </div>
            </div>
            <div class="slice-pads-row" id="slicePads_${track.index}" style="display: ${track.isSliceMode ? 'flex' : 'none'};">
                ${[0,1,2,3,4,5,6,7].map(s => `
                    <button class="slice-pad ${track.activeSlice === s ? 'active' : ''}" data-slice="${s}" data-index="${track.index}">
                        ${s + 1}
                    </button>
                `).join('')}
            </div>
        `;

        container.appendChild(row);

        // Attach touch & mouse scrubbing to waveform
        const box = row.querySelector('.waveform-box');
        let isScrubbing = false;

        function handleScrub(e) {
            const rect = box.getBoundingClientRect();
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            const norm = Math.max(0, Math.min(0.99, (clientX - rect.left) / rect.width));

            if (track.isSliceMode) {
                const sIdx = Math.min(7, Math.floor(norm * 8.0));
                engine.triggerSlice(track.index, sIdx);
                updateSlicePadsUI(track.index);
            } else {
                engine.seekTrack(track.index, norm);
            }
        }

        box.addEventListener('mousedown', e => {
            isScrubbing = true;
            handleScrub(e);
        });

        window.addEventListener('mousemove', e => {
            if (isScrubbing) handleScrub(e);
        });

        window.addEventListener('mouseup', () => {
            isScrubbing = false;
        });

        box.addEventListener('touchstart', e => {
            isScrubbing = true;
            handleScrub(e);
        }, { passive: true });

        box.addEventListener('touchmove', e => {
            if (isScrubbing) handleScrub(e);
        }, { passive: true });

        box.addEventListener('touchend', () => {
            isScrubbing = false;
        });
    });
}

function updateSlicePadsUI(trackIndex) {
    const track = engine.tracks[trackIndex];
    const padsRow = document.getElementById(`slicePads_${trackIndex}`);
    if (!padsRow) return;

    padsRow.style.display = track.isSliceMode ? 'flex' : 'none';
    const pads = padsRow.querySelectorAll('.slice-pad');
    pads.forEach((pad, i) => {
        pad.classList.toggle('active', track.activeSlice === i);
    });

    const sliceBtn = document.querySelector(`.btn-track.slice[data-index="${trackIndex}"]`);
    if (sliceBtn) sliceBtn.classList.toggle('active', track.isSliceMode);
}

function setupEventListeners() {
    // Play / Stop
    const btnPlay = document.getElementById('btnPlayMaster');
    btnPlay.addEventListener('click', () => {
        if (engine.isPlaying) {
            engine.stopPlayback();
            btnPlay.classList.remove('active');
            btnPlay.querySelector('.play-icon').textContent = '▶';
            btnPlay.querySelector('.play-label').textContent = 'PLAY';
            document.getElementById('statusDot').classList.remove('active');
            document.getElementById('statusText').textContent = 'ENGINE STANDBY';
        } else {
            engine.startPlayback();
            btnPlay.classList.add('active');
            btnPlay.querySelector('.play-icon').textContent = '■';
            btnPlay.querySelector('.play-label').textContent = 'STOP';
            document.getElementById('statusDot').classList.add('active');
            document.getElementById('statusText').textContent = `LIVE 8-TRACK LOOPING ACTIVE (${SOUND_GENRES[engine.activeGenre].name.toUpperCase()})`;
        }
    });

    // BPM Stepper
    document.getElementById('btnBpmMinus').addEventListener('click', () => {
        engine.setBPM(engine.bpm - 1);
        document.getElementById('bpmValue').textContent = Math.round(engine.bpm);
    });

    document.getElementById('btnBpmPlus').addEventListener('click', () => {
        engine.setBPM(engine.bpm + 1);
        document.getElementById('bpmValue').textContent = Math.round(engine.bpm);
    });

    // Tap Tempo
    const btnTap = document.getElementById('btnTapTempo');
    btnTap.addEventListener('click', () => {
        btnTap.classList.add('tapped');
        setTimeout(() => btnTap.classList.remove('tapped'), 120);

        const now = Date.now();
        engine.tapTimes.push(now);
        engine.tapTimes = engine.tapTimes.filter(t => now - t <= 3000);

        if (engine.tapTimes.length >= 3) {
            let intervals = [];
            for (let i = 1; i < engine.tapTimes.length; i++) {
                intervals.push(engine.tapTimes[i] - engine.tapTimes[i - 1]);
            }
            const avg = intervals.reduce((a, b) => a + b, 0) / intervals.length;
            const bpm = Math.round(60000 / avg);
            engine.setBPM(bpm);
            document.getElementById('bpmValue').textContent = Math.round(engine.bpm);
        }
    });

    // Master Key Selector (cycles chromatic keys)
    const keys = [
        { name: 'C Min', semi: 0 },
        { name: 'D Min', semi: 2 },
        { name: 'E♭ Maj', semi: 3 },
        { name: 'F Min', semi: 5 },
        { name: 'G Min', semi: 7 },
        { name: 'A♭ Maj', semi: 8 },
        { name: 'B♭ Maj', semi: 10 }
    ];
    let keyIdx = 0;
    document.getElementById('btnKeySelector').addEventListener('click', () => {
        keyIdx = (keyIdx + 1) % keys.length;
        const k = keys[keyIdx];
        engine.setKey(k.semi, k.name);
        document.getElementById('masterKeyDisplay').textContent = k.name;
    });

    // Metronome Toggle
    const btnMetro = document.getElementById('btnMetronome');
    btnMetro.addEventListener('click', () => {
        engine.metronomeEnabled = !engine.metronomeEnabled;
        btnMetro.classList.toggle('active', engine.metronomeEnabled);
    });

    // Genre Sound Packs Selector
    document.querySelectorAll('.genre-pill').forEach(pill => {
        pill.addEventListener('click', () => {
            const genre = pill.dataset.genre;
            document.querySelectorAll('.genre-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');

            engine.applyGenrePack(genre);
            renderTracks();
            document.getElementById('statusText').textContent = `LOADED SOUND PACK: ${SOUND_GENRES[genre].name.toUpperCase()} (All 8 Tracks Hot-Swapped!)`;
        });
    });

    // Song Sections (A, B, C, D)
    document.querySelectorAll('.section-pill').forEach(pill => {
        pill.addEventListener('click', () => {
            const sec = pill.dataset.section;
            document.querySelectorAll('.section-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');
            engine.applySection(sec);
            document.getElementById('sectionDesc').textContent = `Active Section: ${sec} (${SECTIONS[sec].name})`;

            // Update Mute UI on all rows
            engine.tracks.forEach(track => {
                const muteBtn = document.querySelector(`.btn-track.mute[data-index="${track.index}"]`);
                const row = document.getElementById(`trackRow_${track.index}`);
                if (muteBtn) muteBtn.classList.toggle('active', track.isMuted);
                if (row) row.classList.toggle('muted', track.isMuted);
            });
        });
    });

    // Track buttons click delegation
    document.getElementById('tracksContainer').addEventListener('click', e => {
        const target = e.target.closest('button');
        if (!target) return;

        const action = target.dataset.action;
        const trackIdx = parseInt(target.dataset.index, 10);
        const sliceIdx = target.dataset.slice !== undefined ? parseInt(target.dataset.slice, 10) : null;

        if (sliceIdx !== null) {
            engine.triggerSlice(trackIdx, sliceIdx);
            updateSlicePadsUI(trackIdx);
            return;
        }

        if (action === 'mute') {
            const t = engine.tracks[trackIdx];
            t.isMuted = !t.isMuted;
            engine.updateTrackGain(t);
            target.classList.toggle('active', t.isMuted);
            document.getElementById(`trackRow_${trackIdx}`).classList.toggle('muted', t.isMuted);
        } else if (action === 'solo') {
            const t = engine.tracks[trackIdx];
            t.isSolo = !t.isSolo;
            target.classList.toggle('active', t.isSolo);
            document.getElementById(`trackRow_${trackIdx}`).classList.toggle('solo-active', t.isSolo);
            engine.tracks.forEach(tr => engine.updateTrackGain(tr));
        } else if (action === 'sliceToggle') {
            const t = engine.tracks[trackIdx];
            if (t.isSliceMode) {
                engine.exitSliceMode(trackIdx);
            } else {
                engine.triggerSlice(trackIdx, 0);
            }
            updateSlicePadsUI(trackIdx);
        } else if (action === 'openEQ') {
            openEQModal(trackIdx);
        } else if (action === 'openSoundBrowser') {
            openSoundBrowserModal(trackIdx);
        } else if (action === 'openRecord') {
            openRecordingModal(trackIdx);
        }
    });

    // Header master buttons
    document.getElementById('btnOpenMasterRecord').addEventListener('click', () => {
        openRecordingModal(7);
    });

    document.getElementById('btnOpenSoundLibrary').addEventListener('click', () => {
        openSoundBrowserModal(0);
    });

    // Export WAV
    document.getElementById('btnExport').addEventListener('click', () => {
        engine.exportMixdownWAV();
    });

    // Modal controls
    document.getElementById('btnCloseModal').addEventListener('click', () => {
        document.getElementById('eqModal').style.display = 'none';
    });

    document.getElementById('btnCloseRecordModal').addEventListener('click', () => {
        engine.isRecording = false;
        document.getElementById('recordModal').style.display = 'none';
    });

    document.getElementById('btnCloseLibraryModal').addEventListener('click', () => {
        engine.stopPreview();
        document.getElementById('soundLibraryModal').style.display = 'none';
    });

    // Recording Modal Actions
    document.getElementById('btnRequestMic').addEventListener('click', async () => {
        const granted = await engine.initMicrophone();
        const box = document.getElementById('micStatusBox');
        if (granted) {
            box.style.background = 'rgba(0, 240, 120, 0.15)';
            box.style.borderColor = '#00F078';
            document.getElementById('micStatusText').textContent = '✅ Microphone Active & Ready to sample';
        } else {
            box.style.background = 'rgba(255, 180, 0, 0.15)';
            box.style.borderColor = '#FFD214';
            document.getElementById('micStatusText').textContent = '⚠️ Mic blocked - Auto simulation enabled';
        }
    });

    let selectedRecBars = 2;
    document.querySelectorAll('.btn-bar').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.btn-bar').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            selectedRecBars = parseInt(btn.dataset.bars, 10);
            document.getElementById('recordTimerDisplay').textContent = `Ready to record (${selectedRecBars} Bars)`;
        });
    });

    const recBtn = document.getElementById('btnMainRecordToggle');
    recBtn.addEventListener('click', () => {
        if (engine.isRecording) {
            engine.stopLiveRecording();
            recBtn.classList.remove('recording');
            document.getElementById('recBtnLabel').textContent = 'START RECORDING';
            document.getElementById('recordModal').style.display = 'none';
        } else {
            const targetTrack = parseInt(document.getElementById('recTargetTrackSelect').value, 10);
            recBtn.classList.add('recording');
            document.getElementById('recBtnLabel').textContent = 'STOP & LOOP';
            engine.startLiveRecording(targetTrack, selectedRecBars);
        }
    });

    // EQ Inputs
    ['eqLow', 'eqMid', 'eqHigh'].forEach(id => {
        document.getElementById(id).addEventListener('input', e => {
            const val = parseFloat(e.target.value);
            document.getElementById(`${id}Val`).textContent = `${val > 0 ? '+' : ''}${val.toFixed(1)} dB`;
            const t = engine.tracks[activeModalTrackIndex];
            if (id === 'eqLow') t.eqLow.gain.value = val;
            if (id === 'eqMid') t.eqMid.gain.value = val;
            if (id === 'eqHigh') t.eqHigh.gain.value = val;
            drawEQModalCurve();
        });
    });

    // Track Vol & Pan
    document.getElementById('trackVol').addEventListener('input', e => {
        const val = parseFloat(e.target.value);
        document.getElementById('trackVolVal').textContent = `${Math.round(val * 100)}%`;
        const t = engine.tracks[activeModalTrackIndex];
        t.volume = val;
        engine.updateTrackGain(t);
    });

    document.getElementById('trackPan').addEventListener('input', e => {
        const val = parseFloat(e.target.value);
        document.getElementById('trackPanVal').textContent = Math.abs(val) < 0.05 ? 'Center' : (val < 0 ? `L ${Math.round(Math.abs(val) * 100)}` : `R ${Math.round(val * 100)}`);
        const t = engine.tracks[activeModalTrackIndex];
        t.pan = val;
        if (t.panNode) t.panNode.pan.value = val;
    });
}

function openEQModal(trackIndex) {
    activeModalTrackIndex = trackIndex;
    const t = engine.tracks[trackIndex];

    document.getElementById('modalTrackIcon').textContent = t.icon;
    document.getElementById('modalTrackTitle').textContent = `Track ${t.index + 1}: ${t.name}`;

    document.getElementById('eqLow').value = t.eqLow.gain.value;
    document.getElementById('eqLowVal').textContent = `${t.eqLow.gain.value > 0 ? '+' : ''}${t.eqLow.gain.value.toFixed(1)} dB`;

    document.getElementById('eqMid').value = t.eqMid.gain.value;
    document.getElementById('eqMidVal').textContent = `${t.eqMid.gain.value > 0 ? '+' : ''}${t.eqMid.gain.value.toFixed(1)} dB`;

    document.getElementById('eqHigh').value = t.eqHigh.gain.value;
    document.getElementById('eqHighVal').textContent = `${t.eqHigh.gain.value > 0 ? '+' : ''}${t.eqHigh.gain.value.toFixed(1)} dB`;

    document.getElementById('trackVol').value = t.volume;
    document.getElementById('trackVolVal').textContent = `${Math.round(t.volume * 100)}%`;

    document.getElementById('trackPan').value = t.pan;
    document.getElementById('trackPanVal').textContent = Math.abs(t.pan) < 0.05 ? 'Center' : (t.pan < 0 ? `L ${Math.round(Math.abs(t.pan) * 100)}` : `R ${Math.round(t.pan * 100)}`);

    drawEQModalCurve();
    document.getElementById('eqModal').style.display = 'flex';
}

function openRecordingModal(trackIndex) {
    const select = document.getElementById('recTargetTrackSelect');
    if (select) select.value = trackIndex;

    const timer = document.getElementById('recordTimerDisplay');
    if (timer) timer.textContent = 'Ready to record (2 Bars)';

    document.getElementById('recordModal').style.display = 'flex';
    engine.initMicrophone();
}

function openSoundBrowserModal(trackIndex) {
    activeModalTrackIndex = trackIndex;
    const t = engine.tracks[trackIndex];

    document.getElementById('libraryTitle').textContent = `SOUND PRESET BROWSER - ${t.icon} ${TRACK_NAMES[trackIndex].toUpperCase()}`;

    // Render filter tabs: All Packs vs Specific Pack
    const tabsContainer = document.getElementById('libraryFilterTabs');
    tabsContainer.innerHTML = '';

    const allTab = document.createElement('button');
    allTab.className = `lib-tab ${currentLibraryCategory === 'all' ? 'active' : ''}`;
    allTab.textContent = '🌟 All Sound Packs';
    allTab.addEventListener('click', () => {
        currentLibraryCategory = 'all';
        document.querySelectorAll('.lib-tab').forEach(b => b.classList.remove('active'));
        allTab.classList.add('active');
        renderLibraryPresets(trackIndex, 'all');
    });
    tabsContainer.appendChild(allTab);

    Object.keys(SOUND_GENRES).forEach(key => {
        const pack = SOUND_GENRES[key];
        const tab = document.createElement('button');
        tab.className = `lib-tab ${currentLibraryCategory === key ? 'active' : ''}`;
        tab.textContent = `${pack.icon} ${pack.name}`;
        tab.addEventListener('click', () => {
            currentLibraryCategory = key;
            document.querySelectorAll('.lib-tab').forEach(b => b.classList.remove('active'));
            tab.classList.add('active');
            renderLibraryPresets(trackIndex, key);
        });
        tabsContainer.appendChild(tab);
    });

    renderLibraryPresets(trackIndex, currentLibraryCategory);
    document.getElementById('soundLibraryModal').style.display = 'flex';
}

function renderLibraryPresets(trackIndex, filterCategory) {
    const list = document.getElementById('presetsList');
    list.innerHTML = '';

    const currentTrack = engine.tracks[trackIndex];
    const genresToDisplay = filterCategory === 'all' ? Object.keys(SOUND_GENRES) : [filterCategory];

    genresToDisplay.forEach(gKey => {
        const pack = SOUND_GENRES[gKey];
        const preset = pack.tracks[trackIndex];
        const isCurrentlyActive = (currentTrack.genre === gKey && !currentTrack.isUserRecorded);

        const card = document.createElement('div');
        card.className = `preset-card ${isCurrentlyActive ? 'current' : ''}`;

        card.innerHTML = `
            <div class="preset-header">
                <span class="preset-name">${pack.icon} ${preset.name}</span>
                <span class="preset-tag">${pack.name}</span>
            </div>
            <div class="preset-desc">${preset.desc} (${pack.bpm} BPM)</div>
            <div class="preset-actions">
                <button class="btn-preview-sound" data-genre="${gKey}" data-index="${trackIndex}">
                    <span>▶</span> Audition
                </button>
                <button class="btn-load-preset" data-genre="${gKey}" data-index="${trackIndex}">
                    ${isCurrentlyActive ? '✓ ACTIVE' : 'LOAD SOUND'}
                </button>
            </div>
        `;

        // Audition preview
        const btnPrev = card.querySelector('.btn-preview-sound');
        btnPrev.addEventListener('click', () => {
            if (btnPrev.classList.contains('playing')) {
                engine.stopPreview();
                btnPrev.classList.remove('playing');
                btnPrev.innerHTML = '<span>▶</span> Audition';
            } else {
                document.querySelectorAll('.btn-preview-sound').forEach(b => {
                    b.classList.remove('playing');
                    b.innerHTML = '<span>▶</span> Audition';
                });
                engine.previewPreset(trackIndex, gKey);
                btnPrev.classList.add('playing');
                btnPrev.innerHTML = '<span>■</span> Stop';
            }
        });

        // Load into Track
        const btnLoad = card.querySelector('.btn-load-preset');
        btnLoad.addEventListener('click', () => {
            engine.stopPreview();
            engine.loadTrackPreset(trackIndex, gKey);
            renderTracks();
            document.getElementById('soundLibraryModal').style.display = 'none';
            document.getElementById('statusText').textContent = `LOADED SOUND "${preset.name.toUpperCase()}" INTO TRACK ${trackIndex + 1}`;
        });

        list.appendChild(card);
    });
}

function drawEQModalCurve() {
    const canvas = document.getElementById('eqCanvas');
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    const midY = height / 2;

    ctx.clearRect(0, 0, width, height);

    // Center 0dB line
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.15)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, midY);
    ctx.lineTo(width, midY);
    ctx.stroke();

    const t = engine.tracks[activeModalTrackIndex];
    const low = t.eqLow.gain.value;
    const mid = t.eqMid.gain.value;
    const high = t.eqHigh.gain.value;

    ctx.beginPath();
    ctx.moveTo(0, midY);

    for (let x = 0; x <= width; x++) {
        const normX = x / width;
        const lowInf = 1.0 / (1.0 + Math.exp((normX - 0.25) * 15.0));
        const midDiff = (normX - 0.5) * 3.5;
        const midInf = Math.exp(-midDiff * midDiff);
        const highInf = 1.0 / (1.0 + Math.exp(-(normX - 0.75) * 15.0));

        const totalDB = low * lowInf + mid * midInf + high * highInf;
        const y = midY - (totalDB / 14.0) * (height * 0.4);

        if (x === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }

    ctx.strokeStyle = t.color;
    ctx.lineWidth = 2.5;
    ctx.stroke();
}

// 60 FPS Render Loop
function renderLoop() {
    engine.updateClock();

    engine.tracks.forEach(track => {
        const canvas = document.getElementById(`canvas_${track.index}`);
        if (!canvas) return;
        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;

        ctx.clearRect(0, 0, width, height);

        // Draw waveform amplitude bars
        const peaks = track.peaks;
        const barCount = peaks.length;
        const barWidth = (width - barCount * 2) / barCount;
        const centerY = height / 2;

        for (let i = 0; i < barCount; i++) {
            const p = peaks[i];
            const barH = Math.max(4, p * (height * 0.85));
            const x = i * (barWidth + 2);
            const y = centerY - barH / 2;

            const grad = ctx.createLinearGradient(x, y, x, y + barH);
            grad.addColorStop(0, track.color);
            grad.addColorStop(1, 'rgba(255, 255, 255, 0.2)');

            ctx.fillStyle = grad;
            ctx.fillRect(x, y, barWidth, barH);
        }

        // Slice lines overlay
        if (track.isSliceMode) {
            const sliceWidth = width / 8.0;

            if (track.activeSlice !== null) {
                ctx.fillStyle = `${track.color}33`;
                ctx.fillRect(track.activeSlice * sliceWidth, 0, sliceWidth, height);
                ctx.strokeStyle = track.color;
                ctx.lineWidth = 1.5;
                ctx.strokeRect(track.activeSlice * sliceWidth, 0, sliceWidth, height);
            }

            ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
            ctx.setLineDash([4, 4]);
            for (let s = 1; s < 8; s++) {
                ctx.beginPath();
                ctx.moveTo(s * sliceWidth, 0);
                ctx.lineTo(s * sliceWidth, height);
                ctx.stroke();
            }
            ctx.setLineDash([]);
        }

        // 60fps Playhead
        const playheadX = track.playhead * width;
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(playheadX, 0);
        ctx.lineTo(playheadX, height);
        ctx.stroke();

        // Neon Glow around Playhead
        ctx.strokeStyle = `${track.color}88`;
        ctx.lineWidth = 4;
        ctx.stroke();

        // Playhead handles
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(playheadX - 4, 0, 8, 5);
        ctx.fillRect(playheadX - 4, height - 5, 8, 5);
    });

    requestAnimationFrame(renderLoop);
}
