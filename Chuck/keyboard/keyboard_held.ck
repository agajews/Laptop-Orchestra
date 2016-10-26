class Note {
    0 => float freq;
    0 => int isPlaying;
    ADSR env => dac;
    SinOsc s;
    env.set(10::ms, 8::ms, .5, 300::ms);

    fun static Note Note(int note){
        Note n;
        0 => n.isPlaying;
        note => Std.mtof => n.freq;
        return n;
    }

    fun void play(){
        s => env;
        freq => s.freq;
        1 => env.keyOn;
        1 => isPlaying;
        while(true){
            1::second => now;
        }
    }

    fun void stop(){
        1 => env.keyOff;
        0 => isPlaying;
        1::second => now;
        s =< env =< dac;
        me.exit();
    }
}

Hid hi;
HidMsg msg;
0 => int device;
if( !hi.openKeyboard( device ) ) me.exit();

Note held[255];

while(true){
	hi => now;
	while(hi.recv(msg)){
        if(msg.isButtonDown()){
            if(!held[msg.ascii].isPlaying){
                Note.Note(msg.ascii) @=> held[msg.ascii];
                spork ~ held[msg.ascii].play();
            }
        }else{
            spork ~ held[msg.ascii].stop();
        }
	}
}
