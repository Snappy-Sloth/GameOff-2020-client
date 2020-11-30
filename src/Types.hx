typedef PlayerData = {
	var dayId : Data.DayKind;
	var currentEvent : Int;
	var currentTime : Float;
}

typedef OptionsData = {
	var SFX_VOLUME : Float;
	var MUSIC_VOLUME : Float;
	var LOCA : String;
}

typedef TaskData = {
	var taskKind : Data.TaskKind;
	var text : String;
	var author : String;
}

enum TalkFrom {
	Player(ptd:Array<PlayerTalkData>);
	System(td:TalkData);
	Outside(td:TalkData);
}

typedef PlayerTalkData = {
	var text : String;
	var answer : Null<TalkData>;
}

typedef TalkData = {
	var text : String;
	var author : Null<String>;
	var type : Data.TalkTypeKind;
	var timeBefore : Float;
}

enum VType {
	Value1;
	Value2;
	Value3;
	Value4;
}

typedef ValueData = {
	var vt : VType;
	var v : Int;
}

enum VolumeGroup { // M => Module
	@volume(1) M_ClicButton;
	@volume(0.5) M_ClicGrid;
	@volume(1) M_SetSymbol;
	@volume(1) M_ClicWires;
	@volume(1) M_Switch;
	@volume(0.5) M_ValueChange;
	@volume(0.5) M_ValueSelect;
	@volume(1) M_ChangeGauges;
	@volume(1) M_ChangeBars;
	@volume(1) M_NumPad;
}