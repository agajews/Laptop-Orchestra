fun Hid initjoystick() {
    Hid trak;
    trak.openJoystick(0);
    <<<"Joystick " + trak.name() + " ready!">>>;

    return trak;
}

class GameTrak {
    time lastTime;
    time currTime;

    0.0 => float prev_rx;
    0.0 => float prev_ry;
    0.0 => float prev_rz;

    0.0 => float prev_lx;
    0.0 => float prev_ly;
    0.0 => float prev_lz;

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

initjoystick() @=> Hid trak;
GameTrak gt;
spork ~ gtupdate(gt, trak);

// [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] @=> int chromscale[];
// [0, 2, 4, 5, 7, 9, 11] @=> int majscale[];
// [0, 3, 5, 6, 7, 10] @=> int bluescale[];
[0, 4, 7, 11] @=> int sevenscale[];

// ==========================================================================
// Select a (midi) key and a scale
60 => int key;
[0, 2, 4, 5] @=> int lscale[];
[7, 9, 11, 12] @=> int rscale[];

PRCRev p => dac;

class Note {
    float freq;

    1 => int playing;

    // ==========================================================================
    // Your instrument here
    SinOsc s => ADSR a => Gain g => p;
    0.3 => g.gain;

    // set a, d, s, and r
    a.set(10::ms, 8::ms, .5, 100::ms);
    // ==========================================================================

    fun static Note Note(int note){
        Note n;
        note => Std.mtof => n.freq;
        return n;
    }

    // ==========================================================================
    // Set how to play your note
    fun void play(){
        freq => s.freq;
        1 => a.keyOn;
        while(playing){
            10::ms => now;
        }
        me.exit();
    }

    // how to change its volume
    fun void set_par(float par) {
        par + 0.1 => g.gain;
    }

    // And how to stop it
    fun void stop(){
        0 => playing;
        1 => a.keyOff;
        1::second => now;
        s =< a =< g =< p;
        me.exit();
    }
    // ==========================================================================
}

fun int calc_rzone(float x, float y) {
    -1 => int zone;
    if (x > 0.3 && y > 0.1) {
        1 => zone;
    } else if (x <= 0.3 && y > 0.1) {
        0 => zone;
    } else if (x <= 0.3 && y <= -0.1) {
        3 => zone;
    } else if (x > 0.3 && y <= -0.1) {
        2 => zone;
    }
    return zone;
}

fun int calc_lzone(float x, float y) {
    -1 => int zone;
    if (x < -0.3 && y > 0.1) {
        2 => zone;
    } else if (x > -0.3 && y > 0.1) {
        3 => zone;
    } else if (x > -0.3 && y <= -0.1) {
        0 => zone;
    } else if (x <= -0.3 && y <= -0.1) {
        1 => zone;
    }
    return zone;
}

fun int calc_z_zone(float z) {
    if (z < 1) {
        return 0;
    } else {
        return 1;
    }
}

fun int calc_zone_id(int zone, int z_zone) {
    if (zone < 0) {
        return -1;
    }
    return zone + 4 * z_zone;
}

Note held[2];
fun void play(int zone, float x, float y, float z, int prev_zone, float prev_x, float prev_y, float prev_z, int scale[], int side) {
    calc_z_zone(z) => int z_zone;
    calc_z_zone(prev_z) => int prev_z_zone;

    calc_zone_id(zone, z_zone) => int zone_id;
    calc_zone_id(prev_zone, prev_z_zone) => int prev_zone_id;

    if (prev_zone_id != zone_id) {  // crossed border
        <<<zone>>>;
        if (prev_zone >= 0) {
            spork ~ held[side].stop();
        }
        if (zone >= 0) {
            key + z_zone * 12 + scale[zone] => int note;
            Note.Note(note) @=> held[side];
            spork ~ held[side].play();
        }
    }

    Std.fabs(y) => float par;
    held[side].set_par(par);
}

while (true) {
    play(calc_rzone(gt.rx, gt.ry), gt.rx, gt.ry, gt.rz, calc_rzone(gt.prev_rx, gt.prev_ry), gt.prev_rx, gt.prev_ry, gt.prev_rz, rscale, 0);
    play(calc_lzone(gt.lx, gt.ly), gt.lx, gt.ly, gt.lz, calc_lzone(gt.prev_lx, gt.prev_ly), gt.prev_lx, gt.prev_ly, gt.prev_lz, lscale, 1);
    gt.rx => gt.prev_rx; gt.ry => gt.prev_ry; gt.rz => gt.prev_rz;
    gt.lx => gt.prev_lx; gt.ly => gt.prev_ly; gt.lz => gt.prev_lz;
    10::ms => now;
}