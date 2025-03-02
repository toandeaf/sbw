const rl = @import("raylib");
const constants = @import("constants.zig");

pub const Map = struct {
    texture: rl.Texture2D,
    tile_map: TileMap,
};

pub const TileMap = struct {
    tiles: [100][100]Tile,
};

pub const Tile = enum {
    Grass,
    Water,
    Sand,
    pub fn toRectangle(self: Tile) rl.Rectangle {
        const tuple = switch (self) {
            Tile.Sand => Tuple{ .x = 1.0, .y = 1.0 },
            Tile.Water => Tuple{ .x = 15.0, .y = 6.0 },
            Tile.Grass => Tuple{ .x = 18.0, .y = 6.0 },
        };

        return rl.Rectangle {
            .x = tuple.x * constants.TILE_SIZE,
            .y = tuple.y * constants.TILE_SIZE,
            .width = constants.TILE_SIZE,
            .height = constants.TILE_SIZE,
        };
    }
};

pub const Tuple = struct {
    x: f32,
    y: f32,
};
