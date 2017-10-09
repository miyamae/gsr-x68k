*
*	音色名定義（Roland SC-88準拠）
*

	.xdef	inst_capital
	.xdef	inst_var1
	.xdef	inst_var2
	.xdef	inst_var3
	.xdef	inst_var4
	.xdef	inst_var5
	.xdef	inst_var6
	.xdef	inst_var7
	.xdef	inst_var8
	.xdef	inst_var9
	.xdef	inst_var10
	.xdef	inst_var11
	.xdef	inst_var16
	.xdef	inst_var17
	.xdef	inst_var18
	.xdef	inst_var19
	.xdef	inst_var24
	.xdef	inst_var25
	.xdef	inst_var26
	.xdef	inst_var32
	.xdef	inst_var33
	.xdef	inst_var40
	.xdef	inst_CM32P
	.xdef	inst_CM32L
	.xdef	inst_drums
	.xdef	inst_user
	.xdef	effect_reverb
	.xdef	effect_chorus
	.xdef	effect_delay


	.dc.b	"$Id: sc88map.s,v 1.1 1994/10/21 12:03:55 T.MIYAMAE Exp $"

inst_capital:
	.dc.b	"Piano 1     ",0,"Piano 2     ",0,"Piano 3     ",0,"Honky-tonk  ",0
	.dc.b	"E.Piano 1   ",0,"E.Piano 2   ",0,"Harpsichord ",0,"Clav.       ",0
	.dc.b	"Celesta     ",0,"Glockenspiel",0,"Music Box   ",0,"Vibraphone  ",0
	.dc.b	"Marimba     ",0,"Xyrophone   ",0,"Tubular-bell",0,"Santur      ",0
	.dc.b	"Organ 1     ",0,"Organ 2     ",0,"Organ 3     ",0,"Church Org.1",0
	.dc.b	"Reed Organ  ",0,"Accordion Fr",0,"Harmonica   ",0,"Bandoneon   ",0
	.dc.b	"Nylon-str.Gt",0,"Steel-str.Gt",0,"Jazz Gt.    ",0,"Clean Gt.   ",0
	.dc.b	"Muted Gt.   ",0,"Overdrive Gt",0,"DistortionGt",0,"Gt.Harmonics",0
	.dc.b	"Acoustic Bs.",0,"Fingered Bs.",0,"Picked Bs.  ",0,"Fretless Bs.",0
	.dc.b	"Slap Bass 1 ",0,"Slap Bass 2 ",0,"Synth Bass 1",0,"Synth Bass 2",0
	.dc.b	"Violin      ",0,"Viola       ",0,"Cello       ",0,"Contrabass  ",0
	.dc.b	"Tremolo Str ",0,"PizzicatoStr",0,"Harp        ",0,"Timpani     ",0
	.dc.b	"Strings     ",0,"Slow Strings",0,"Syn.Strings1",0,"Syn.Strings2",0
	.dc.b	"Choir Aahs  ",0,"Voice Oohs  ",0,"SynVox      ",0,"OrchestraHit",0
	.dc.b	"Trumpet     ",0,"Trombone    ",0,"Tuba        ",0,"MutedTrumpet",0
	.dc.b	"French Horn ",0,"Brass 1     ",0,"Synth Brass1",0,"Synth Brass2",0
	.dc.b	"Soprano Sax ",0,"Alto Sax    ",0,"Tenor Sax   ",0,"Baritone Sax",0
	.dc.b	"Oboe        ",0,"English Horn",0,"Bassoon     ",0,"Clarinet    ",0
	.dc.b	"Piccolo     ",0,"Flute       ",0,"Recorder    ",0,"Pan Flute   ",0
	.dc.b	"Bottle Blow ",0,"Shakuhachi  ",0,"Whistle     ",0,"Ocarina     ",0
	.dc.b	"Square Wave ",0,"Saw Wave    ",0,"Syn.Calliope",0,"Chiffer Lead",0
	.dc.b	"Charang     ",0,"Solo Vox    ",0,"5th Saw Wave",0,"Bass & Lead ",0
	.dc.b	"Fantasia    ",0,"Warm Pad    ",0,"Polysynth   ",0,"Space Voice ",0
	.dc.b	"Bowed Glass ",0,"Metal Pad   ",0,"Halo Pad    ",0,"Sweep Pad   ",0
	.dc.b	"Ice Rain    ",0,"Soundtrack  ",0,"Crystal     ",0,"Atmosphere  ",0
	.dc.b	"Brightness  ",0,"Goblin      ",0,"Echo Drops  ",0,"Star Theme  ",0
	.dc.b	"Sitar       ",0,"Banjo       ",0,"Shamisen    ",0,"Koto        ",0
	.dc.b	"Kalimba     ",0,"Bag Pipe    ",0,"Fiddle      ",0,"Shannai     ",0
	.dc.b	"Tinkle Bell ",0,"Agogo       ",0,"Steel Drums ",0,"Woodblock   ",0
	.dc.b	"Taiko       ",0,"Melo. Tom 1 ",0,"Synth Drum  ",0,"Reverse Cym.",0
	.dc.b	"Gt.FretNoise",0,"Breath Noise",0,"Seashore    ",0,"Bird        ",0
	.dc.b	"Telephone 1 ",0,"Helicopter  ",0,"Applause    ",0,"Gun Shot    ",0

inst_var1:
	.dc.b	"            ",0,"            ",0,"EG+Rhodes 1 ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Hard Vive   ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Santur 2    ",0
	.dc.b	"Organ 101   ",0,"Organ 201   ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Harmonica 2 ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Mellow Gt.  ",0,"            ",0
	.dc.b	"Muted Dis.Gt",0,"            ",0,"Dist.Gt2    ",0,"            ",0
	.dc.b	"            ",0,"Fingered Bs2",0,"            ",0,"Fretless Bs2",0
	.dc.b	"            ",0,"            ",0,"SynthBass101",0,"SynthBass201",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Strings 2   ",0,"SlowStrings2",0,"OB Strings  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Trumpet 2   ",0,"Trombone 2  ",0,"Tuba 2      ",0,"            ",0
	.dc.b	"Fr.Horn 2   ",0,"            ",0,"Poly Brass  ",0,"Soft Brass  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Square      ",0,"Saw         ",0,"Vent Synth  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Big Fives   ",0,"Big & Raw   ",0
	.dc.b	"Fantasia 2  ",0,"Thick Pad   ",0,"80's PolySyn",0,"Heaven II   ",0
	.dc.b	"            ",0,"Tine Pad    ",0,"            ",0,"Polar Pad   ",0
	.dc.b	"Harmo Rain  ",0,"Ancestral   ",0,"Syn Mallet  ",0,"Warm Atmos  ",0
	.dc.b	"            ",0,"Goblinson   ",0,"Echo Bell   ",0,"Star Theme 2",0
	.dc.b	"Sitar 2     ",0,"Muted Banjo ",0,"Tsugaru     ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Shanai 2    ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Real Tom    ",0,"            ",0,"Reverse Cym2",0
	.dc.b	"Gt.Cut Noise",0,"Fl.Key Click",0,"Rain        ",0,"Dog         ",0
	.dc.b	"Telephone 2 ",0,"Car-engine  ",0,"Laughing    ",0,"Machin gun  ",0

inst_var2:
	.dc.b	"            ",0,"            ",0,"EG+Rhodes 2 ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Dazed Guitar",0,"            ",0
	.dc.b	"            ",0,"Jazz Bass   ",0,"            ",0,"Fretless Bs3",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Modular Bass",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Hollow Mini ",0,"Pulse Saw   ",0,"Pure PanLead",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Fat & Perky ",0
	.dc.b	"            ",0,"Horn Pad    ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Panner Pad  ",0,"            ",0,"            ",0
	.dc.b	"African wood",0,"Prologue    ",0,"Soft Crystal",0,"Nylon Harp  ",0
	.dc.b	"            ",0,"50's Sci-Fi ",0,"Echo Pan    ",0,"            ",0
	.dc.b	"Detune Sitar",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"String Slap ",0,"            ",0,"Thunder     ",0,"Horse-Gallop",0
	.dc.b	"DoorCreaking",0,"Car-stop    ",0,"Screaming   ",0,"Lasergun    ",0

inst_var3:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Fretless Bs4",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Seq Bass    ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Mellow FM   ",0,"Feline GR   ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Rotary Strng",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Round Glock ",0,"Harpvox     ",0
	.dc.b	"            ",0,"            ",0,"Echo Pan 2  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Gt.CutNoise2",0,"            ",0,"Wind        ",0,"Bird 2      ",0
	.dc.b	"Door        ",0,"Car-pass    ",0,"Punch       ",0,"Explosion   ",0

inst_var4:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Syn Fretless",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"CC Solo     ",0,"Big Lead    ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Soft Pad    ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Loud Glock  ",0,"HollowReleas",0
	.dc.b	"            ",0,"            ",0,"Big Panner  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Dist.CutNoiz",0,"            ",0,"Stream      ",0,"Kitty       ",0
	.dc.b	"Scratch     ",0,"Car-crash   ",0,"Heart Beat  ",0,"            ",0

inst_var5:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Cimbalom    ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Mr.Smooth   ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Shmoog      ",0,"Velo Lead   ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"GlockenChime",0,"Nylon+Rhodes",0
	.dc.b	"            ",0,"            ",0,"Reso Panner ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Bass Slide  ",0,"            ",0,"Bubble      ",0,"Growl       ",0
	.dc.b	"Windchime   ",0,"Siren       ",0,"Footsteps   ",0,"            ",0

inst_var6:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"LM Square   ",0,"GR-300      ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Clear Bells ",0,"Ambient Pad ",0
	.dc.b	"            ",0,"            ",0,"Water Piano ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Pick Scrape ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Train       ",0,"Applause 2  ",0,"            ",0

inst_var7:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"LA Saw      ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"ChristmasBel",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Scratch 2   ",0,"Jetplane    ",0,"            ",0,"            ",0

inst_var8:
	.dc.b	"Piano 1w    ",0,"Piano 2w    ",0,"Piano 3w    ",0,"Old Upright ",0
	.dc.b	"St.Soft EP  ",0,"Detuned EP 2",0,"Coupled Hps.",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Vib.w       ",0
	.dc.b	"Marimba w   ",0,"            ",0,"Church Bell ",0,"            ",0
	.dc.b	"Detuned Or.1",0,"Detuned Or.2",0,"Rotary Org. ",0,"Church Org.2",0
	.dc.b	"            ",0,"Accordion It",0,"            ",0,"            ",0
	.dc.b	"Ukulele     ",0,"12-str.Gt.  ",0,"Pedal Steel ",0,"Chorus Gt.  ",0
	.dc.b	"Funk Pop    ",0,"            ",0,"Feedback Gt.",0,"Gt.Feedback ",0
	.dc.b	"            ",0,"            ",0,"Mute PickBs.",0,"            ",0
	.dc.b	"Reso Slap   ",0,"            ",0,"Acid Bass   ",0,"Beff FM Bass",0
	.dc.b	"Slow Violin ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Slow Tremolo",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Orchestra   ",0,"Legato Str. ",0,"Syn.Strings3",0,"            ",0
	.dc.b	"St.Choir    ",0,"            ",0,"Syn.Voice   ",0,"Impact Hit  ",0
	.dc.b	"Flugel Horn ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Fr.Horn Solo",0,"Brass 2     ",0,"Synth Brass3",0,"Synth Brass4",0
	.dc.b	"            ",0,"Hyper Alto  ",0,"BreathyTenor",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Bs Clarinet ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Kawala      ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Sine Wave   ",0,"Doctor Solo ",0,"            ",0,"            ",0
	.dc.b	"Dist.Lead   ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Converge    ",0
	.dc.b	"Clavi Pad   ",0,"Rave        ",0,"Vibra Bells ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Tambra      ",0,"Rabab       ",0,"            ",0,"Taisho Koto ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Pungi       ",0
	.dc.b	"Bonang      ",0,"Atarigane   ",0,"            ",0,"Castanets   ",0
	.dc.b	"Concert BD  ",0,"Melo. Tom 2 ",0,"808 Tom     ",0,"Rev.Snare 1 ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"StarShip    ",0,"            ",0,"            ",0

inst_var9:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Carillon    ",0,"            ",0
	.dc.b	"Organ 109   ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Nylon+Steel ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Feedback Gt2",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"TB303 Bass  ",0,"X Wire Bass ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Suspense Str",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Orchestra 2 ",0,"Warm Strings",0,"            ",0,"            ",0
	.dc.b	"Mello Choir ",0,"            ",0,"            ",0,"Philly Hit  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Quack Brass ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Shwimmer    ",0
	.dc.b	"            ",0,"            ",0,"Digi Bells  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Gender      ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Rock Tom    ",0,"Elec Perc   ",0,"Rev.Snare 2 ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Burst Noise ",0,"            ",0,"            ",0

inst_var10:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Tekno Bass  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Tremolo Orch",0,"St.Slow Str.",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Double Hit  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Gamelan Gong",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var11:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Choir Str.  ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"St.Gamelan  ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var16:
	.dc.b	"Piano 1d    ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"FM + SA EP  ",0,"St.FM EP    ",0,"Harpsi.w    ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Barafon     ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"60's Organ 1",0,"            ",0,"Rotary Org.S",0,"Church Org.3",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Nylon Gt.o  ",0,"Mandolin    ",0,"            ",0,"            ",0
	.dc.b	"Funk Gt.2   ",0,"            ",0,"Power Guitar",0,"Ac.Gt.Harmnx",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Reso SH Bass",0,"Rubber Bass ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"St.Strings  ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Lo Fi Rave  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Horn Orch   ",0,"Brass Fall  ",0,"Octave Brass",0,"Velo Brass 1",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Wispy Synth ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Choral Bells",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Tamboura    ",0,"Gopichant   ",0,"            ",0,"Kanoon      ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Hichiriki   ",0
	.dc.b	"RAMA Cymbal ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Rev.Kick 1  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var17:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Barafon 2   ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"60's Organ 2",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Power Gt.2  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"SH101 Bass 1",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Velo Brass 2",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Air Bells   ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Rev.ConBD   ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var18:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"60's Organ 3",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"5th Dist.   ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"SH101 Bass 2",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Bell Harp   ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var19:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Gamelimba   ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var24:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"60's E.Piano",0,"Hard FM EP  ",0,"Harpsi.o    ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Log drum    ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Cheese Organ",0,"            ",0,"Rotary Org.F",0,"Organ Flute ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Velo Harmnix",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Rock Rhythm ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Smooth Bass ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Velo Strings",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Bright Tp.  ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"Oud         ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Rev.Tom 1   ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var25:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Hard Rhodes ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"Rock Rhythm2",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Warm Tp.    ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"Rev Tom 2   ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var26:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"MellowRhodes",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var32:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Organ 4     ",0,"Organ 5     ",0,"            ",0,"Trem.Flute  ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Nylon Gt.2  ",0,"Steel Gt.2  ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Choir Aahs 2",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var33:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Even Bar    ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_var40:
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Organ Bass  ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"Lequint Gt. ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_CM32P:
	.dc.b	"Piano 2     ",0,"Piano 2     ",0,"Piano 2     ",0,"Honky-tonk  ",0
	.dc.b	"Piano 1     ",0,"Piano 2     ",0,"Piano 2     ",0,"E.Piano 1   ",0
	.dc.b	"Detuned EP 1",0,"E.Piano 2   ",0,"Steel-str.Gt",0,"Steel-str.Gt",0
	.dc.b	"12-str.Gt   ",0,"Funk Gt.    ",0,"Muted Gt.   ",0,"Slap Bass 1 ",0
	.dc.b	"Slap Bass 1 ",0,"Slap Bass 1 ",0,"Slap Bass 1 ",0,"Slap Bass 2 ",0
	.dc.b	"Slap Bass 2 ",0,"Slap Bass 2 ",0,"Slap Bass 2 ",0,"Fingered Bs.",0
	.dc.b	"Fingered Bs.",0,"Picked Bs.  ",0,"Picked Bs.  ",0,"Fretless Bs.",0
	.dc.b	"Acoustic Bs.",0,"Choir Aahs  ",0,"Choir Aahs  ",0,"Choir Aahs  ",0
	.dc.b	"Choir Aahs  ",0,"SlowStrings ",0,"Strings     ",0,"SynStrings 3",0
	.dc.b	"SynStrings 3",0,"Organ 1     ",0,"Organ 1     ",0,"Organ 1     ",0
	.dc.b	"Organ 2     ",0,"Organ 1     ",0,"Organ 1     ",0,"Organ 2     ",0
	.dc.b	"Organ 2     ",0,"Organ 2     ",0,"Trumpet     ",0,"Trumpet     ",0
	.dc.b	"Trombone    ",0,"Trombone    ",0,"Trombone    ",0,"Trombone    ",0
	.dc.b	"Trombone    ",0,"Trombone    ",0,"Alto Sax    ",0,"Tenor Sax   ",0
	.dc.b	"Baritone Sax",0,"Alto Sax    ",0,"Brass 1     ",0,"Brass 1     ",0
	.dc.b	"Brass 2     ",0,"Brass 2     ",0,"Brass 1     ",0,"OrchestraHit",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0

inst_CM32L:
	.dc.b	"Acou Piano 1",0,"Acou Piano 2",0,"Acou Piano 3",0,"Elec Piano 1",0
	.dc.b	"Elec Piano 2",0,"Elec Piano 3",0,"Elec Piano 4",0,"Honkytonk   ",0
	.dc.b	"Elec Org 1  ",0,"Elec Org 2  ",0,"Elec Org 3  ",0,"Elec Org 4  ",0
	.dc.b	"Pipe Org 1  ",0,"Pipe Org 2  ",0,"Pipe Org 3  ",0,"Accordion   ",0
	.dc.b	"Harpsi 1    ",0,"Harpsi 2    ",0,"Harpsi 3    ",0,"Clavi 1     ",0
	.dc.b	"Clavi 2     ",0,"Clavi 3     ",0,"Celesta 1   ",0,"Celesta 2   ",0
	.dc.b	"Syn Brass 1 ",0,"Syn Brass 2 ",0,"Syn Brass 3 ",0,"Syn Brass 4 ",0
	.dc.b	"Syn Bass 1  ",0,"Syn Bass 2  ",0,"Syn Bass 3  ",0,"Syn Bass 4  ",0
	.dc.b	"Fantasy     ",0,"Harmo Pan   ",0,"Chorale     ",0,"Glasses     ",0
	.dc.b	"Soundtrack  ",0,"Atmosphere  ",0,"Warm Bell   ",0,"Funny Vox   ",0
	.dc.b	"Echo Bell   ",0,"Ice Rain    ",0,"Oboe 2001   ",0,"Echo Pan    ",0
	.dc.b	"Doctor Solo ",0,"School Daze ",0,"Bellsinger  ",0,"Square Wave ",0
	.dc.b	"Str Sect 1  ",0,"Str Sect 2  ",0,"Str Sect 3  ",0,"Pizzicato   ",0
	.dc.b	"Violin 1    ",0,"Violin 2    ",0,"Cello 1     ",0,"Cello 2     ",0
	.dc.b	"Contrabass  ",0,"Harp 1      ",0,"Harp 2      ",0,"Guitar 1    ",0
	.dc.b	"Guitar 2    ",0,"Elec Gtr 1  ",0,"Elec Gtr 2  ",0,"Sitar       ",0
	.dc.b	"Acou Bass 1 ",0,"Acou Bass 2 ",0,"Elec Bass 1 ",0,"Elec Bass 2 ",0
	.dc.b	"Slap Bass 1 ",0,"Slap Bass 2 ",0,"Fretless 1  ",0,"Fretless 2  ",0
	.dc.b	"Flute 1     ",0,"Flute 2     ",0,"Piccolo 1   ",0,"Piccolo 2   ",0
	.dc.b	"Recorder    ",0,"Pan Pipes   ",0,"Sax 1       ",0,"Sax 2       ",0
	.dc.b	"Sax 3       ",0,"Sax 4       ",0,"Clarinet 1  ",0,"Clarinet 2  ",0
	.dc.b	"Oboe        ",0,"Engl Horn   ",0,"Bassoon     ",0,"Harmonica   ",0
	.dc.b	"Trumpet 1   ",0,"Trumpet 2   ",0,"Trombone 1  ",0,"Trombone 2  ",0
	.dc.b	"Fr Horn 1   ",0,"Fr Horn 2   ",0,"Tuba        ",0,"Brs Sect 1  ",0
	.dc.b	"Brs Sect 2  ",0,"Vibe 1      ",0,"Vibe 2      ",0,"Syn Mallet  ",0
	.dc.b	"Wind Bell   ",0,"Glock       ",0,"Tube Bell   ",0,"Xylophone   ",0
	.dc.b	"Marimba     ",0,"Koto        ",0,"Sho         ",0,"Shakuhachi  ",0
	.dc.b	"Whistle 1   ",0,"Whistle 2   ",0,"Bottleblow  ",0,"Breathpipe  ",0
	.dc.b	"Timpani     ",0,"Melodic Tom ",0,"Deep Snare  ",0,"Elec Perc 1 ",0
	.dc.b	"Elec Perc 2 ",0,"Taiko       ",0,"Taiko Rim   ",0,"Cymbal      ",0
	.dc.b	"Castanets   ",0,"Triangle    ",0,"Orche Hit   ",0,"Telephone   ",0
	.dc.b	"Bird Tweet  ",0,"One Note Jam",0,"Water Bell  ",0,"Jungle Tune ",0

inst_drums:
	.dc.b	"STANDARD 1  ",0,"STANDARD 2  ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"ROOM        ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"POWER       ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"ELECTRONIC  ",0,"TR-808/909  ",0,"DANCE       ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"JAZZ        ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"BRUSH       ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"ORCHESTRA   ",0,"ETHNIC      ",0,"KICK&SNARE  ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"SFX         ",0,"RHYTHM FX   ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"USER 1      ",0,"USER 2      ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"            ",0
	.dc.b	"            ",0,"            ",0,"            ",0,"CM-64/32L   ",0

inst_user:
	.dc.b	"User Tone   ",0

effect_reverb:
	.dc.b	"Room1 ",0,"Room2 ",0
	.dc.b	"Room3 ",0,"Hall1 ",0
	.dc.b	"Hall2 ",0,"Plate ",0
	.dc.b	"Delay ",0,"PanDly",0
effect_chorus:
	.dc.b	"Chors1",0,"Chors2",0
	.dc.b	"Chors3",0,"Chors4",0
	.dc.b	"FeedBk",0,"Flangr",0
	.dc.b	"ShoDly",0,"SDlyFB",0
effect_delay:
	.dc.b	"Delay1",0,"Delay2",0
	.dc.b	"Delay3",0,"Delay4",0
	.dc.b	"Pan1  ",0,"Pan2  ",0
	.dc.b	"Pan3  ",0,"Pan4  ",0
	.dc.b	"ToRvrb",0,"Repeat",0

	.even
