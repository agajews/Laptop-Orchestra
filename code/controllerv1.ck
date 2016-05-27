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
}

// gametrack
GameTrak gt;


// spork control
spork ~ gametrak();
// print
// spork ~ print();


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


// main loop
while( true )
{
    <<< gt.axis[0] >>>;
    
    // 100 * gt.axis[5] => sin.freq;
    
    200 + Std.mtof(Std.ftom(600 * (1 - gt.axis[0])) $ int) => rsin.freq;
    gt.axis[2] * 3 => rsin.gain;
    
    200 + Std.mtof(Std.ftom(600 * (1 - gt.axis[3])) $ int) => lsin.freq;
    gt.axis[5] * 3 => lsin.gain;

    3::ms => now;
}

// print
fun void print()
{
    // time loop
    while( true )
    {
        // values
        <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2], gt.axis[3],gt.axis[4],gt.axis[5] >>>;
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
            }
        }
    }
}