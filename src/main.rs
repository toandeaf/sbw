mod player;

use crate::player::Player;
use raylib::drawing::RaylibDrawHandle;
use raylib::prelude::{Color, RaylibDraw, Vector2};
use raylib::{prelude as rl, RaylibHandle, RaylibThread};

const FRAME_TIME: f32 = 0.05;

trait GameObject {
    fn update(&mut self, rl: &RaylibHandle);
    fn render(&mut self, rld: &mut RaylibDrawHandle);
}

struct SpriteSheetAnimation {
    texture: rl::Texture2D,
    frame_width: i32,
    frame_height: i32,
    frame_count: i32,
    frame_time: f32,
    current_frame: i32,
    current_row: i32,
    timer: f32,
    rotation: f32,
}

struct Game {
    rl: RaylibHandle,
    thread: RaylibThread,
    game_objects: Vec<Box<dyn GameObject>>,
}

impl Game {
    fn new() -> Self {
        let mut rlb = rl::init();
        rlb.height(400).width(800).title("Sand, blood, water.");
        let (rl, thread) = rlb.build();

        Self {
            rl,
            thread,
            game_objects: vec![],
        }
    }

    fn init(&mut self) {
        let screen_width: i32 = 800;
        let screen_height: i32 = 400;

        let half_width: f32 = screen_width as f32 / 2.0;
        let half_height: f32 = screen_height as f32 / 2.0;

        self.rl.set_target_fps(60);

        let sure = self
            .rl
            .load_texture(&self.thread, "assets/walk.png")
            .unwrap();

        let animation: SpriteSheetAnimation = SpriteSheetAnimation {
            frame_width: sure.width / 9,
            frame_height: sure.height / 4,
            texture: sure,
            frame_count: 9,
            frame_time: FRAME_TIME,
            current_frame: 0,
            current_row: 1,
            timer: 0.0,
            rotation: 0.0,
        };

        let position = Vector2 {
            x: half_width,
            y: half_height,
        };

        let player = Player {
            position,
            animation,
        };

        self.game_objects.push(Box::new(player));
    }

    fn run(&mut self) {
        while !self.rl.window_should_close() {
            for game_object in self.game_objects.iter_mut() {
                game_object.update(&self.rl);
            }

            let mut d = self.rl.begin_drawing(&self.thread);
            d.clear_background(Color::BLACK);
            d.draw_text("Sand, blood, water.", 100, 200, 20, Color::GOLD);

            for game_object in &mut self.game_objects.iter_mut() {
                game_object.render(&mut d);
            }
        }
    }
}

fn main() {
    let mut game = Game::new();
    game.init();
    game.run();
}
