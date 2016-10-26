SinOsc s => Chorus c => NRev n=> dac;

500 => s.freq;

while(true){
	1::second => now;
	Std.rand2f(30.0,1000.0) => s.freq;
}
