typedef TaskData = {
	var taskKind : Data.TaskKind;
	var text : String;
	var author : String;
}

enum TalkType {
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
	var bgColor : Null<UInt>;
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