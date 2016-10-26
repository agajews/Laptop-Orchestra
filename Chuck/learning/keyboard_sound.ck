//keyboard
//Hid kb;
//HidMsg msg;
KBHit kb;

//if(!kb.openKeyboard(0)) me.exit();

Mandolin m => dac;

while(true){
	kb => now;
	while(kb.more()){
		kb.getchar() => int c;
		<<<"ascii: ", c>>>;
		/*if(c == 97){
			300 => m.freq;
		}else if(c == 115){
			400 => m.freq;
		}else if(c == 100){
			500 => m.freq;
		}else{*/
			c-30 => Std.mtof => m.freq;
		/*}*/
		1 => m.noteOn;
	}
	//0 => m.noteOff;
}
