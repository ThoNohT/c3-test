const decoder = new TextDecoder();
let wasm;

function make_environment(...envs) {
    return new Proxy(envs, {
        get(_target, prop, _receiver) {
            for (let env of envs) {
                if (env.hasOwnProperty(prop)) {
                    return env[prop];
                }
            }
            return (...args) => {
                throw new Error(`NOT IMPLEMENTED: ${String(prop)} ${args}`);
            };
        }
    });
}

function decodeString(index) {
    const strInfo = new Uint32Array(wasm.instance.exports.memory.buffer, index, 2);
    const strBuffer = new Uint8Array(wasm.instance.exports.memory.buffer, strInfo[0], strInfo[1]);
    return decoder.decode(strBuffer)
}

function append_text(index) {
    var elem = document.createElement("p");
    elem.innerText = decodeString(index);
    document.body.append(elem);
}

function append_num(num) {
    var elem = document.createElement("p");
    elem.innerText = num;
    document.body.append(elem);
}

(async () => {
    body = 
    wasm = await WebAssembly.instantiateStreaming(fetch("main.wasm"), {
        "env": make_environment({
            // "log": index => console.log(decodeString(index)),
            "log": index => append_text(index),
            //"log_num": num => console.log(num),
            "log_num": num => append_num(num),
            "alert": index => alert(decodeString(index)),
        })
    });
    wasm.instance.exports.main();
})();
