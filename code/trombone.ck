// name: gametra.ck
// desc: gametrak boilerplate example
//

// z axis deadzone
0.25 => float DEADZONE;


// which joystick
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// HID objects
Hid trak;
HidMsg msg;

// open joystick 0, exit on fail
if( !trak.openJoystick( device ) ) me.exit();

// print
<<< "joystick '" + trak.name() + "' ready", "" >>>;

// data structure for gametrak
class GameTrak
{
    // timestamps
    time lastTime;
    time currTime;
    
    // previous axis data
    float lastAxis[6];
    // current axis data
    float axis[6];
    
    int pedal;
}

// gametrack
GameTrak gt;


// spork control
spork ~ gametrak();
// print
spork ~ print();


// ======== spatialization =======
// change this to # of channels used
2 => int CHANNELS;
// amount of feedback
.5 => float FEEDBACK;
// duration between successive channels
300::ms => dur CHAN_DELAY;

// delay stuff
DelayL delay[CHANNELS];
OneZero lowpass[CHANNELS];
NRev reverb[CHANNELS];

//patch
//LH
//Shakers shake => JCRev r => dac;
SinOsc lsin => JCRev rrev => dac;
SinOsc rsin => JCRev lrev => dac;

//setting gain
.95 => lsin.gain;
.95 => rsin.gain;
//set the reverb
.1 => rrev.mix;
.1 => lrev.mix;
//set instrument
//22 => shake.which;

true => int quantized;
            
[0, 2, 4, 5, 7, 9, 11] @=> int majscale[];
[0, 2, 3, 5, 7, 8, 10] @=> int natminscale[];
[0, 2, 3, 5, 7, 8, 11] @=> int harminscale[];
[0, 3, 5, 6, 7, 10] @=> int bluescale[];

bluescale @=> int scale[];

0 => int key;

// main loop
while( true )
{
    // <<< gt.axis[0] >>>;
    
    // 100 * gt.axis[5] => sin.freq;
    
    if(gt.pedal == 0){
        265 + 270 * (Math.pow(2, 1 - gt.axis[0]) - 1) => rsin.freq;
        265 + 270 * (Math.pow(2, 1 - gt.axis[3]) - 1) => lsin.freq;
        
        if(quantized){
            Std.mtof(Std.ftom(rsin.freq()) $ int + key) => rsin.freq;
            Std.mtof(Std.ftom(lsin.freq()) $ int + key) => lsin.freq;
            
            Std.ftom(rsin.freq()) $ int => int rmidi;
            Std.ftom(lsin.freq()) $ int => int lmidi;
            
            (rmidi - key) $ int % 12 => int rnote;
            (lmidi - key) $ int % 12 => int lnote;
            
            rmidi - rnote => int rbase;
            lmidi - lnote => int lbase;
            
            in_int_array(scale, rnote) => int r_in_notes;
            in_int_array(scale, lnote) => int l_in_notes;
            
            closest_int_array(scale, rnote) => int rclosest;
            closest_int_array(scale, lnote) => int lclosest;
            
            <<< rmidi, rnote, rbase, rclosest >>>;
            
            if(r_in_notes == 0){
                Std.mtof(rbase + rclosest) => rsin.freq;
            }
            if(l_in_notes == 0){
                Std.mtof(lbase + lclosest) => lsin.freq;
            }
        }
    }
    gt.axis[2] * 7 => rsin.gain;
    gt.axis[5] * 7 => lsin.gain;
    
    3::ms => now;
}

fun int in_int_array(int array[], int item){
    for(0 => int i; i < array.size(); i++){
        if(array[i] == item){
            return 1;
        }
    }
    return 0;
}

fun int closest_int_array(int array[], int item){
    1 => int i;
    while(i < array.size() && array[i] < item ){
        i++;
    }
    return array[i - 1];
}

// print
fun void print()
{
    // time loop
    while( true )
    {
        // values
        // <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2], gt.axis[3],gt.axis[4],gt.axis[5] >>>;
        // <<< Std.ftom(rsin.freq()) $ int % 12 >>>;
        // advance time
        10::ms => now;
    }
}

// gametrack handling
fun void gametrak()
{
    while( true )
    {
        // wait on HidIn as event
        trak => now;
        
        // messages received
        while( trak.recv( msg ) )
        {
            // joystick axis motion
            if( msg.isAxisMotion() )
            {            
                // check which
                if( msg.which >= 0 && msg.which < 6 )
                {
                    gt.axis[msg.which] => gt.lastAxis[msg.which];
                    // the z axes map to [0,1], others map to [-1,1]
                    if( msg.which != 2 && msg.which != 5 )
                    { msg.axisPosition => gt.axis[msg.which]; }
                    else
                    {
                        1 - ((msg.axisPosition + 1) / 2) - DEADZONE => gt.axis[msg.which];
                        if( gt.axis[msg.which] < 0 ) 0 => gt.axis[msg.which];
                    }
                }
            } else if( msg.isButtonDown() )
            {
                <<< "joystick button", msg.which, "down" >>>;
                1 => gt.pedal;
            }
            
            // joystick button up
            else if( msg.isButtonUp() )
            {
                <<< "joystick button", msg.which, "up" >>>;
                0 => gt.pedal;
            }
        }
    }
}