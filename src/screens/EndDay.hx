package screens;

class EndDay extends dn.Process {

	public static var ME : EndDay;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	var bg : HSprite;
	var flow : h2d.Flow;

	var nextDayBtn : ui.Button;

	public function new(numTaskCompleted:Int) {
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

		var sec = Const.PLAYER_DATA.currentTime / Const.FPS;
		var min = Std.int(sec / 60);

		function createMiniFlow(strLeft:String, strRight:String) {
			var miniFlow = new h2d.Flow(flow);
			// miniFlow.debug = true;
			miniFlow.minWidth = miniFlow.maxWidth = Std.int(wid * 0.75);

			var textLeft = new h2d.Text(Assets.fontRulergold32, miniFlow);
			textLeft.text = strLeft;
			textLeft.textColor = 0xe9dfc3;
			miniFlow.getProperties(textLeft).horizontalAlign = Left;

			var textRight = new h2d.Text(Assets.fontRulergold32, miniFlow);
			textRight.text = strRight;
			textRight.textColor = 0xe9dfc3;
			miniFlow.getProperties(textRight).horizontalAlign = Right;
		}

		createMiniFlow(	Lang.t._("Temps passé sur les alertes :"), min >= 1 ?	(min == 1 ? Lang.t._("1 minute et ::sec:: secondes", {sec:Std.int(sec) % 60}) : Lang.t._("::min:: minutes et ::sec:: secondes", {min:Std.int(min), sec:Std.int(sec) % 60})) :
																				Lang.t._("::sec:: secondes", {sec:Std.int(sec) % 60}));

		createMiniFlow(Lang.t._("Nombres d'alertes résolues :"), Std.string(numTaskCompleted));
		
		Assets.tiles.h_get("separationEndDay", flow);

		nextDayBtn = new ui.Button("Journée suivante", function() {
			nextDayBtn.clickEnable = false;
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
		flow.addChild(nextDayBtn);

		onResize();
	}

	override function onDispose() {
		super.onDispose();

		ME = null;
	}

	override function onResize() {
		super.onResize();

		bg.scaleX = wid;
		bg.scaleY = hei;

		flow.reflow();
		flow.setPosition(Std.int(wid - flow.outerWidth) >> 1, Std.int(hei - flow.outerHeight) >> 1);
	}

}