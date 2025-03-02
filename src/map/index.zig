const MapObject = @import("../game/types.zig").GameObject;
const update = @import("update.zig").update;
const render = @import("render.zig").render;
const init = @import("state.zig").init;

pub fn Init() MapObject {
    // Initialize the player state
    init();

    return MapObject{
        .updateFn = update,
        .renderFn = render,
    };
}