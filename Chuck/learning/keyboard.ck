//keyboard
Hid kb;
HidMsg msg;

if(!kb.openKeyboard(0)) me.exit();

<<<"Ready?","">>>;
while(true){
	kb => now;
	while(kb.recv(msg)){
		<<<msg.which>>>;
	}
}
