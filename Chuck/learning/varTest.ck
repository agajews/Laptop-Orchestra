1 => int i;
<<<i>>>;

2 => i;
<<<i>>>;

0x22=>i;
<<<i>>>;

5.678 => float f;
<<<f>>>;

9.0::second => dur d;
<<<d>>>;

now => time t;
<<<t>>>;
now => t;
<<<t>>>;
<<<now>>>;

<<<"waiting 10 seconds...">>>;
10::second => now;
<<<now>>>;
