package screens;

class Communication extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : Communication;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(h() / Const.SCALE);

	var mainWrapper : h2d.Mask;
	var mainWrapperPadding : Int = 10;

	var bgWrapper : h2d.Bitmap;

	var arMessages : Array<h2d.Flow>;

	var isTypingText : h2d.Text;
	var isOfflineText : h2d.Text;

	var currentTalk : Array<Data.Day_events_talks>;
	var currentTalkProgress : Int;
	var waitForPlayer = false;

	var forcedMessage : {text:String, author:String} = null;

	var goToManualBtn : ui.Button;
	var goToModulesBtn : ui.Button;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);
		
		mainWrapper = new h2d.Mask(Std.int(wid * 0.75), Std.int(hei * 0.75), root);
		bgWrapper = new h2d.Bitmap(h2d.Tile.fromColor(0x5e5e5e), mainWrapper);

		arMessages = [];

		isTypingText = new h2d.Text(Assets.fontSmall, mainWrapper);
		isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: "XXX"});
		isTypingText.alpha = 0;

		isOfflineText = new h2d.Text(Assets.fontSmall, mainWrapper);
		isOfflineText.textColor = 0x9e9e9e;
		isOfflineText.text = Lang.t._("::name:: est hors ligne...", {name: "XXX"});
		isOfflineText.alpha = 0;

		goToManualBtn = new ui.Button("Manual", Game.ME.showManual);
		root.add(goToManualBtn, 1);

		goToModulesBtn = new ui.Button("Modules", Game.ME.showModules);
		root.add(goToModulesBtn, 1);

		onResize();
	}

	public function launchTalk() {
		currentTalk = Data.day.get(Day_1).events[0].talks.toArrayCopy();
		currentTalkProgress = 0;

		tw.createS(isTypingText.alpha, 1, 0.5);

		if (currentTalk[currentTalkProgress].author != null) {
			isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: currentTalk[currentTalkProgress].author});
			cd.setS("newText", 2);
		}
	}

	public function nextMessage() {
		if (forcedMessage != null) {
			showMessage(forcedMessage.text, forcedMessage.author);
			forcedMessage = null;

			if (currentTalk != null)
				currentTalkProgress++;
		}
		else if (currentTalk[currentTalkProgress].anwsers.length > 0) {
			showAnswers();
		}
		else {
			showMessage(currentTalk[currentTalkProgress].text, currentTalk[currentTalkProgress].author);
			currentTalkProgress++;
			if (currentTalkProgress >= currentTalk.length) {
				currentTalk = null;
				
				delayer.addS(()->tw.createS(isOfflineText.alpha, 1, 1), 1);
			}
		}
	}

	public function showMessage(text:String, from:Null<String> = null) { // if from == null => it's the hero
		if (from != null) {
			tw.createS(isTypingText.alpha, 0, 0.2);
		}

		var messageFlow = new h2d.Flow(mainWrapper);
		messageFlow.backgroundTile = h2d.Tile.fromColor(from != null ? 0x439d2a : 0x28749a);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = from != null ? Left : Right;
		messageFlow.maxWidth = Std.int(mainWrapper.width * 0.75);
		arMessages.push(messageFlow);

		var authorText = new h2d.Text(Assets.fontMedium, messageFlow);
		authorText.text = from != null ? from : "You";

		var messageText = new h2d.Text(Assets.fontSmall, messageFlow);
		messageText.text = Lang.t.get(text);

		messageFlow.reflow();
		messageFlow.setPosition(from != null ? mainWrapperPadding : mainWrapper.width - messageFlow.outerWidth - mainWrapperPadding, mainWrapper.height + 5);

		var dist = messageFlow.outerHeight + mainWrapperPadding + 30;

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		for (flow in arMessages) {
			tw.createS(flow.y, flow.y - dist, 0.2);
		}

		cd.setS("newText", 1 + text.length * 0.03);
		
		if (currentTalk != null && nextMessageIsNotFromYou()) {
			isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: currentTalk[currentTalkProgress + 1].author});
			delayer.addS(()->tw.createS(isTypingText.alpha, 1, 0.2), 1);
		}
	}

	public function forceMessage(text:String, author:String) {
		forcedMessage = {text: text, author: author};
	}

	public function showAnswers() {
		waitForPlayer = true;

		// var answers = ["I'm a the first anwser", "I am the second answer and I'm very very very very very very very very very long", "I am the third answer"];

		var flowAnswers = new h2d.Flow(mainWrapper);
		flowAnswers.layout = Vertical;
		flowAnswers.horizontalAlign = Right;
		flowAnswers.minWidth = flowAnswers.maxWidth = Std.int(mainWrapper.width * 0.5);
		flowAnswers.verticalSpacing = 2;
		flowAnswers.padding = 5;
		flowAnswers.backgroundTile = h2d.Tile.fromColor(0, 1, 1, 0.5);
		
		for (a in currentTalk[currentTalkProgress].anwsers) {
			var flow = new h2d.Flow(flowAnswers);
			flow.paddingHorizontal = 5;
			flow.paddingVertical = 15;
			flow.horizontalAlign = Right;
			flow.backgroundTile = h2d.Tile.fromColor(0, 1, 1, 0.5);
			flow.minWidth = Std.int(flowAnswers.innerWidth);
			
			var text = new h2d.Text(Assets.fontMedium, flow);
			text.text = Lang.t.get(a.text);

			var inter = new h2d.Interactive(1, 1, flow);
			flow.getProperties(inter).isAbsolute = true;
			inter.onClick = function (e) {
				tw.createS(flowAnswers.alpha, 0, 0.2);
				tw.createS(flowAnswers.y, flowAnswers.y + flowAnswers.outerHeight, 0.2);
				delayer.addS(function () {
					flowAnswers.removeChildren();
					flowAnswers.remove();

					showMessage(a.text);
					forceMessage(a.answer, a.author);
					waitForPlayer = false;
				}, 0.21);
			}
			
			flow.reflow();
			inter.width = flow.outerWidth;
			inter.height = flow.outerHeight;
		}

		flowAnswers.reflow();
		flowAnswers.setPosition(mainWrapper.width - flowAnswers.outerWidth, mainWrapper.height - flowAnswers.outerHeight);
	}

	public function nextMessageIsNotFromYou() : Bool return currentTalk[currentTalkProgress + 1] != null && currentTalk[currentTalkProgress + 1].author != null;
	
	override function onResize() {
		super.onResize();

		goToManualBtn.setPosition((w() / Const.SCALE) - goToManualBtn.wid - 7, ((h() / Const.SCALE) - goToManualBtn.hei) / 2);
		goToModulesBtn.setPosition(7, ((h() / Const.SCALE) - goToModulesBtn.hei) / 2);

		bgWrapper.scaleX = mainWrapper.width;
		bgWrapper.scaleY = mainWrapper.height;

		mainWrapper.setPosition((wid - mainWrapper.width) >> 1, (hei - mainWrapper.height) >> 1);

		isTypingText.setPosition(mainWrapperPadding + 5, mainWrapper.height - mainWrapperPadding - isTypingText.textHeight);
		isOfflineText.setPosition(mainWrapperPadding + 5, mainWrapper.height - mainWrapperPadding - isOfflineText.textHeight);
	}

	override function update() {
		super.update();

		if (currentTalk != null || forcedMessage != null) {
			if (!waitForPlayer && !cd.has("newText")) {
				nextMessage();
			}
		}

		// if (hxd.Key.isPressed(hxd.Key.F1)) {
		// 	launchTalk();
		// }
		// if (hxd.Key.isPressed(hxd.Key.F2)) {
		// 	newMessage("Hello, I'm a test!");
		// }
	}
}