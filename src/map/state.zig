const rl = @import("raylib");
const m = @import("types.zig");

pub var map: m.Map = undefined;

pub fn init() anyerror!void {
    const texture = try rl.loadTexture("assets/map.png");

    var outter = [_][100]m.Tile { undefined } ** 100;

    for (0..100) |outter_index| {
        for (0..100) |inner_index| {
            outter[outter_index][inner_index] = m.Tile.Sand;
        }
    }

    const tileMap = m.TileMap {
        .tiles = outter,
    };

    map = m.Map {
        .texture = texture,
        .tile_map = tileMap,
    };
}