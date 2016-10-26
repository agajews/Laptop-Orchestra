Impulse i => BiQuad f => dac;

.99 => f.prad;
1 => f.eqzs;
0.0 => float v;

while(true){
	1.0 => i.next;
	Std.fabs(Math.sin(v)) * 400.0 => f.pfreq;
	v + .1 => v;
	
	//advance time
	101::ms => now;
}
