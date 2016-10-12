// FM synthesis by hand

// carrier
VoicForm c => PRCRev n => dac;
1.0 => c.noteOn;
31 => c.vibratoFreq;
0 => c.unVoiced;
1 => c.voiced;
1 => c.pitchSweepRate;

// carrier frequency
440 => float cf;
40 => c.freq;

// time-loop
0 => int i;
while( true ) {
    // Math.random2( 50, 70 ) => Std.mtof => c.freq;
    1 => c.noteOn;
    500::ms => now;
    1 => c.noteOff;
    500::ms => now;
    i++;
}