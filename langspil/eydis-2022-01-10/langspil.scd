
    //helper
    /*~fsaa  = { arg in, freq=0.0, phase=0.0, mul=1.0, add=0.0;
        var hcutoff = (SampleRate.ir/2 - freq.max(0))/2;
        var lcutoff = ((0.0 - freq.min(0))*2).max(20);
        FreqShift.ar(
            BHiPass4.ar(BLowPass4.ar(in, hcutoff), lcutoff),
            freq, phase, mul, add);
    };*/

    // define+create synth which goes in the feedback loop
~synth = SynthDef(\langspil, { arg
    shift_onsets = 7,
    shift_hz = -3e-2,
    shift_ratio = 0,
    hz_mix = 1,
    ratio_mix = 0,
    onsets_mix = 1,
    center_freqs = #[100, 200, 400],
    pitch_lag = 3,
    low_pass = 700,
    high_pass = 10,
    drive = 2e-1,
    thresh = 1e-2,
    comp_exponent = 1;

    var att = 3e-2;
    var rel = 1e-1;

    // var pup1 = SoundIn.ar(~pup_buses[0]);
    // var pup2 = SoundIn.ar(~pup_buses[1]);
    // var pup3 = SoundIn.ar(~pup_buses[2]);

    // var pups = [pup1, pup2, pup3] * drive;
    var pups = SoundIn.ar(~pup_buses) * drive;
    // var f0_raw = Pitch.kr(pups, 200, 30, 3000,
    // clar:1, ampThreshold:1e-4, execFreq:200).flop;
    // var f0s = Lag.ar(K2A.ar(f0_raw[0].log), pitch_lag).exp;

    // var purity = f0_raw[1];

    var filt = LPF.ar(pups, low_pass);

    var amps = Amplitude.ar(filt, att, rel);

    /*var onsets = Decay.ar(FluidAmpSlice.ar(pups,
    fastRampUp: 30, fastRampDown: 9600, slowRampUp: 19200,
    slowRampDown: 19200, onThreshold: 15, offThreshold: 3,
    floor: -70, minSliceLength: 960, highPassFreq: 100
    ), 3).pow(0.25);*/
    var chain = FFT(LocalBuf(128), pups);
    var onsets = Decay.ar(T2A.ar(Onsets.kr(chain,
        threshold: 0.5, odftype: \wphase,
        relaxtime: 1, floor: 0.1,
        mingap: 10, medianspan: 11,
    )), 3).pow(0.25);

    var comp = filt / ((amps/thresh).pow(comp_exponent) + thresh);
    // var comp = Limiter.ar(filt)

    var mcomp = Mix.ar(comp);

    /* var ratio_shift = ~fsaa.(comp,
    shift_ratio*f0s
    *(f0s - center_freqs / center_freqs * 10).clip(-1, 1));*/

    var hz_shift = FreqShift.ar(mcomp, shift_hz);

    /* var up_shift = FreqShift.ar(comp, shift_onsets*onsets);
    var down_shift = FreqShift.ar(comp, 0-shift_onsets*2.log*onsets);
    var onsets_shift = up_shift + down_shift / 2 * onsets;*/
    // var onsets_shift = FreqShift.ar(Mix.ar(comp*onsets), shift_onsets * (1-(1e1*Mix.ar(onsets))));
    var onsets_shift = FreqShift.ar(Mix.ar(comp*onsets), shift_onsets + Mix.ar(onsets));


    // var premix = hz_shift;
    var premix = (
        //     (ratio_shift*ratio_mix) +
        (hz_shift*hz_mix) +
        (onsets_shift* onsets_mix));

    // var mix = HPF.ar(Mix.ar(premix), 20) * \gain.kr(1, 3);
    var mix = HPF.ar(premix, high_pass) * \gain.kr(4, 3);


    // f0s.poll(5, \f0);
    // purity.poll(5, \purity);
    // amps.poll(5, \amp);
    // onsets.poll(5, \onsets);

    Out.ar(~output_bus, mix);
}).play;