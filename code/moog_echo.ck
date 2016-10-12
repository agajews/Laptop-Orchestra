// FM synthesis by hand

// carrier
Moog c => PRCRev n => dac;
1.0 => c.noteOn;

// carrier frequency
440 => float cf;

// time-loop
0 => int i;
while( true ) {
    Math.random2( 50, 70 ) => Std.mtof => c.freq;
    1 => c.noteOn;
    200::ms => now;
    1 => c.noteOff;
    200::ms => now;
    i++;
}