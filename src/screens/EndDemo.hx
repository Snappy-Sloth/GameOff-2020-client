package screens;

class EndDemo extends dn.Process {

	public static var ME : EndDemo;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(Const.AUTO_SCALE_TARGET_WID);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(Const.AUTO_SCALE_TARGET_HEI);

	var bg : HSprite;
	var flow : h2d.Flow;

	var nextDayBtn : ui.Button;

	var asteriskText : h2d.Text;

	public function new() {
		super(Main.ME);

		ME = this;

		createRoot();

		bg = Assets.tiles.h_get("whitePixel", root);
		bg.colorize(0x211812);

		flow = new h2d.Flow(root);
		flow.layout = Vertical;
		flow.verticalSpacing = 25;
		flow.horizontalAlign = Middle;

		var endDayText = new h2d.Text(Assets.fontRulergold48, flow);
		endDayText.text = Lang.t._("Merci d'avoir joué au prototype de");
		endDayText.textColor = 0xc7ba29;
		
		Assets.tiles.h_get("logoGame", flow);

		Assets.tiles.h_get("separationEndDay", flow);

		var sec = Const.PLAYER_DATA.currentTime / Const.FPS;
		var min = Std.int(sec / 60);

		var timeText = new h2d.Text(Assets.fontRulergold32, flow);
		timeText.textColor = 0xe9dfc3;
		timeText.text = Lang.t._("Vous avez mis ::min:: minutes et ::sec:: secondes à résoudre toutes les alarmes !", {min: min, sec:Std.int(sec) % 60});

		Assets.tiles.h_get("separationEndDay", flow);

		function createText(str:String) {
			var text = new h2d.Text(Assets.fontRulergold16, flow);
			text.textColor = 0xe9dfc3;
			text.text = str;
		}

		createText(Lang.t._("Qui a envoyé ce mystérieux message ?"));
		flow.addSpacing(-15);
		createText(Lang.t._("Est-ce que vous et Hayley réussirez à terminer cette mission vitale ?"));
		flow.addSpacing(-15);
		createText(Lang.t._("Pourquoi cette interface de communication est aussi austère ?"));
		
		flow.addSpacing(15);

		createText(Lang.t._("Autant de questions qui trouveront leurs réponses dans la version finale du jeu* !"));

		asteriskText = new h2d.Text(Assets.fontRulergold16, root);
		asteriskText.textColor = 0xe9dfc3;
		asteriskText.text = Lang.t._("*Disponible... quand elle sera finie :D");
		
		flow.addSpacing(15);

		createText(Lang.t._("Si vous avez aimé cette démo, n'hésitez surtout pas à nous le faire savoir sur Twitter (@SnappySloth), ainsi qu'à le partager un maximum !"));
		
		Assets.tiles.h_get("separationEndDay", flow);

		nextDayBtn = new ui.Button("Écran Titre", function() {
			nextDayBtn.clickEnable = false;
			Main.ME.startTitleScreen();
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

		asteriskText.setPosition(Std.int(wid - asteriskText.textWidth - 20), Std.int(hei - asteriskText.textHeight - 20));
	}

}