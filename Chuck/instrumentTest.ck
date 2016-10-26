//SawOsc s => dac;

//500 => s.freq;
Mandolin s => dac;

1000 => s.freq;
//10 => s.vibratoFreq;
1 => s.noteOn;
//1 => s.startBlowing;
while(true){
	1 => s.noteOn;
	2::second => now;
	0 => s.noteOff;
}
//0 => s.stopBlowing;
.5::second => now;
