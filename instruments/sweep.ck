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

SinOsc s;
0.3 => s.gain;
s => Gain leftg => dac;
s => Gain rightg => dac;
0.5 => leftg.gain;
0.5 => rightg.gain;
60 => Std.mtof => s.freq;

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
  bound(vel / 3.0, 0, 0.8) => float newGain;
  return bound(0.99 * old + 0.01 * newGain, 0, 0.8);
}

while(true){
  <<<leftg.gain(), rightg.gain()>>>;
  calc_gain(gt.lvelocity, leftg.gain()) => leftg.gain;
  calc_gain(gt.rvelocity, rightg.gain()) => rightg.gain;
  10::ms => now;
}
