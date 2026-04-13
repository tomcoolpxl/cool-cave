# test.ps1
$lua = "C:\Program Files (x86)\Corona Labs\Corona\Native\Corona\win\bin\lua.exe"
$env:LUA_PATH="?;?.lua;./?.lua;./util/?.lua;./systems/?.lua;./test/?.lua"
& $lua -e "local test = require('test.logic_test'); test.run()"
