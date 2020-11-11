class Module extends dn.Process {
	
	public var wid(default, null) : Int;
	public var hei(default, null) : Int;

	public function new(?wid:Int = Const.MODULE_WIDTH, ?hei:Int = Const.MODULE_HEIGHT) {
		super(screens.ModuleScreen.ME);

		this.wid = wid;
		this.hei = hei;

		createRoot();
		
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x949494, wid, hei), root);
	}

	function checkValidate() {}

	public function reset() {}
}