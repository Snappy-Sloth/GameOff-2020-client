package ui;

class Options extends dn.Process {
	
	public var wid(get, never):Int;		inline function get_wid() return Const.AUTO_SCALE_TARGET_WID;
	public var hei(get, never):Int;		inline function get_hei() return Const.AUTO_SCALE_TARGET_HEI;

	var mainFlow : h2d.Flow;
	var flow : h2d.Flow;
	var bgFlow : h2d.ScaleGrid;
	var nextLevelBtn : Button;

	var controlLock(default, null) = false;
	
	var cinematic : dn.Cinematic;

	var blackBG : h2d.Interactive;

	public function new() {
		super(Main.ME);

		createRoot();

		blackBG = new h2d.Interactive(wid, hei, root);
		blackBG.backgroundColor = 0xDD000000;

		cinematic = new dn.Cinematic(Const.FPS);

		mainFlow = new h2d.Flow(root);
		mainFlow.layout = Vertical;
		mainFlow.horizontalAlign = Middle;
		mainFlow.verticalSpacing = 30;

		flow = new h2d.Flow(mainFlow);
		flow.layout = Vertical;
		// flow.debug = true;
		flow.horizontalAlign = Middle;
		flow.verticalSpacing = 15;
		flow.padding = 10;

		bgFlow = new h2d.ScaleGrid(Assets.tiles.getTile("bgOptions"), 90, 90, flow);
		flow.getProperties(bgFlow).isAbsolute = true;

		var optionsText = new h2d.Text(Assets.fontRulergold32, flow);
		optionsText.text = 'OPTIONS';
		// optionsText.alpha = 0;
		optionsText.dropShadow = {dx: 0, dy: 2, alpha: 1, color: 0x2770c4};

		createSliderFlow("SFX", Const.OPTIONS_DATA.SFX_VOLUME, function (v) {
			Const.OPTIONS_DATA.SFX_VOLUME = v;
			Assets.UPDATE_SFX_VOLUME();
		});
		createSliderFlow("Music", Const.OPTIONS_DATA.MUSIC_VOLUME, function (v) {
			Const.OPTIONS_DATA.MUSIC_VOLUME = v;
			Assets.UPDATE_MUSIC_VOLUME();
		});

		// var creditsText = new h2d.Text(Assets.fontM5x7gold16, flow);
		// creditsText.lineSpacing = 10;
		// // creditsText.textColor = 0x404040;
		// creditsText.text = "- A game developed by Titaninette and Tipyx";
		// creditsText.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x895515};

		nextLevelBtn = new Button("Back", onClickBtn);
		mainFlow.addChild(nextLevelBtn);

		onResize();

		flow.y -= (h()/Const.SCALE);
		nextLevelBtn.y += (h()/Const.SCALE);
		
		tw.createS(flow.y, flow.y + (h()/Const.SCALE), 0.5);
		tw.createS(nextLevelBtn.y, nextLevelBtn.y - (h()/Const.SCALE), 0.5).end(()->cinematic.signal());
		tw.createS(blackBG.alpha, 0 > 1, 0.5);
	}

	public function onClickBtn() {
		if (controlLock) return;
		controlLock = true;
		cinematic.create({
			tw.createS(flow.y, flow.y-(h()/Const.SCALE), 0.5);
			tw.createS(nextLevelBtn.y, nextLevelBtn.y+(h()/Const.SCALE), 0.5).end(()->cinematic.signal());
			tw.createS(blackBG.alpha, 0, 0.5);
			end;
			screens.TitleScreen.ME.enableClick();
			this.destroy();
		});
	}

	function createSliderFlow(name:String, initialValue:Float, onChange:Float->Void) {
		var subFlow = new h2d.Flow(flow);
		subFlow.layout = Horizontal;
		subFlow.verticalAlign = Middle;
		subFlow.horizontalSpacing = 20;
		subFlow.minWidth = subFlow.maxWidth = flow.innerWidth;

		var text = new h2d.Text(Assets.fontRulergold16, subFlow);
		text.text = name;
		text.textColor = 0xFFFFFF;
		text.dropShadow = {dx: 0, dy: 1, alpha: 1, color: 0x2770c4};
		subFlow.getProperties(text).horizontalAlign = Left;
		subFlow.getProperties(text).minWidth = 50;
		subFlow.getProperties(text).paddingLeft = 10;
		
		var slider = new Slider(initialValue, onChange);
		subFlow.addChild(slider);
		subFlow.getProperties(slider).horizontalAlign = Right;
	}

	override function onResize() {
		super.onResize();
		
		flow.reflow();

		bgFlow.width = flow.outerWidth;
		bgFlow.height = flow.outerHeight;

		mainFlow.reflow();
		mainFlow.setPosition(Std.int((w() / Const.SCALE) - mainFlow.outerWidth) >> 1, Std.int((h() / Const.SCALE) - mainFlow.outerHeight) >> 1);
	}

	override function update() {
		super.update();

		cinematic.update(tmod);
	}

}