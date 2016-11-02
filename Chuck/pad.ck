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

    float velocity;
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
    while (true) {
        // wait for event
        trak => now;

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
            // Math.sqrt( Math.pow((gt.lx - last_lx),2) + Math.pow((gt.ly - last_ly),2) + Math.pow((gt.lz - last_lz),2) ) => ldisplacement;
            // (gt.currTime - gt.lastTime)/displacement => gt.velocity;
            // <<<ldisplacement>>>;
        }
    }
}

initjoystick() @=> Hid trak;
// GameTrak gt;
// spork ~ gtupdate(gt, trak);
