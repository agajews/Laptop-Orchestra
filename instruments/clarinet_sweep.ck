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

    float lvelocity;
    float rvelocity;
}

fun void gtupdate(GameTrak gt, Hid trak) {
    HidMsg msg;
    // for velocity
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
            /*Math.sqrt( Math.pow((gt.lx - last_lx), 2) + Math.pow((gt.ly - last_ly), 2) + Math.pow((gt.lz - last_lz), 2) ) => ldisplacement;
            Math.sqrt( Math.pow((gt.rx - last_rx), 2) + Math.pow((gt.ry - last_ry), 2) + Math.pow((gt.rz - last_rz), 2) ) => rdisplacement;*/
            Math.sqrt( Math.pow((gt.lx - last_lx), 2) + Math.pow((gt.ly - last_ly), 2) ) => ldisplacement;
            Math.sqrt( Math.pow((gt.rx - last_rx), 2) + Math.pow((gt.ry - last_ry), 2) ) => rdisplacement;
            ldisplacement /((gt.currTime - gt.lastTime) / 1::second) => gt.lvelocity;
            rdisplacement /((gt.currTime - gt.lastTime) / 1::second) => gt.rvelocity;
        }
    }
}

initjoystick() @=> Hid trak;
GameTrak gt;

spork ~ gtupdate(gt, trak);

fun void prep_clarinet(Clarinet c) {
  0.5 => c.noteOn;
  0.0 => c.startBlowing;
  1.0 => c.vibratoGain;
  0 => c.vibratoFreq;
  0.6 => c.pressure;
  0.3 => c.noiseGain;
  0.5 => c.reed;
}
Clarinet lc => dac;
Clarinet rc => dac;
prep_clarinet(lc);
prep_clarinet(rc);

1.5 => lc.gain;
1.5 => rc.gain;
60 => Std.mtof => lc.freq;
62 => Std.mtof => rc.freq;

fun float bound(float x, float min, float max) {
  if (x < min) {
    return min;
  }
  if (x > max) {
    return max;
  }
  return x;
}

fun float calc_gain(float vel, float old) {
  bound(vel * 0.5, 0, 1.5) => float new_gain;
  return bound(0.99 * old + 0.01 * new_gain, 0, 0.8);
}

while(true){
  <<<lc.gain(), rc.gain()>>>;
  if ((now - gt.lastTime) > 0.25::second) {
    0 => gt.lvelocity;
    0 => gt.rvelocity;
  }
  calc_gain(gt.lvelocity, lc.gain()) => lc.gain;
  calc_gain(gt.rvelocity, rc.gain()) => rc.gain;
  10::ms => now;
}
