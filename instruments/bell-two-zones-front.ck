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
80 => int key;
/*[0, 2, 4, 5, 7, 9, 11, 12] @=> int majscale[];*/
[0, 2, 4, 5] @=> int scale[];

PRCRev p => dac;
0.1 => p.mix;

class Note {
    float freq;

    1 => int playing;

    // ==========================================================================
    // Your instrument here
    /*SinOsc s => ADSR a => Gain g => p;*/
    TubeBell b => Gain g => p;
    0.3 => g.gain;

    // set a, d, s, and r
    /*a.set(10::ms, 8::ms, .5, 100::ms);*/
    // ==========================================================================

    fun static Note Note(int note){
        Note n;
        note => Std.mtof => n.freq;
        return n;
    }

    // ==========================================================================
    // Set how to play your note
    fun void play(){
        freq => b.freq;
        1 => b.noteOn;
        while(playing){
            10::ms => now;
        }
        me.exit();
    }

    // how to change its volume
    fun void set_par(float par) {
        /*par / 2.0 + 0.1 => g.gain;*/
    }

    // And how to stop it
    fun void stop(){
        0 => playing;
        /*0.1 => b.noteOff;*/
        10::second => now;
        b =< g =< p;
        me.exit();
    }
    // ==========================================================================
}

fun float plr_ang(float x, float y) {
    return Math.atan2(y, x) / Math.PI * 180;
}

fun float plr_rad(float x, float y) {
    return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2));
}

fun int quadrant(float x, float y) {
    plr_ang(x, y) => float ang;
    if (0 <= ang && ang < 90) {
        return 1;
    } else if (90 <= ang && ang <= 180) {
        return 2;
    } else if (-180 <= ang && ang < -90) {
        return 3;
    } else if (-90 <= ang && ang < 0) {
        return 4;
    }
}

fun int calc_zone(float x, float y, int side) {
    plr_rad(x, y) => float rad;
    quadrant(x, y) => int quad;
    if (quad == 3 || quad == 4 || y < 0.1) {
      return -1;
    }
    if (side == 1) {
      if (quad == 1) {
        return 1;
      } else if (quad == 2) {
        return 0;
      }
    }
    if (side == 0) {
      if (quad == 1) {
        return 3;
      } else if (quad == 2) {
        return 2;
      }
    }
    return 1 - side;
}

fun Note play(float x, float y, float z, float prev_x, float prev_y, float prev_z, int scale[], Note held, int side) {
    calc_zone(x, y, side) => int zone;
    calc_zone(prev_x, prev_y, side) => int prev_zone;

    if (prev_zone != zone) {  // crossed border
        <<<zone>>>;
        if (prev_zone >= 0) {
            spork ~ held.stop();
        }
        if (zone >= 0) {
            key + scale[zone] => int note;
            Note.Note(note) @=> held;
            spork ~ held.play();
        }
    }

    plr_rad(x, y) => float par;
    held.set_par(par);
    return held;
}

Note held[2];
while (true) {
    play(gt.rx, gt.ry, gt.rz, gt.prev_rx, gt.prev_ry, gt.prev_rz, scale, held[0], 0) @=> held[0];
    play(gt.lx, gt.ly, gt.lz, gt.prev_lx, gt.prev_ly, gt.prev_lz, scale, held[1], 1) @=> held[1];
    gt.rx => gt.prev_rx; gt.ry => gt.prev_ry; gt.rz => gt.prev_rz;
    gt.lx => gt.prev_lx; gt.ly => gt.prev_ly; gt.lz => gt.prev_lz;
    10::ms => now;
}
