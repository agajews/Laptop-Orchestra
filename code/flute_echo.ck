// FM synthesis by hand

// carrier
Clarinet c => ADSR a => PRCRev n => dac;
0.5 => c.noteOn;
0.0 => c.startBlowing;
1.0 => c.vibratoGain;
0 => c.vibratoFreq;
0.6 => c.pressure;
0.8 => c.noiseGain;
0.5 => c.reed;

a.set(300::ms, 8::ms, .5, 300::ms);

// carrier frequency
440 => float cf;

// time-loop
0 => int i;
while( true ) {
    Math.random2( 80, 100 ) => Std.mtof => c.freq;
    1 => a.keyOn;
    500::ms => now;
    1 => a.keyOff;
    500::ms => now;
    i++;
}