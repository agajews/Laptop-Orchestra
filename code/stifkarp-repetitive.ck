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
40.0 => float xdeg;
40.0 => float ydeg;
5.0 => float xoff;
5.0 => float yoff;
25.0 => float rzoff;
27.5 => float lzoff;
9.0 => float xsplit;
1.0 / 100.0 => float height_freq_off;
0.1 => float y_cap;
21.0 => float dist_min;

fun float mod_deg(float deg, float off) {
    if (deg > 0) {
        return deg + off;
    } else if (deg < 0) {
        return deg - off;
    } else {
        return deg;
    }
}

fun float deg_to_rad(float deg) {
    return deg / 180 * Math.PI;
}

fun float calc_height(float gt_x, float gt_y, float gt_z, float zoff) {
    mod_deg(gt_x * xdeg / 2.0, xoff) => float x;
    mod_deg(gt_y * ydeg / 2.0, yoff) => float y;
    gt_z / zpi + zoff => float z;
    z * Math.cos(deg_to_rad(x)) => float height;
    return height;
}

fun float calc_distance(float gt_x, float gt_y, float gt_z, float zoff) {
    mod_deg(gt_x * xdeg / 2.0, xoff) => float x;
    mod_deg(gt_y * ydeg / 2.0, yoff) => float y;
    gt_z / zpi + zoff => float z;
    z * Math.sin(deg_to_rad(x)) => float distance;
    return distance;
}

// StifKarp karp => dac;
// 0.9 => karp.pickupPosition;
// // Math.random2f( 0, 1 ) => karp.pickupPosition;
// 0.9 => karp.sustain;
// // Math.random2f( 0, 1 ) => karp.sustain;
// // 0.0 => karp.stretch;
// // Math.random2f( 0, 1 ) => karp.stretch;

Sitar rhodey => dac;

[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] @=> int chromscale[];
[0, 2, 4, 5, 7, 9, 11] @=> int majscale[];
[0, 3, 5, 6, 7, 10] @=> int bluescale[];

60 => int key;
majscale @=> int scale[];

fun void play_note(float note) {
    note => Std.mtof => rhodey.freq;
    0.5 => rhodey.noteOn;
    // Math.random2f(0.6, 0.9) => karp.pluck;
}

fun float calc_note(float height) {
    // return height / 2.0 + 50 $ int;
    height * 24 + key => float fpitch;
    fpitch $ int => int pitch;
    (pitch - key) / 12 $ int => int octave;
    (pitch - octave * 12) % 12 => int note;
    -1 => int folded_note;
    for (0 => int i; i < scale.size(); i++) {
        if (scale[i] > note) {
            scale[i - 1] => folded_note;
            break;
        }
    }
    if (folded_note == -1) {
        scale[scale.size() - 1] => folded_note;
    }
    key + octave * 12 + folded_note => int folded_pitch;
    <<<fpitch, folded_pitch>>>;
    return folded_pitch $ float;
}

while (true) {
    gt.rz => float rheight;
    gt.lz => float lheight;

    calc_note(rheight) => float rnote;
    // calc_note(lheight) => float lnote;
    // <<<gt.ly, rnote>>>;

    // if (gt.ly > y_cap && !gt.right_cross) {
    //     play_note(rnote);
    //     true => gt.right_cross;
    // } else if (gt.ly <= y_cap && gt.right_cross) {
    //     play_note(rnote);
    //     false => gt.right_cross;
    // }

    <<<gt.lz>>>;
    play_note(rnote);
    8 * Math.pow(2, ((1 - lheight) * 8) $ int) => float diff;
    <<<diff>>>;
    if (diff > 0) {
        diff::ms => now;
    } else {
        3::ms => now;
    }
}