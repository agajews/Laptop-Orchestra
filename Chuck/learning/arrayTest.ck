int foo[10];
<<<foo[0]>>>;

[1,1,2,3,5,8] @=> int bar[];
<<<bar[0]>>>;
12 => bar[0];
<<<bar[0]>>>;

float foo3D[4][6][8];
[ [1,3],[2,4] ] @=> int baz[][];

for(0=>int i; i<bar.cap(); i++){
	<<<bar[i]>>>;
}
