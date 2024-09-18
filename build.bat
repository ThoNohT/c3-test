c:/tools/c3-windows-Release/c3c.exe compile ^
 -D PLATFORM_WEB ^
 --reloc=none ^
 --target wasm32 ^
 -O5 -g0 --link-libc=no --no-entry ^
 --use-stdlib=no ^
 -o main ^
 -z --export-table ^
 -z --allow-undefined ^
 ./src/main.c3 ./src/browser.c3 ./src/ffi.c3

c:/tools/wabt-1.0.36/bin/wasm2wat ./main.wasm > ./main.wat
