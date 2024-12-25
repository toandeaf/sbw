use crate::game::{Game, GameObject};
use raylib::drawing::{RaylibDrawHandle, RaylibMode2D};
use raylib::math::Vector2;
use raylib::prelude::{Camera2D, RaylibDraw, Rectangle, Texture2D};
use raylib::RaylibHandle;

const TILE_SIZE: f32 = 64.0;
const RENDER_DISTANCE: f32 = 150.0;

pub struct Map {
    texture: Texture2D,
    tile_map: TileMap,
}

struct TileMap {
    tiles: Vec<Vec<Tile>>,
}

#[derive(PartialEq, Eq, Hash)]
enum Tile {
    Grass,
    Water,
    Sand,
}

impl Map {
    pub(crate) fn init(game: &mut Game) -> Self {
        let texture = game
            .rl
            .load_texture(&game.thread, "assets/map.png")
            .expect("Failed to load texture");

        let tile_map = TileMap {
            tiles: (0..100)
                .map(|_| (0..100).map(|_| Tile::Sand).collect())
                .collect(),
        };

        Self { texture, tile_map }
    }
}

impl GameObject for Map {
    fn update(&mut self, _: &mut RaylibHandle, _: &mut Camera2D) {}

    fn render(&mut self, rld: &mut RaylibMode2D<RaylibDrawHandle>, camera: &Camera2D) {
        let tiles = &self.tile_map.tiles;

        for (y, row) in tiles.iter().enumerate() {
            for (x, tile) in row.iter().enumerate() {
                let tile_x = (x * TILE_SIZE as usize) as f32;
                let tile_y = (y * TILE_SIZE as usize) as f32;

                let dest_rec = Rectangle {
                    x: tile_x - camera.target.x,
                    y: tile_y - camera.target.y,
                    width: TILE_SIZE,
                    height: TILE_SIZE,
                };

                let origin = Vector2 {
                    x: dest_rec.x / 2.,
                    y: dest_rec.y / 2.,
                };

                let distance_to_origin = origin.distance_to(camera.target);
                if distance_to_origin >= RENDER_DISTANCE {
                    continue;
                }

                let source_rec = tile.to_rectangle();

                rld.draw_texture_pro(
                    &self.texture,
                    source_rec,
                    dest_rec,
                    origin,
                    0.0,
                    raylib::prelude::Color::WHITE,
                );
            }
        }
    }
}

impl Tile {
    fn to_rectangle(&self) -> Rectangle {
        let (x, y) = match self {
            Tile::Sand => (1., 1.),
            Tile::Water => (15., 6.),
            Tile::Grass => (18., 6.),
        };

        Rectangle {
            x: TILE_SIZE * x,
            y: TILE_SIZE * y,
            width: TILE_SIZE,
            height: TILE_SIZE,
        }
    }
}
