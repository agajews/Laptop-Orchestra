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

initjoystick() @=> Hid trak;
GameTrak gt;
spork ~ gtupdate(gt, trak);

[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] @=> int chromscale[];
[0, 2, 4, 5, 7, 9, 11] @=> int majscale[];
[0, 3, 5, 6, 7, 10] @=> int bluescale[];

// ==========================================================================
// Select a (midi) key and a scale
80 => int key;
majscale @=> int scale[];

// ==========================================================================
// Your instrument here
Clarinet c => ADSR a => PRCRev n => dac;
0.5 => c.noteOn;
0.0 => c.startBlowing;
1.0 => c.vibratoGain;
0 => c.vibratoFreq;
0.6 => c.pressure;
0.8 => c.noiseGain;
0.5 => c.reed;

// set a, d, s, and r
a.set(300::ms, 8::ms, .5, 300::ms);

fun void play_note(float note) {
    note => Std.mtof => c.freq;
    a.keyOn();
    100::ms => now;
    a.keyOff();
    100::ms => now;
    me.exit();
}
// ==========================================================================

fun float calc_note(float height) {
    height * 24 => float fpitch;
    fpitch $ int => int pitch;
    pitch / scale.size() => int octave;
    pitch % scale.size() => int note;
    key + octave * 12 + scale[note] => int folded_pitch;
    <<<fpitch, folded_pitch>>>;
    return folded_pitch $ float;
}

while (true) {
    gt.rz => float rheight;
    gt.lz => float lheight;
    calc_note(rheight) => float rnote;
    spork ~ play_note(rnote);
    8 * Math.pow(2, (1 - lheight) * 8) => float diff;
    <<<diff>>>;
    if (diff > 0) {
        diff::ms => now;
    } else {
        3::ms => now;
    }
}