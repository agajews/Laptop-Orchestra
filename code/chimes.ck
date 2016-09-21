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
}

fun void gtupdate(GameTrak gt, Hid trak) {
    HidMsg msg;
    while (true) {
        // wait for event
        trak => now;

        while (trak.recv(msg)) {
            if (msg.which >= 0 && msg.which < 6) {
                if (msg.which == 0) {msg.axisPosition => gt.lx;}
                if (msg.which == 1) {msg.axisPosition => gt.ly;}
                if (msg.which == 2) {1 - msg.axisPosition => gt.lz;}
                if (msg.which == 3) {msg.axisPosition => gt.rx;}
                if (msg.which == 4) {msg.axisPosition => gt.ry;}
                if (msg.which == 5) {1 - msg.axisPosition => gt.rz;}
            } else if (msg.isButtonDown()) {
                1 => gt.pedal;
            } else if (msg.isButtonUp()) {
                0 => gt.pedal;
            }
        }
    }
}

fun void gtprint(GameTrak gt) {
    while (true) {
        <<<"axes:", gt.rx, gt.ry, gt.rz, gt.lx, gt.ly, gt.lz>>>;
        10::ms => now;
    }
}

initjoystick() @=> Hid trak;
GameTrak gt;
spork ~ gtupdate(gt, trak);
// spork ~ gtprint(gt);

0.0260 => float zpi;
// 0.035 => float xpi;
// 0.037 => float xpi;
0.047 => float xpi;
0.047 => float ixpi;
25 => int zoff;
while (true) {
    Math.sqrt(Math.pow(gt.rz / zpi, 2) -
              Math.pow(gt.rx / ixpi, 2) -
              Math.pow(gt.ry / ixpi, 2)) + zoff => float iheight;
    0.085 * (iheight - 63.5) / 13.0 => float xoff;
    Math.sqrt(Math.pow(gt.rz / zpi, 2) -
              Math.pow(gt.rx / (xpi - xoff), 2) -
              Math.pow(gt.ry / (xpi - xoff), 2)) + zoff => float height;
    <<<gt.rz, gt.rx, gt.ry, iheight, height>>>;
    3::ms => now;
}