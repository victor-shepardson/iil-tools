//TODO:
// io settings for Bela
// controls for Bela
// test+tweak Onsets for langspil

//connect to bela
(
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 4; // should match the settings on the Bela
s.initTree;
s.startAliveThread;
)

//alternatively: local setup
(
~pup_buses = [0,1,2];
// output to transducer
~output_bus = 0;
s.options.sampleRate = 48000;
s.options.blockSize = 16;
)

s.waitForBoot({this.executeFile("langspil.scd")});



//===============================================


Bus.new(2+~pup_buses[0]).belaScope(0)

Bus.new(index:~output_bus).belaScope(0)
// ~output_bus.belaScope(0)

~synth.free

// RUN THIS to unmute the instrument:
// ~play.();

~synth.set(\gain, 0)

(
~synth.set(\gain, 4);
~synth.set(\low_pass, 700);
~synth.set(\high_pass, 10);
~synth.set(\shift_hz, -3e-2);
~synth.set(\comp_exponent, 1);
~synth.set(\thresh, 1e-2);
~synth.set(\drive, 2e-1);
~synth.set(\hz_mix, 1);
~synth.set(\onsets_mix, 1);
~synth.set(\shift_onsets, 7);

)




// s.stopRecording;

// s.quit;