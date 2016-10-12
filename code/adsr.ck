// an ADSR envelope
// (also see envelope.ck)
SinOsc s => ADSR e => dac;

// set a, d, s, and r
e.set(10::ms, 8::ms, .5, 300::ms);
// set gain
.5 => s.gain;

// infinite time-loop
while( true )
{
    // choose freq
    Math.random2( 50, 100 ) => Std.mtof => s.freq;

    // key on - start attack
    e.keyOn();
    // advance time by 800 ms
    100::ms => now;
    // key off - start release
    e.keyOff();
    // advance time by 800 ms
    500::ms => now;
}