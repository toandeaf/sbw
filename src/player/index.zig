const PlayerObject = @import("../game/types.zig").GameObject;
const update = @import("update.zig").update;
const render = @import("render.zig").render;
const init = @import("state.zig").init;

pub fn Init() PlayerObject {
    // Initialize the player state
    init();

    return PlayerObject{
        .updateFn = update,
        .renderFn = render,
    };
}