package screens;

class Communication extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : Communication;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(h() / Const.SCALE);

	var mainWrapper : h2d.Mask;
	var mainWrapperPadding : Int = 10;

	var bgWrapper : h2d.Bitmap;

	var arMessageFlow : Array<h2d.Flow>;

	var isTypingText : h2d.Text;

	var waitForPlayer = false;
	
	var currentAuthor : Null<String> = null;
	
	var pendingMessages : Array<TalkType>;
	var currentMessage : TalkType;
	var nextMessage(get, never) : Null<TalkType>;		inline function get_nextMessage() return pendingMessages[0];

	var goToManualBtn : ui.Button;
	var goToModulesBtn : ui.Button;

	var lastMessage : TalkType;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);
		
		mainWrapper = new h2d.Mask(Std.int(wid * 0.75), Std.int(hei * 0.75), root);
		bgWrapper = new h2d.Bitmap(h2d.Tile.fromColor(0x5e5e5e), mainWrapper);

		arMessageFlow = [];

		isTypingText = new h2d.Text(Assets.fontSmall, mainWrapper);
		isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: "XXX"});
		isTypingText.alpha = 0;

		goToManualBtn = new ui.Button("Manual", Game.ME.showManual);
		root.add(goToManualBtn, 1);

		goToModulesBtn = new ui.Button("Modules", Game.ME.showModules);
		root.add(goToModulesBtn, 1);

		pendingMessages = [];

		onResize();
	}

	public function initTalk() {
		pendingMessages = [];

		for (det in game.currentEvent.talks) {
			if (det.answers.length > 0) {
				var texts : Array<PlayerTalkData> = [];
				for (answer in det.answers) {
					texts.push({text:answer.text, answer:answer.answer != null ? {text: answer.answer, author: answer.customAuthor, bgColor: answer.customBGColor} : null});
				}
				pendingMessages.push(Player(texts));
			}
			else if (det.customAuthor == "System") {
				pendingMessages.push(System({author:"System", text: det.text, bgColor: det.customBGColor}));
			}
			else {
				pendingMessages.push(Outside({author:det.customAuthor, text: det.text, bgColor: det.customBGColor}));
			}
		}

		lastMessage = pendingMessages[pendingMessages.length - 1];

		if (currentAuthor != game.currentEvent.author) {
			currentAuthor = game.currentEvent.author;
			forceSystemMessage(Lang.t._("::name:: est en ligne", {name:currentAuthor}));
		}

		isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: currentAuthor});

		switch (nextMessage) {
			case Player(ptd):
			case System(td):
			case Outside(td):
				tw.createS(isTypingText.alpha, 1, 0.5);
				cd.setS("newText", 2);
		}
	}

	public function showNextMessage() {
		currentMessage = pendingMessages.shift();

		switch (currentMessage) {
			case Player(ptds):
				showPlayerAnswers(ptds);
			case System(td):
				showSystemMessage(td);
			case Outside(td):
				showOutsideMessage(td);
		}
	}

	function showPlayerAnswers(ptds:Array<PlayerTalkData>) {
		waitForPlayer = true;

		var flowAnswers = new h2d.Flow(mainWrapper);
		flowAnswers.layout = Vertical;
		flowAnswers.horizontalAlign = Right;
		flowAnswers.minWidth = flowAnswers.maxWidth = Std.int(mainWrapper.width * 0.5);
		flowAnswers.verticalSpacing = 2;
		flowAnswers.padding = 5;
		flowAnswers.backgroundTile = h2d.Tile.fromColor(0, 1, 1, 0.5);
		
		for (a in ptds) {
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
				if (!waitForPlayer)
					return;
				
				tw.createS(flowAnswers.alpha, 0, 0.2);
				tw.createS(flowAnswers.y, flowAnswers.y + flowAnswers.outerHeight, 0.2);
				delayer.addS(function () {
					flowAnswers.removeChildren();
					flowAnswers.remove();

					if (a.answer != null) {
						var m = forceOutsideMessage(a.answer);
						if (lastMessage == currentMessage) {
							lastMessage = m;
						}
					}
					showPlayerMessage(a.text);
					waitForPlayer = false;
				}, 0.21);
			}
			
			flow.reflow();
			inter.width = flow.outerWidth;
			inter.height = flow.outerHeight;
		}

		flowAnswers.reflow();
		flowAnswers.setPosition(mainWrapper.width - flowAnswers.outerWidth, mainWrapper.height - flowAnswers.outerHeight);

		flowAnswers.x += flowAnswers.outerWidth;
		tw.createS(flowAnswers.alpha, 0 > 1, 0.2);
		tw.createS(flowAnswers.x, flowAnswers.x - flowAnswers.outerWidth, 0.2);
	}

	function showPlayerMessage(text:String) {
		var messageFlow = new h2d.Flow(mainWrapper);
		messageFlow.backgroundTile = h2d.Tile.fromColor(0x28749a);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Right;
		messageFlow.maxWidth = Std.int(mainWrapper.width * 0.5);
		arMessageFlow.push(messageFlow);

		var authorText = new h2d.Text(Assets.fontMedium, messageFlow);
		authorText.text = Lang.t._("Vous");

		var messageText = new h2d.Text(Assets.fontSmall, messageFlow);
		messageText.text = Lang.t.get(text);

		messageFlow.reflow();
		messageFlow.setPosition(mainWrapper.width - messageFlow.outerWidth - mainWrapperPadding, mainWrapper.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);
		
		updatePostedMessages(messageFlow.outerHeight + mainWrapperPadding + 30, text);
	}

	function showSystemMessage(td:TalkData) {
		var messageFlow = new h2d.Flow(mainWrapper);
		messageFlow.backgroundTile = h2d.Tile.fromColor(0x2f2c3a);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Middle;
		messageFlow.minWidth = messageFlow.maxWidth = Std.int(mainWrapper.width - mainWrapperPadding * 2);
		arMessageFlow.push(messageFlow);

		var messageText = new h2d.Text(Assets.fontMedium, messageFlow);
		messageText.text = Lang.t.get(td.text);

		messageFlow.reflow();
		messageFlow.setPosition(mainWrapperPadding, mainWrapper.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		updatePostedMessages(messageFlow.outerHeight + mainWrapperPadding + 30, td.text);
	}

	function showOutsideMessage(td:TalkData) {
		tw.createS(isTypingText.alpha, 0, 0.2);

		var messageFlow = new h2d.Flow(mainWrapper);
		messageFlow.backgroundTile = h2d.Tile.fromColor(td.bgColor != null ? td.bgColor : 0x439d2a);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Left;
		messageFlow.maxWidth = Std.int(mainWrapper.width * 0.5);
		arMessageFlow.push(messageFlow);

		var authorText = new h2d.Text(Assets.fontMedium, messageFlow);
		authorText.text = td.author != null ? td.author : currentAuthor;

		var messageText = new h2d.Text(Assets.fontSmall, messageFlow);
		messageText.text = Lang.t.get(td.text);

		messageFlow.reflow();
		messageFlow.setPosition(mainWrapperPadding, mainWrapper.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		updatePostedMessages(messageFlow.outerHeight + mainWrapperPadding + 30, td.text);
	}

	function updatePostedMessages(dist:Float, text:String) {
		for (flow in arMessageFlow) {
			tw.createS(flow.y, flow.y - dist, 0.2);
		}

		switch (nextMessage) {
			case null :
			case Player(ptd): cd.setS("newText", 1);
			case System(td) : cd.setS("newText", 0.5);
			case Outside(td) :
				cd.setS("newText", td.text.length * 0.04);
				isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: currentAuthor});
				delayer.addS(()->tw.createS(isTypingText.alpha, 1, 0.2), 0.5);
		}

		if (currentMessage == lastMessage) {
			lastMessage = null;
			delayer.addS(game.nextEvent, 1);
		}
	}

	public function showOffline() {
		forceSystemMessage(Lang.t._("::name:: est hors ligne...", {name: currentAuthor}));
	}

	public function forceSystemMessage(text:String) {
		pendingMessages.unshift(System({author:"System", text: text, bgColor: null}));
	}

	public function forceOutsideMessage(td:TalkData):TalkType {
		var m = Outside(td);
		pendingMessages.unshift(m);
		return m;
	}

	override function onResize() {
		super.onResize();

		goToManualBtn.setPosition((w() / Const.SCALE) - goToManualBtn.wid - 7, ((h() / Const.SCALE) - goToManualBtn.hei) / 2);
		goToModulesBtn.setPosition(7, ((h() / Const.SCALE) - goToModulesBtn.hei) / 2);

		bgWrapper.scaleX = mainWrapper.width;
		bgWrapper.scaleY = mainWrapper.height;

		mainWrapper.setPosition((wid - mainWrapper.width) >> 1, (hei - mainWrapper.height) >> 1);

		isTypingText.setPosition(mainWrapperPadding + 5, mainWrapper.height - mainWrapperPadding - isTypingText.textHeight);
	}

	override function update() {
		super.update();

		if (nextMessage != null) {
			if (!waitForPlayer && !cd.has("newText")) {
				showNextMessage();
			}
		}
	}
}