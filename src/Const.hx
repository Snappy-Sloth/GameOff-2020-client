class Const {
	public static var FPS = 60;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = 1280; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = 720; // -1 to disable auto-scaling on height
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var GRID = 16;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get,never) : Int; static inline function get_NEXT_UNIQ() return _uniq++;
	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;

	public static inline var BUTTON_WIDTH = 100;
	public static inline var BUTTON_HEIGHT = 50;

	// public static inline var SHEET_WIDTH = 840;
	// public static inline var SHEET_HEIGHT = 1188;
	public static inline var SHEET_WIDTH = 420;
	public static inline var SHEET_HEIGHT = 594;
	public static inline var SHEET_ANGLE = 0.0006;

	public static inline var MODULE_WIDTH = 500;
	public static inline var MODULE_HEIGHT = 150;

	public static var PLAYER_DATA : PlayerData;
	public static var OPTIONS_DATA : OptionsData;
	
	public static function INIT() {
		PLAYER_DATA = dn.LocalStorage.readObject("playerData", false, {dayId:Data.DayKind.Day_1, currentEvent:0, currentTime: 0.});

		OPTIONS_DATA = dn.LocalStorage.readObject("optionsData", false, {SFX_VOLUME: 1., MUSIC_VOLUME: 1., LOCA : "en"});
			// #if debug 
			// {SFX_VOLUME: 0., MUSIC_VOLUME: 0.}
			// #else
			// {SFX_VOLUME: 1., MUSIC_VOLUME: 1.}
			// #end);

		// Assets.UPDATE_MUSIC_VOLUME();
	}

	public static function SAVE_PROGRESS(d:Data.DayKind, currentEvent:Int) {
		PLAYER_DATA.dayId = d;
		PLAYER_DATA.currentEvent = currentEvent;
		
		dn.LocalStorage.writeObject("playerData", false, PLAYER_DATA);
	}

	public static function CHANGE_LOCA(loca:String) {
		OPTIONS_DATA.LOCA = loca;

		dn.LocalStorage.writeObject("optionsData", false, OPTIONS_DATA);
	}
}
