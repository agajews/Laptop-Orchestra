adc => DelayL d => PitShift p => dac;

.5::second => d.max => d.delay;
1 => p.shift;

while(true){
	1000::ms => now;
}
