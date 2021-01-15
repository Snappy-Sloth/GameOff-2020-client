haxe -hl hxd.fmt.pak.Build.hl -lib heaps -main hxd.fmt.pak.Build
hl hxd.fmt.pak.Build.hl
rename res.null.pak res.pak
del /Q /S redist\js
haxelib run redisthelper -o redist\js -p AreYouThere js.hxml
move res.pak redist\js\js