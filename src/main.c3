import std::browser;
import std::allocators::memory_allocator;
import std::list;

def IntList = List(<usz>);

fn void main() @extern("main") @wasm {

    IntList l1;

    // browser::log_num(l1.count);

    // browser::log("Append");
    l1.append(6);

    // browser::log_num(l1.count);
    // browser::log_num((usz)&l1[0]);
    // browser::log_num(l1[0]);

    // browser::log("Append");
    // l1.append(7);

    // browser::log_num(l1.count);
    // browser::log_num((usz)&l1[1]);
    // browser::log_num(l1[1]);

    // browser::log("Append");
    // l1.append(8);

    // browser::log_num(l1.count);
    // browser::log_num((usz)&l1[2]);
    // browser::log_num(l1[2]);

    // browser::log("Append");
    // l1.append(9);

    // browser::log_num(l1.count);
    // browser::log_num((usz)&l1[3]);
    // browser::log_num(l1[3]);

    IntList l2;

    // browser::log_num(l2.count);

    // browser::log("Append");
    l2.append(6 + 10);

    // browser::log_num(l2.count);
    // browser::log_num((usz)&l2[0]);
    // browser::log_num(l2[0]);

    // browser::log("Append");
    // l2.append(7 + 10);

    // browser::log_num(l2.count);
    // browser::log_num((usz)&l2[1]);
    // browser::log_num(l2[1]);

    // browser::log("Append");
    // l2.append(8 + 10);

    // browser::log_num(l2.count);
    // browser::log_num((usz)&l2[2]);
    // browser::log_num(l2[2]);

    // browser::log("Append");
    // l2.append(9 + 10);

    // browser::log_num(l2.count);
    // browser::log_num((usz)&l2[3]);
    // browser::log_num(l2[3]);

    // browser::log("Check");
    // browser::log_num(l1[3]);
    // browser::log_num(l2[3]);

    // browser::log_num((usz)&l1[3]);
    // browser::log_num((usz)&l2[3]);

    return;
}
