package ui;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(h() / Const.SCALE);

	var flow : h2d.Flow;
	var invalidated = true;

	var globalGlow : HSprite;

	var wrapperTimer : h2d.Object;
	var glowTimer : HSprite;
	var timerText : h2d.Text;

	var bgNewMessage : HSprite;
	var wrapperNewMessage : h2d.Object;
	var newMessageText : h2d.Text;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);

		globalGlow = Assets.tiles.h_get("globalRedGlow", 0.5, 0.5, root);
		globalGlow.setScale(1.2);

		{ // TIMER
			wrapperTimer = new h2d.Object(root);

			var bg = Assets.tiles.h_get("bgTimer", 0, 0.5, wrapperTimer);
	
			glowTimer = Assets.tiles.h_get("redGlowTimer", 0.5, 0.5, wrapperTimer);
	
			timerText = new h2d.Text(Assets.fontLarge, wrapperTimer);
			timerText.textColor = 0xe72727; //0x27e761
			
			wrapperTimer.y = -timerText.textHeight - 50;
		}

		wrapperNewMessage = new h2d.Object(root);

		bgNewMessage = Assets.tiles.h_get("bgNewMessage", wrapperNewMessage);
		
		newMessageText = new h2d.Text(Assets.fontRulergold32, wrapperNewMessage);
		newMessageText.textColor = 0xFFFFFF;
		newMessageText.text = Lang.t._("New message!");
		newMessageText.maxWidth = bgNewMessage.tile.width;
		newMessageText.setPosition(Std.int(bgNewMessage.tile.width - newMessageText.textWidth) >> 1, Std.int(bgNewMessage.tile.height - newMessageText.textHeight) >> 1);
	}
	
	public function showTimer() {
		glowTimer.set("redGlowTimer");
		tw.createS(wrapperTimer.y, 0, 0.3);
		tw.createS(globalGlow.scaleX, 1, 0.6);
		tw.createS(globalGlow.scaleY, 1, 0.6);
	}
	
	public function endAlert() {
		glowTimer.set("greenGlowTimer");
		timerText.textColor = 0x27e761;
		tw.createS(globalGlow.scaleX, 1.2, 0.6);
		tw.createS(globalGlow.scaleY, 1.2, 0.6);
		delayer.addS(function() {
			tw.createS(wrapperTimer.y, -timerText.textHeight - 50, 0.3);
		}, 2);
	}
	
	public function showNewMessage() {
		tw.createS(wrapperNewMessage.y, 0, 0.3);
	}
	
	public function hideNewMessage() {
		tw.createS(wrapperNewMessage.y, -bgNewMessage.tile.height, 0.3);
	}

	public function redWarning() {
		fx.flashBangS(0xe72727, 0.5, 0.2);
	}

	public function goodWarning() {
		fx.flashBangS(0x27e72e, 0.5, 0.5);
	}

	override function onResize() {
		super.onResize();

		wrapperNewMessage.x = wid - bgNewMessage.tile.width - 10;

		timerText.text = prettyTimer((Game.ME.timer / Const.FPS) * 100);
		timerText.x = -Std.int(timerText.textWidth) >> 1;
		// wrapperTimer.x = Std.int((w() / Const.SCALE) - timerText.textWidth) >> 1;
		wrapperTimer.x = Std.int(w() / Const.SCALE) >> 1;
		glowTimer.setPosition(0, timerText.textHeight * 0.5);

		globalGlow.setPos(wid >> 1, hei >> 1);
	}

	public inline function invalidate() invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		timerText.text = prettyTimer((Game.ME.timer / Const.FPS) * 100);

		if (!cd.hasSetS("blinkNewMessage", 0.5))
			newMessageText.visible = !newMessageText.visible;

		if (game.alertIsActive) {
			globalGlow.alpha = 0.75 + 0.25 * Math.cos(5 + (ftime / 10));
			glowTimer.alpha = 0.75 + 0.25 * Math.cos(ftime / 10);
		}

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
