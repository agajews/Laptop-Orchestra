// FM synthesis by hand

// carrier
BlowBotl c => dac;
1.5 => c.noteOn;
1.0 => c.startBlowing;
1.0 => c.vibratoGain;
0.1 => c.noiseGain;

// carrier frequency
440 => float cf;

// time-loop
0 => int i;
while( true ) {
    cf => c.freq;
    i++;
    0.1::ms => now;
}