// FM synthesis by hand

// carrier
Phasor c => dac;

// carrier frequency
220 => float cf;

// time-loop
0 => int i;
while( true ) {
    cf + i => c.freq;
    i++;
    0.1::ms => now;
}