class Note {
    SinOsc s => ADSR env => dac;
    env.set(10::ms, 8::ms, .5, 300::ms);

    fun static Note Note(int note){
        Note n;
        note => Std.mtof => n.s.freq;
        return n;
    }

    fun void play(){
        1 => env.keyOn;
        while(true){
            1::second => now;
        }
        1 => env.keyOff;
        1::second => now;
        s =< env =< dac;
        me.exit();
    }
}

KBHit kb;
while(true){
    kb => now;
    while(kb.more()){
        kb.getchar() => int c;
        spork ~ Note.Note(c - 30).play();
    }
}
