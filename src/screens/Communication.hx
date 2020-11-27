package screens;

class Communication extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public static var ME : Communication;
	
	public var wid(get, never):Int;		inline function get_wid() return Std.int(w() / Const.SCALE);
	public var hei(get, never):Int;		inline function get_hei() return Std.int(h() / Const.SCALE);

	var mainWrapper : h2d.Mask;

	var bgWrapper : h2d.Bitmap;
	
	var currentAuthor : Null<String> = null;

	var goToManualBtn : ui.Button;
	var goToModulesBtn : ui.Button;

	var talks : Array<Talk> = [];

	var wrapperTab : h2d.Object;
	var tabs : Array<Tab> = [];
	var currentTabId = 0;

	public function new() {
		super(Game.ME);

		ME = this;

		createRoot(Game.ME.wrapperScreens);

		var screen = Assets.tiles.h_get("commScreen", root);
		
		mainWrapper = new h2d.Mask(916, 410, root);

		var reflect = Assets.tiles.h_get("commScreenReflect", root);

		goToManualBtn = new ui.Button("Manual", Game.ME.showManual);
		root.add(goToManualBtn, 1);

		goToModulesBtn = new ui.Button("Modules", Game.ME.showModules);
		root.add(goToModulesBtn, 1);

		initScreen();

		onResize();
	}

	function initScreen() {
		mainWrapper.removeChildren();

		// Content
		bgWrapper = new h2d.Bitmap(h2d.Tile.fromColor(0x081c0c), mainWrapper);

		// Tabs
		wrapperTab = new h2d.Object(mainWrapper);

		var line = Assets.tiles.h_get("tabLine", wrapperTab);
		line.y = 16;

		// getTalk("Astro");
	}

	function addTab(author:String) : Tab {
		for (tab in tabs) {
			if (tab.author == author)
				return tab;
		}

		var tab = new Tab(this, author);
		wrapperTab.addChild(tab.root);
		tab.root.x = 20 + tabs.length * 101;
		tabs.push(tab);

		return tab;
	}

	public function selectTab(author:String) {
		for (tab in tabs) {
			if (tab.author == author)
				tab.select();
			else
				tab.unselect();
		}

		for (talk in talks) {
			talk.root.visible = talk.author == author;
		}
	}

	function getTalk(author:String):Talk {
		for (talk in talks) {
			if (talk.author == author)
				return talk;
		}

		var talk = new Talk(this, author);
		talk.root.visible = false;
		talks.push(talk);
		talk.root.y = 17;
		return talk;
	}

	function getMainTalk():Talk {
		for (talk in talks) {
			if (talk.author== "Astro")
				return talk;
		}

		return null;
	}

	public function initTalk() {
		var talk = getTalk(game.currentEvent.author);

		addTab(game.currentEvent.author).newMessage();

		if (talk == talks[0])
			selectTab(talk.author);

		talk.initNextTalk();
	}

	public function clearAll() {
		initScreen();

		onResize();
	}

	public function showOffline() {
		getMainTalk().forceSystemMessage(Lang.t._("::name:: est hors ligne...", {name: currentAuthor}));
	}
	
	public function forceOutsideMessage(td:TalkData) {
		getMainTalk().forceOutsideMessage(td);
	}
	
	public function forceSystemMessage(text:String, type:Data.TalkTypeKind = Normal) {
		getMainTalk().forceSystemMessage(text, type);
	}

	override function onResize() {
		super.onResize();

		goToManualBtn.setPosition((w() / Const.SCALE) - goToManualBtn.wid - 7, ((h() / Const.SCALE) - goToManualBtn.hei) / 2);
		goToModulesBtn.setPosition(7, ((h() / Const.SCALE) - goToModulesBtn.hei) / 2);

		bgWrapper.scaleX = mainWrapper.width;
		bgWrapper.scaleY = mainWrapper.height;

		// mainWrapper.setPosition((wid - mainWrapper.width) >> 1, (hei - mainWrapper.height) >> 1);
		mainWrapper.setPosition(182, 135);
	}
}

private class Tab extends dn.Process {

	var bg : HSprite;
	var text : h2d.Text;

	public var hasNewMessage : Bool = false;

	public var author(default, null) : String;

	public var isSelected = false;

	var blink = false;

	public function new(comm:Communication, author:String) {
		super(comm);

		createRoot();

		this.author = author;

		bg = Assets.tiles.h_get("tabFGNew", root);

		var inter = new h2d.Interactive(bg.tile.width, bg.tile.height, root);
		inter.onClick = function (e) {
			comm.selectTab(author);
		}

		text = new h2d.Text(Assets.fontRulergold16, root);
		text.text = author;
		text.textColor = 0x43b643;
		text.setPosition(Std.int(bg.tile.width - text.textWidth) >> 1, Std.int(bg.tile.height - text.textHeight) >> 1);

		unselect();
	}

	public function select() {
		bg.set("tabCurrent");
		hasNewMessage = false;
		text.textColor = 0x43b643;
	}

	public function newMessage() {
		hasNewMessage = true;
		unselect();
	}
	
	public function unselect() {
		text.textColor = hasNewMessage ? 0x081c0c : 0x43b643;
		bg.set(hasNewMessage ? "tabFGNew" : "tabFGNormal");
	}

	override function update() {
		super.update();

		if (hasNewMessage && !isSelected && !cd.hasSetS("blink", 0.4)) {
			text.textColor = blink ? 0x081c0c : 0x43b643;
			bg.set(blink ? "tabFGNew" : "tabFGNormal");
			blink = !blink;
		}
	}
}

private class Talk extends dn.Process {

	public var author(default, null) : String;
	
	var mainWrapperPadding : Int = 10;
	
	var pendingMessages : Array<TalkFrom>;
	var currentMessage : TalkFrom;
	var nextMessage(get, never) : Null<TalkFrom>;		inline function get_nextMessage() return pendingMessages[0];

	var waitForPlayer = false;

	var lastMessage : TalkFrom;

	var arMessageFlow : Array<h2d.Flow>;

	var isTypingText : h2d.Text;

	var mask : h2d.Mask;

	public function new(comm:Communication, author:String) {
		super(comm);

		createRoot(@:privateAccess comm.mainWrapper);

		mask = new h2d.Mask(916, 393, root);

		this.author = author;

		waitForPlayer = false;

		cd.reset();

		arMessageFlow = [];

		isTypingText = new h2d.Text(Assets.fontSinsgold16, mask);
		isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: "XXX"});
		isTypingText.alpha = 0;
		isTypingText.textColor = 0x43b643;

		isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: author});

		onResize();
	}

	public function initNextTalk() {
		pendingMessages = [];

		lastMessage = null;

		for (det in Game.ME.currentEvent.talks) {
			if (det.answers.length > 0) {
				var texts : Array<PlayerTalkData> = [];
				for (answer in det.answers) {
					texts.push({text:answer.text, answer:answer.answer != null ? {text: answer.answer, author: answer.customAuthor, type: answer.TypeId} : null});
				}
				pendingMessages.push(Player(texts));
			}
			else if (det.customAuthor == "System") {
				pendingMessages.push(System({author:"System", text: det.text, type: det.TypeId}));
			}
			else {
				pendingMessages.push(Outside({author:det.customAuthor, text: det.text, type: det.TypeId}));
			}
		}

		lastMessage = pendingMessages[pendingMessages.length - 1];

		if (arMessageFlow.length == 0)
			forceSystemMessage(Lang.t._("::name:: est en ligne", {name:author}));

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

		var flowAnswers = new h2d.Flow(mask);
		flowAnswers.layout = Vertical;
		flowAnswers.horizontalAlign = Right;
		flowAnswers.minWidth = flowAnswers.maxWidth = Std.int(mask.width * 0.5);
		flowAnswers.verticalSpacing = 2;
		flowAnswers.padding = 5;

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("sliceboxAnswer"), 6, 6, flowAnswers);
		flowAnswers.getProperties(bg).isAbsolute = true;
		
		var arrow = Assets.tiles.h_get("answerArrow", 0, 1, 0.5, flowAnswers);
		arrow.x = -5;
		flowAnswers.getProperties(arrow).isAbsolute = true;
		
		for (a in ptds) {
			if (a != ptds[0]) {
				var separation = Assets.tiles.h_get("separationAnswer", flowAnswers);
				flowAnswers.getProperties(separation).horizontalAlign = Middle;
			}

			var flow = new h2d.Flow(flowAnswers);
			flow.paddingHorizontal = 5;
			flow.paddingVertical = 15;
			flow.horizontalAlign = Right;
			flow.minWidth = Std.int(flowAnswers.innerWidth);
			
			var text = new h2d.Text(Assets.fontSinsgold16, flow);
			text.text = Lang.t.get(a.text);
			text.textColor = 0x081c0c;

			var inter = new h2d.Interactive(1, 1, flow);
			flow.getProperties(inter).isAbsolute = true;
			inter.onOver = function (e) {
				arrow.y = flow.y + (flow.outerHeight >> 1);
			}
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

			if (a == ptds[0])
				arrow.y = flow.y + (flow.outerHeight >> 1);
		}

		flowAnswers.reflow();
		flowAnswers.setPosition(mask.width - flowAnswers.outerWidth, mask.height - flowAnswers.outerHeight);

		bg.width = flowAnswers.outerWidth;
		bg.height = flowAnswers.outerHeight;

		flowAnswers.x += flowAnswers.outerWidth;
		tw.createS(flowAnswers.alpha, 0 > 1, 0.2);
		tw.createS(flowAnswers.x, flowAnswers.x - flowAnswers.outerWidth, 0.2);
	}

	function showPlayerMessage(text:String) {
		var messageFlow = new h2d.Flow(mask);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Right;
		messageFlow.maxWidth = Std.int(mask.width * 0.45);
		arMessageFlow.push(messageFlow);

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("sliceboxTalkNormal"), 6, 6, messageFlow);
		messageFlow.getProperties(bg).isAbsolute = true;

		var bgName = new h2d.ScaleGrid(Assets.tiles.getTile("sliceboxNameNormal"), 6, 6, messageFlow);
		messageFlow.getProperties(bgName).isAbsolute = true;

		var authorText = new h2d.Text(Assets.fontRulergold16, messageFlow);
		authorText.textColor = 0x081c0c;
		authorText.text = Lang.t._("Vous");

		var messageText = new h2d.Text(Assets.fontSinsgold16, messageFlow);
		messageText.text = Lang.t.get(text);
		messageText.textColor = 0x43b643;

		messageFlow.reflow();
		messageFlow.setPosition(mask.width - messageFlow.outerWidth - mainWrapperPadding, mask.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		bg.width = messageFlow.outerWidth;
		bg.height = messageFlow.outerHeight;

		bgName.setPosition(authorText.x - 2, authorText.y);
		bgName.width = authorText.textWidth + 4;
		bgName.height = authorText.textHeight;
		
		updatePostedMessages(messageFlow.outerHeight + mainWrapperPadding + 30, text);
	}

	function showSystemMessage(td:TalkData) {
		var messageFlow = new h2d.Flow(mask);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Middle;
		messageFlow.minWidth = messageFlow.maxWidth = Std.int(mask.width - mainWrapperPadding * 2);
		arMessageFlow.push(messageFlow);

		var bg = Assets.tiles.h_get("boxSystem" + td.type.toString(), 0.5, 0.5, messageFlow);
		messageFlow.getProperties(bg).isAbsolute = true;

		var messageText = new h2d.Text(Assets.fontRulergold16, messageFlow);
		messageText.text = Lang.t.get(td.text);
		messageText.textColor = 0x081c0c;

		messageFlow.reflow();
		messageFlow.setPosition(mainWrapperPadding, mask.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		bg.setPos(messageFlow.outerWidth >> 1, messageFlow.outerHeight >> 1);

		updatePostedMessages(messageFlow.outerHeight + mainWrapperPadding + 30, td.text);
	}

	function showOutsideMessage(td:TalkData) {
		tw.createS(isTypingText.alpha, 0, 0.2);

		var messageFlow = new h2d.Flow(mask);
		messageFlow.padding = 10;
		messageFlow.verticalSpacing = 5;
		messageFlow.layout = Vertical;
		messageFlow.horizontalAlign = Left;
		messageFlow.maxWidth = Std.int(mask.width * 0.45);
		arMessageFlow.push(messageFlow);

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("sliceboxTalk" + td.type.toString()), 6, 6, messageFlow);
		messageFlow.getProperties(bg).isAbsolute = true;

		var bgName = new h2d.ScaleGrid(Assets.tiles.getTile("sliceboxName" + td.type.toString()), 6, 6, messageFlow);
		messageFlow.getProperties(bgName).isAbsolute = true;

		var authorText = new h2d.Text(Assets.fontRulergold16, messageFlow);
		authorText.textColor = 0x081c0c;
		authorText.text = td.author != null ? td.author : author;

		var messageText = new h2d.Text(Assets.fontSinsgold16, messageFlow);
		messageText.text = Lang.t.get(td.text);
		messageText.textColor = switch td.type {
			case Normal: 0x43b643;
			case Alert: 0xe65b5b;
		}

		messageFlow.reflow();
		messageFlow.setPosition(mainWrapperPadding, mask.height + 5);

		tw.createS(messageFlow.alpha, 0 > 1, 0.2);

		// D

		bg.width = messageFlow.outerWidth;
		bg.height = messageFlow.outerHeight;

		bgName.setPosition(authorText.x - 2, authorText.y);
		bgName.width = authorText.textWidth + 4;
		bgName.height = authorText.textHeight;

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
				cd.setS("newText", 0.5 + td.text.length * 0.04);
				isTypingText.text = Lang.t._("::name:: est en train d'écrire...", {name: author});
				delayer.addS(()->tw.createS(isTypingText.alpha, 1, 0.2), 0.5);
		}

		if (currentMessage == lastMessage) {
			lastMessage = null;
			delayer.addS(Game.ME.nextEvent, 1);
		}
	}

	public function forceOutsideMessage(td:TalkData):TalkFrom {
		var m = Outside(td);
		pendingMessages.unshift(m);
		return m;
	}

	public function forceSystemMessage(text:String, type:Data.TalkTypeKind = Normal) {
		pendingMessages.unshift(System({author:"System", text: text, type: type}));
	}

	override function onResize() {
		super.onResize();

		isTypingText.setPosition(mainWrapperPadding + 5, mask.height - mainWrapperPadding - isTypingText.textHeight);
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