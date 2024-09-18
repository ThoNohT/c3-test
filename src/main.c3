import browser;

fn void main() @extern("main") @wasm {
    browser::log("Hello, World!");
    //browser::alert("...");
}
