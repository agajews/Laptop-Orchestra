SinOsc s => dac;

1000 => s.freq;

while(true){
	//1000 => s.freq;
	//Uncomment the line below and comment out the line above while running
	500 => s.freq;
	1::second => now;
}
