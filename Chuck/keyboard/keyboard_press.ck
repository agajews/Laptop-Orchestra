KBHit kb;

fun void playNote(int note){
    SinOsc s => ADSR env => dac;
    env.set(10::ms, 8::ms, .5, 300::ms);
    note => Std.mtof => s.freq;
    1 => env.keyOn;
    1::second => now;
    1 => env.keyOff;
    1::second => now;
    s =< env =< dac;
    me.exit();
}
while(true){
	kb => now;
	while(kb.more()){
        kb.getchar() => int c;
		spork ~ playNote(c - 30);
	}
}
