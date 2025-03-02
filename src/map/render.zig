const rl = @import("raylib");
const m = @import("state.zig");
const constants = @import("constants.zig");
const c = @import("../resources/camera.zig");

pub fn render() void {
    const tiles = m.map.tile_map.tiles;

    var x_index: f32 = 0;
    var y_index: f32 = 0;

    for (tiles) |row| {
        y_index = y_index + 1;

        for (row) |tile| {
            x_index = x_index + 1;
            const x: f32 = x_index * constants.TILE_SIZE;
            const y: f32 = y_index * constants.TILE_SIZE;

            const dest_rec = rl.Rectangle {
                .x =  x,
                .y =  y,
                .width = constants.TILE_SIZE,
                .height =  constants.TILE_SIZE,
            };

            const origin = rl.Vector2 {
                .x = dest_rec.x / 2,
                .y = dest_rec.y / 2,
            };

            const distanceToOrigin = origin.distance(c.camera.target);
            if (distanceToOrigin >= constants.RENDER_DISTANCE) {
                continue;
            }

            const source_rec = tile.toRectangle();

            rl.drawTexturePro(m.map.texture, source_rec, dest_rec, origin, 0.0, rl.Color.white);
        }
    }
}