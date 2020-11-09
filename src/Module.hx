class Module extends dn.Process {

	public function new() {
		super(screens.ModuleScreen.ME);

		createRoot();
		
		var bg = new h2d.Bitmap(h2d.Tile.fromColor(0x949494, Const.MODULE_WIDTH, Const.MODULE_HEIGHT), root);
	}

	function checkValidate() {}

	public function reset() {}
}