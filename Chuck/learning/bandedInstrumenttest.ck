BandedWG b => dac;

0 => b.preset;

//50 => Std.mtof => b.freq;
440 => b.freq;

while(true){
    1.0 => b.bowPressure;
    .5 => b.bowRate;
    0.2 => b.strikePosition;

    1.0 => b.pluck;
    .1::second => now;
    1.0 => b.startBowing;
    1::second => now;
    1.0 => b.stopBowing;
    1::second => now;
}
