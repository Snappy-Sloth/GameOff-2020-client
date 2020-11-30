package screens;

class EndDay extends dn.Process {

	public static var ME : EndDay;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(h() / Const.SCALE);

	var bg : HSprite;
	var flow : h2d.Flow;

	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		bg = Assets.tiles.h_get("whitePixel", root);
		bg.colorize(0x211812);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 50;
		flow.horizontalAlign = Middle;

		var endDayText = new h2d.Text(Assets.fontRulergold48, flow);
		endDayText.text = Lang.t._("FIN DE LA JOURNÉE");
		endDayText.textColor = 0xc7ba29;
		
		Assets.tiles.h_get("separationEndDay", flow);

		var timeText = new h2d.Text(Assets.fontRulergold32, flow);
		timeText.text = Lang.t._("Temps passé sur les alertes : X minutes et X secondes");
		timeText.textColor = 0xe9dfc3;

		var numText = new h2d.Text(Assets.fontRulergold32, flow);
		numText.text = Lang.t._("Nombres d'alertes résolues : X");
		numText.textColor = 0xe9dfc3;
		
		Assets.tiles.h_get("separationEndDay", flow);

		var btn = new ui.Button("Journée suivante", function() {
			var previous = Const.PLAYER_DATA.dayId;
			Const.PLAYER_DATA.dayId = null;
			for (i in 0...Data.day.all.length) {
				if (Data.day.all[i].id == previous) {
					Const.PLAYER_DATA.dayId = Data.day.all[i + 1].id;
					break;
				}
			}
			if (Const.PLAYER_DATA.dayId != null)
				Main.ME.continueGame();
			else {
				// TODO FIN DE DEMO
				trace("No day after " + previous);
				Main.ME.startTitleScreen();
			}
		});
		flow.addChild(btn);

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
	}

	override function onResize() {
		super.onResize();

		root.setScale(Const.SCALE);

		bg.scaleX = wid;
		bg.scaleY = hei;

		flow.reflow();
		flow.setPosition(Std.int(wid - flow.outerWidth) >> 1, Std.int(hei - flow.outerHeight) >> 1);
	}

}