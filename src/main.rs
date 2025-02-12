mod player;
mod game;
mod sprite_sheet;
mod map;

use crate::game::Game;

fn main() {
    let mut game = Game::new();
    game.init();
    game.run();
}

