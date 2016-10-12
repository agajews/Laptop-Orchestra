// FM synthesis by hand

// carrier
SinOsc c => Echo e => dac;
0.1 => e.mix;

// carrier frequency
220 => float cf;

// time-loop
0 => int i;
while( true ) {
    (cf + i) % 1000 => c.freq;
    i++;
    0.1::ms => now;
}