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

// 6 => bar.preset;
// // Math.random2( 0, 8 ) => bar.preset;
// 0.2 => bar.stickHardness;
// // Math.random2f( 0, 1 ) => bar.stickHardness;
// 0.5 => bar.strikePosition;
// // Math.random2f( 0, 1 ) => bar.strikePosition;
// 0.5 => bar.vibratoGain;
// // Math.random2f( 0, 1 ) => bar.vibratoGain;
// 20 => bar.vibratoFreq;
// // Math.random2f( 0, 60 ) => bar.vibratoFreq;
// // Math.random2f( 0, 1 ) => bar.volume;
// 0.75 => bar.directGain;
// // Math.random2f( .5, 1 ) => bar.directGain;
// 0.75 => bar.masterGain;
// // Math.random2f( .5, 1 ) => bar.masterGain;

VoicForm voc=> JCRev r => dac;

// settings
220.0 => voc.freq;
0.75 => voc.gain;
.8 => r.gain;
.2 => r.mix;
// 10::ms => a.max;
// 7::ms => a.delay;
// .50 => a.mix;

// shred to modulate the mix
// fun void vecho_Shred( )
// {
//     0.0 => float decider;
//     0.0 => float mix;
//     0.0 => float old;
//     0.0 => float inc;
//     0 => int n;

//     // time loop
//     while( true )
//     {
//         Math.random2f(0.0,1.0) => decider;
//         if( decider < .3 ) 0.0 => mix;
//         else if( decider < .6 ) .08 => mix;
//         else if( decider < .8 ) .5 => mix;
//         else .15 => mix;

//         // find the increment
//         (mix-old)/1000.0 => inc;
//         1000 => n;
//         while( n-- )
//         {
//             old + inc => old;
//             old => a.mix => b.mix => c.mix;
//             1::ms => now;
//         }
//         mix => old;
//         Math.random2(2,6)::second => now;
//     }
// }

// let echo shred go
// spork ~ vecho_Shred();
0.5 => voc.loudness;
0.01 => voc.vibratoGain;
2 => voc.phonemeNum;


fun void play_note(float note) {
    // 2 * Math.random2(0,2) => int bphon;
    note $ int => Std.mtof => voc.freq;
    // vol / 100 => voc.volume;
    Math.random2f(0.6, 0.8) => voc.noteOn;
    <<<"Playing", note>>>;
}

// while (true) {
//     calc_height(gt.rx, gt.ry, gt.rz, rzoff) => float rheight;
//     calc_height(gt.lx, gt.ly, gt.lz, lzoff) => float lheight;
//     calc_distance(gt.rx, gt.ry, gt.rz, rzoff) + (xsplit / 2.0) + dist_min => float rdistance;
//     calc_distance(gt.lx, gt.ly, gt.lz, lzoff) - (xsplit / 2.0) + dist_min => float ldistance;
//     // <<<lheight, rheight, ldistance, rdistance>>>;

//     // <<<gt.ly, gt.ry>>>;
//     if (gt.ry > y_cap && !gt.right_cross) {
//         play_note(rdistance, rheight * height_freq_off);
//         true => gt.right_cross;
//     } else if (gt.ry <= y_cap) {
//         false => gt.right_cross;
//     }

//     if (gt.ly > y_cap && !gt.left_cross) {
//         play_note(ldistance, lheight * height_freq_off);
//         true => gt.left_cross;
//     } else if (gt.ly <= y_cap) {
//         false => gt.left_cross;
//     }

//     1::ms => now;
// }

fun float calc_note(float height) {
    return height / 2.0 + 50;
}

while (true) {
    gt.rz / zpi => float rheight;
    gt.lz / zpi => float lheight;

    calc_note(rheight) => float rnote;
    calc_note(lheight) => float lnote;
    <<<gt.ly, rnote>>>;

    if (gt.ly > y_cap && !gt.right_cross) {
        play_note(rnote);
        true => gt.right_cross;
    } else if (gt.ly <= y_cap && gt.right_cross) {
        play_note(rnote);
        false => gt.right_cross;
    }

    // if (gt.ly > y_cap && !gt.left_cross) {
    //     play_note(lheight);
    //     true => gt.left_cross;
    // } else if (gt.ly <= y_cap) {
    //     false => gt.left_cross;
    // }

    3::ms => now;
}