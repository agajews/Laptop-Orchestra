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

SinOsc lsin => dac;
SinOsc rsin => dac;
0.3 => lsin.gain;
0.3 => rsin.gain;
60 => Std.mtof => lsin.freq;
60 => Std.mtof => rsin.freq;

fun float bound(float x, float min, float max) {
  if (x < min) {
    return min;
  }
  if (x > max) {
    return max;
  }
  return x;
}

fun float calc_pitch(float vel, float old) {
  bound(vel * 30, 50, 100) => float new_pitch;
  return bound(0.99 * old + 0.01 * new_pitch, 50, 100);
}

while(true){
  <<<lsin.freq() => Std.ftom, rsin.freq() => Std.ftom>>>;
  calc_pitch(gt.lvelocity, lsin.freq() => Std.ftom) => Std.mtof => lsin.freq;
  calc_pitch(gt.rvelocity, rsin.freq() => Std.ftom) => Std.mtof => rsin.freq;
  10::ms => now;
}
