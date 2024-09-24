module std::arena;

import std::list;

struct ArenaCheckpoint {
    usz block_id;
    usz offset_in_block;
}

def ArenaCheckpoints = List(<ArenaCheckpoint>);
def ArenaDataBlock = List(<char>);
def ArenaDataBlocks = List(<ArenaDataBlock>);

struct Arena {
    ArenaDataBlocks blocks;
    ArenaCheckpoints checkpoints;
    usz active_block;
}
