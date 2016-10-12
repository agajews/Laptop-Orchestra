// FM synthesis by hand

// carrier
PulseOsc c => dac;

// carrier frequency
440 => float cf;

// time-loop
0 => int i;
while( true ) {
    cf - 200 * Math.cos(i / 1000.0) + 200 * Math.tan(i / 100000.0) => c.freq;
    i++;
    0.01::ms => now;
}