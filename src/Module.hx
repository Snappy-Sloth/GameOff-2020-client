class Module extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	
	public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	public function new(?wid:Int = Const.MODULE_WIDTH, ?hei:Int = Const.MODULE_HEIGHT, ?colorBG:UInt = 0x949494) {
		super(screens.ModuleScreen.ME);

		this.wid = wid;
		this.hei = hei;

		createRoot();
		
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(colorBG, wid, hei), root);
	}

	public function checkValidate() {}

	public function reset() {}
}