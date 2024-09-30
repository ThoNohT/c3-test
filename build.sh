set -xe

if [ $1 = "build" ]; then
     c3c compile \
        -D PLATFORM_WEB \
        --reloc=none --target wasm32 \
        -O5 -g0 \
        --link-libc=no --no-entry --use-stdlib=no \
        -o main \
        -z --export-table -z --allow-undefined \
        ./src/main.c3 \
        ./src/std/browser.c3 ./src/std/list.c3 \
        ./src/std/allocators/allocator.c3 ./src/std/allocators/memory_allocator.c3 ./src/std/allocators/arena.c3 \
        ./src/std/core/ffi.c3 ./src/std/core/errors.c3 ./src/std/core/wasm_memory.c3

    wasm2wat ./main.wasm > ./main.wat

elif [ $1 = "run" ]; then
    python3 -m http.server 6969

else
    echo "Invalid command."

fi
