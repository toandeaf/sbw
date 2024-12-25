use crate::map::Map;
use crate::player::Player;
use raylib::drawing::RaylibDrawHandle;
use raylib::prelude::{Camera2D, Color, RaylibDraw, RaylibMode2D, RaylibMode2DExt, Vector2};
use raylib::{init, RaylibHandle, RaylibThread};

pub const SCREEN_WIDTH: i32 = 800;
pub const SCREEN_HEIGHT: i32 = 400;

pub trait GameObject {
    fn update(&mut self, rl: &mut RaylibHandle);
    fn render(&mut self, rld: &mut RaylibMode2D<RaylibDrawHandle>, camera2d: &mut Camera2D);
}

pub struct Game {
    pub rl: RaylibHandle,
    pub thread: RaylibThread,
    pub camera2d: Camera2D,
    game_objects: Vec<Box<dyn GameObject>>,
}

impl Game {
    pub fn new() -> Self {
        let mut rlb = init();

        rlb.height(SCREEN_HEIGHT)
            .width(SCREEN_WIDTH)
            .title("Sand, blood, water.");

        let (rl, thread) = rlb.build();

        let camera2d = Camera2D {
            offset: Vector2 { x: 0.0, y: 0.0 },
            target: Vector2 { x: 0.0, y: 0.0 }.into(),
            rotation: 0.0,
            zoom: 1.0,
        };

        Self {
            rl,
            thread,
            camera2d,
            game_objects: vec![],
        }
    }

    pub fn init(&mut self) {
        self.rl.set_target_fps(60);

        let player = Player::init(self);
        let map = Map::init(self);

        self.game_objects.push(Box::new(map));
        self.game_objects.push(Box::new(player));
    }

    pub fn run(&mut self) {
        while !self.rl.window_should_close() {
            for game_object in self.game_objects.iter_mut() {
                game_object.update(&mut self.rl);
            }

            let mut draw = self.rl.begin_drawing(&self.thread);
            let mut draw_2d = draw.begin_mode2D(self.camera2d);
            draw_2d.clear_background(Color::KHAKI);

            for game_object in self.game_objects.iter_mut() {
                game_object.render(&mut draw_2d, &mut self.camera2d);
            }
        }
    }
}
