Rhodey rhodey => dac;
// 0.9 => karp.pickupPosition;
// 0.9 => karp.sustain;
// 0.0 => karp.stretch;

[60, 62, 64, 65, 67, 69, 71, 72] @=> int notes[];
for(0 => int i; i<notes.size(); i++){
    notes[i] => Std.mtof => rhodey.freq;
    0.5 => rhodey.noteOn;
    512::ms => now;
}