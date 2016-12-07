fun Hid initjoystick() {
    Hid trak;
    trak.openJoystick(0);
    <<<"Joystick " + trak.name() + " ready!">>>;
    return trak;
}

class GameTrak {
    time lastTime;
    time currTime;

    float rx;
    float ry;
    float rz;
    float lx;
    float ly;
    float lz;

    int pedal;

    int right_cross;
    int left_cross;

    float velocity[1000];
    0 => int vhead;
}

fun void gtupdate(GameTrak gt, Hid trak) {
    HidMsg msg;
    0.0 => float last_rx;
    0.0 => float last_ry;
    0.0 => float last_rz;
    0.0 => float last_lx;
    0.0 => float last_ly;
    0.0 => float last_lz;
    0.0 => float ldisplacement;
    0.0 => float rdisplacement;
    while (true) {
        // wait for event
        trak => now;
        gt.currTime => gt.lastTime;
        now => gt.currTime;

        while (trak.recv(msg)) {
            if (msg.which >= 0 && msg.which < 6) {
                if (msg.which == 0) {gt.lx => last_lx; msg.axisPosition => gt.lx;}
                if (msg.which == 1) {gt.ly => last_ly; msg.axisPosition => gt.ly;}
                if (msg.which == 2) {gt.lz => last_lz; 1 - msg.axisPosition => gt.lz;}
                if (msg.which == 3) {gt.rx => last_rx; msg.axisPosition => gt.rx;}
                if (msg.which == 4) {gt.ry => last_ry; msg.axisPosition => gt.ry;}
                if (msg.which == 5) {gt.rz => last_rz; 1 - msg.axisPosition => gt.rz;}
            } else if (msg.isButtonDown()) {
                1 => gt.pedal;
            } else if (msg.isButtonUp()) {
                0 => gt.pedal;
            }
            Math.sqrt( Math.pow((gt.lx - last_lx),2) + Math.pow((gt.ly - last_ly),2) + Math.pow((gt.lz - last_lz),2) ) => ldisplacement;
            Math.sqrt( Math.pow((gt.rx - last_rx),2) + Math.pow((gt.ry - last_ry),2) + Math.pow((gt.rz - last_rz),2) ) => rdisplacement;
            ldisplacement/((gt.currTime - gt.lastTime) / 1::second) + rdisplacement/((gt.currTime - gt.lastTime) / 1::second) => gt.velocity[gt.vhead];
            <<<gt.velocity[0], gt.velocity[50], gt.velocity[90]>>>;
            1+=> gt.vhead;
            if (gt.vhead == gt.velocity.cap()){0 => gt.vhead;};
            /*<<<gt.velocity>>>;*/
        }
    }
}

initjoystick() @=> Hid trak;
GameTrak gt;
for( 0 => int i; i < gt.velocity.cap(); i++ ){
    .5 => gt.velocity[i];
}

spork ~ gtupdate(gt, trak);

SinOsc s => Gain g => dac;
0.5 => g.gain;
60 => Std.mtof => s.freq;

while(true){
    0 => float totV;
    for( 0 => int i; i < gt.velocity.cap(); i++ ){
        gt.velocity[i]/gt.velocity.cap() + totV => totV;
    }
    /*<<<totV/10>>>;*/
    /*(gt.velocity/20 - g.gain()) => float delta;*/
    /*<<<delta>>>;*/
    /*g.gain() + delta => g.gain;*/
    totV/10 => g.gain;
    10::ms => now;
}
/////////Make more smooth by using deltas instead of jumping to the new gain
