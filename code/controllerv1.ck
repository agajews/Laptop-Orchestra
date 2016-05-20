// adapted code from GE Wang and also "Programming for music // authors Ajay Kapur, Perry Cook, Spencer Salazar and Ge We 

// z axis deadzone 
0 => float DEADZONE; 

// map values to variables 
0 => float xaxis; 
0 => float yaxis; 
0 => float zaxis; 
0 => float xrotation; 
0 => float yrotation; 
0 => float zrotation;

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
<<< "joystick y" + trak. name() + "' ready", "" >>>; 

SinOsc xleft => dac; 
1 => int onGainXleft; 
0 => int offGainXleft;

SinOsc yleft => dac; 
1 => int onGainYleft; 

=> int offGainYleft; 
SinOsc zleft => dac; 1 => int onGainZleft; 0 => int offGainZleft; 
SinOsc xright => dac; 1 => int onGainXright; 0 => int offGainXright; 
SinOsc yright => dac; => int onGainYright; 0 => int offGainYright; 
SinOsc zright => dac; => int onGainZright; => int offGainZright; 
SinOsc button => dac; 1 => int onGainButton; 0 => int offGainButton; 
// data structure for gametrak class GameTrak { // timestamps time lastTime; time currTime; 
    // previous axis data float lastAxis[6]; // current axis data float axis[6]; 
} 


// part 3
// gametrack GameTrak gt; 
// spork control spork - gametrak(); // print spork - print(); 
// main loop while( true ) { 100::ms => now; } 
// print fun void print() { // time loop while( true ) 
{ 
} 
} 
// left controller values gt.axis[0] is x-axis, qt.( // right controller values gt.axis[3] is x-rotation // the minimum and maximum values need to be determ-<<< "axes:", gt.axis[ ],gt.axis[1]*100,gt.axis[ ]) // advance time //1000::ms => now; 100::ms => now; 
// gametrack handling fun void gametrak() { 
while( true ) 
    
    
    // part 4
    { 
        // wait on Hidln as event trak => now; 
        // messages received while( trak.recv( msg ) ) { 
        // joystick axis motion if( msg.isAxisMotion() ) { 
        // check which if( msg.which >. && msg.which < ) { // check if fresh if( now > gt.currTime ) { // time stamp gt.currTime => gt.lastTime; // set now => gt.currTime; 
    } // save last gt.axis[msg.which] .> gt.lastAxis[msg.wI // the z axes map to [0,1], others map if( msg.which != && msg.which != 5 ) { msg.axisPosition => gt.axis[msg.which: else { 
    ((msg.axisPosition + ) / ) - I if( gt.axis[msg.which] < ) .> gi 
    // check value for x-axis and map to a tone if(gt.axis[0] < 0.0)1 
    
    
    // part 5
    261.6 => xleft.freq; }else if(gt.axis[ ] > 80.0){ . => xleft.freq; }else{ 
        . => xleft.freq; 
    } 
    // check value for y-axis and map to a tone if(gt.axis[1] < -){ 19.4 => yleft.freq; }else if(gt.axis[ ] > 80.0){ . => yleft.freq; }else{ 20.6 => yleft.freq; } 
    // check value for z-axis and map to a tone if(gt.axis[ ] < -){ . => zleft.freq; }else if(gt.axis[ ] > . ){ 110.0 => zleft.freq; }else{ 349.2 => zleft.freq; } 
    // check value for x-rotation and map to a -if(gt.axis[ ] < 0.0){ 43.6 => xright.freq; }else if(gt.axis[ ] > 80.0){ 698.5 => xright.freq; }else{ 174.6 => xright.freq; } 
    // check value for y-rotation and map to a d if(gt.axis[4] < 0){ 
    
    
    // part 6
    . => yright.freq; }else if(gt.axis[4] > 80.0){ 21.8 => yright.freq; }else{ . => yright.freq; } 
    // check value for z-rotation and map to a if(gt.axis[5] < ){ . => zright.freq; }else if(gt.axis[ ] > 0.5){ => zright.freq; }else{ 349.2 => zright.freq; } 
    onGainXleft => xleft.gain; ? :: second => now; // onGainYleft => yleft.gain; // 0.1 :: second => now; onGainZleft => zleft.gain; ? :: second => now; offGainXleft => xleft.gain; ? :: second => now; offGainYleft => yleft.gain; . :: second => now; offGainZleft => zleft.gain; :: second => now; 
    onGainXright => xright.gain; 0., :: second => now; onGainYright => yright.gain; :: second => now; onGainZright => zright.gain; :: second => now; offGainXright => xright.gain; 
    
    
    // part 7
} 
} 
} 
} 
1.1 :: second => now; offGainYright => yright.gain; J.1 :: second => now; offGainZright => zright.gain; 0.1 :: second => now; // joystick button down if( msg.isButtonDown() ) 
{ 
} 
<<< "button", msg.which, "down" >>>; onGainButton => button.gain; . :: second => now; offGainButton => button.gain; . :: second => now; 


// part 8