package ui;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	var flow : h2d.Flow;
	var invalidated = true;

	var timerText : h2d.Text;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);

		timerText = new h2d.Text(Assets.fontLarge, root);
		timerText.textColor = 0xe72727;
		timerText.y = -timerText.textHeight;
	}
	
	public function showTimer() {
		tw.createS(timerText.y, 0, 0.3);
	}
	
	public function hideTimer() {
		tw.createS(timerText.y, -timerText.textHeight, 0.3);
	}

	public function redWarning() {
		fx.flashBangS(0xe72727, 0.5, 0.2);
	}

	public function goodWarning() {
		fx.flashBangS(0x27e72e, 0.5, 0.5);
	}

	override function onResize() {
		super.onResize();
		timerText.x = Std.int((w() / Const.SCALE) - timerText.textWidth) >> 1;
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate() invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		timerText.text = prettyTimer((Game.ME.timer / Const.FPS) * 100);

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}

	public static function prettyTimer(v:Float, keepMinute:Bool = true, keepSecond:Bool = true):String {
		var c = v;
		var s = c/100;
		var m = s/60;
		var out = "";
		m = Std.int(m%60);
		if (m > 0 || keepMinute) {
			out += m > 9 ? Std.string(m) : "0" + m;
			out += ":";
		}
		s = Std.int(s % 60);
		if (s > 0 || keepSecond || m > 0) {
			out += s > 9 ? Std.string(s) : "0" + s;
			out += ":";
		}
		c = Std.int(c % 100);
		out += c > 9 ? Std.string(c) : "0" + c;
		
		return out;
	}
}
