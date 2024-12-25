use crate::game::{Game, GameObject};
use raylib::drawing::{RaylibDrawHandle, RaylibMode2D};
use raylib::math::Vector2;
use raylib::prelude::{Camera2D, RaylibDraw, Rectangle, Texture2D};
use raylib::RaylibHandle;

const TILE_SIZE: f32 = 64.0;

pub struct Map {
    texture: Texture2D,
    tile_map: TileMap,
}

impl Map {
    pub(crate) fn init(game: &mut Game) -> Self {
        let texture = game
            .rl
            .load_texture(&game.thread, "assets/main.png")
            .expect("Failed to load texture");

        let tile_map = TileMap {
            tiles: (0..100).map(|_| {
                (0..100).map(|_| {
                    Tile::Grass
                }).collect()
            }).collect(),
        };

        Self {
            texture,
            tile_map,
        }
    }
}

impl GameObject for Map {
    fn update(&mut self, _: &mut RaylibHandle) {}

    fn render(&mut self, rld: &mut RaylibMode2D<RaylibDrawHandle>, camera: &mut Camera2D) {
        let tiles = &self.tile_map.tiles;
        let render_distance = TILE_SIZE * 10.0; // Adjust this value as needed

        for (y, row) in tiles.iter().enumerate() {
            for (x, tile) in row.iter().enumerate() {
                let tile_x = (x * TILE_SIZE as usize) as f32;
                let tile_y = (y * TILE_SIZE as usize) as f32;

                if (tile_x - camera.target.x).abs() < render_distance && (tile_y - camera.target.y).abs() < render_distance {
                    let source_rec = tile.to_rectangle();

                    let dest_rec = Rectangle {
                        x: tile_x - camera.target.x,
                        y: tile_y - camera.target.y,
                        width: TILE_SIZE,
                        height: TILE_SIZE,
                    };

                    let origin = Vector2 {
                        x: TILE_SIZE / 2.,
                        y: TILE_SIZE / 2.,
                    };

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
