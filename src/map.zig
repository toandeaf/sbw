const rl = @import("raylib");
const std = @import("std");
const c = @import("camera.zig");

const TILE_SIZE: f32 = 64.0;
const RENDER_DISTANCE: f32 = 150.0;

const Tuple = struct {
    x: f32,
    y: f32,
};

const Tile = enum {
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
            .x = tuple.x * TILE_SIZE,
            .y = tuple.y * TILE_SIZE,
            .width = TILE_SIZE,
            .height = TILE_SIZE,
        };
    }
};

const TileMap = struct {
    tiles: [100][100]Tile,
};

pub const Map = struct {
    texture: rl.Texture2D,
    tile_map: TileMap,
    pub fn init() Map {
        const texture = rl.loadTexture("assets/map.png");

        var outter = [_][100]Tile { undefined } ** 100;

        for (0..100) |outter_index| {
            for (0..100) |inner_index| {
                outter[outter_index][inner_index] = Tile.Sand;
            }
        }

        const tileMap = TileMap {
            .tiles = outter,
        };

        return Map {
            .texture = texture,
            .tile_map = tileMap,
        };
    }
    pub fn render(self: Map) void {
        const tiles = self.tile_map.tiles;

        var x_index: f32 = 0;
        var y_index: f32 = 0;

        for (tiles) |row| {
            y_index = y_index + 1;

            for (row) |tile| {
                x_index = x_index + 1;
                const x: f32 = x_index * TILE_SIZE;
                const y: f32 = y_index * TILE_SIZE;

                const dest_rec = rl.Rectangle {
                    .x =  x,
                    .y =  y,
                    .width = TILE_SIZE,
                    .height =  TILE_SIZE,
                };

                const origin = rl.Vector2 {
                    .x = dest_rec.x / 2,
                    .y = dest_rec.y / 2,
                };

                const distanceToOrigin = origin.distance(c.camera.target);
                if (distanceToOrigin >= RENDER_DISTANCE) {
                    continue;
                }

                const source_rec = tile.toRectangle();

                rl.drawTexturePro(self.texture, source_rec, dest_rec, origin, 0.0, rl.Color.white);
            }
        }

    }
    pub fn update(self: *Map) void {
        // Do nothing
        _ = self;
    }
};


