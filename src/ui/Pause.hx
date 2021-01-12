package ui;

import dn.Tweenie.Tweenie;

class Pause extends dn.Process {
	
	public var wid(get,never) : Int; inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get,never) : Int; inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	var blackInter : h2d.Interactive;

	var flow : h2d.Flow;

	var btnContinue : Button;
	var btnQuit : Button;

	public function new() {
		super(Main.ME);

		createRoot();

		blackInter = new h2d.Interactive(wid, hei, root);
		blackInter.backgroundColor = 0xBB000000;

		blackInter.onClick = function (e) {
			close();
		}

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 20;
		flow.horizontalAlign = Middle;
		flow.verticalAlign = Middle;

		var bg = Assets.tiles.h_get("bgPause", flow);
		flow.getProperties(bg).isAbsolute = true;

		flow.minWidth = flow.maxWidth = Std.int(bg.tile.width);
		flow.minHeight = flow.maxHeight = Std.int(bg.tile.height);

		btnContinue = new Button(Lang.t._("Reprendre"), close);
		flow.addChild(btnContinue);

		flow.addSpacing(20);

		btnQuit = new Button(Lang.t._("Quitter"), backToTitle);
		flow.addChild(btnQuit);

		var text = new h2d.Text(Assets.fontM5x7gold16, flow);
		text.maxWidth = flow.maxWidth * 0.75;
		text.textAlign = Center;
		text.textColor = 0x874727;
		text.text = Lang.t._("Vous reprendrez au début de la journée lorsque vous continuerez votre partie.");

		onResize();
		
		tw.createS(blackInter.alpha, 0 > 1, 0.5);
		flow.y += hei;
		tw.createS(flow.y, flow.y - hei, TElasticEnd, 0.3);
		Assets.CREATE_SOUND(hxd.Res.sfx.ui_whooshPause, UI_WhooshPause);
	}

	function backToTitle() {
		btnContinue.clickEnable = false;
		btnQuit.clickEnable = false;
		// new Transition(function () {
			// destroy();
			Main.ME.startTitleScreen();
		// });
	}

	function close() {
		btnContinue.clickEnable = false;
		btnQuit.clickEnable = false;
		tw.createS(blackInter.alpha, 0, 0.2);
		tw.createS(flow.y, flow.y + hei, 0.2).onEnd = destroy;
		Assets.CREATE_SOUND(hxd.Res.sfx.ui_whooshPause, UI_WhooshPause);
	}

	override function onDispose() {
		super.onDispose();

		Game.ME.resume();
	}

	override function onResize() {
		super.onResize();

		blackInter.width = wid;
		blackInter.height = hei;

		flow.setPosition(Std.int(wid - flow.outerWidth) >> 1, Std.int(hei - flow.outerHeight) >> 1);
	}

}