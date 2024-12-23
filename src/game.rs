use crate::player::Player;
use raylib::drawing::RaylibDrawHandle;
use raylib::{init, RaylibHandle, RaylibThread};

pub const SCREEN_WIDTH: i32 = 800;
pub const SCREEN_HEIGHT: i32 = 400;

pub trait GameObject {
    fn update(&mut self, rl: &RaylibHandle);
    fn render(&mut self, rld: &mut RaylibDrawHandle);
}

pub struct Game {
    pub(crate) rl: RaylibHandle,
    pub(crate) thread: RaylibThread,
    game_objects: Vec<Box<dyn GameObject>>,
}

impl Game {
    pub fn new() -> Self {
        let mut rlb = init();

        rlb.height(SCREEN_HEIGHT)
            .width(SCREEN_WIDTH)
            .title("Sand, blood, water.");

        let (rl, thread) = rlb.build();

        Self {
            rl,
            thread,
            game_objects: vec![],
        }
    }

    pub fn init(&mut self) {
        self.rl.set_target_fps(60);
        let player = Player::init(self);
        self.game_objects.push(Box::new(player));
    }

    pub fn run(&mut self) {
        while !self.rl.window_should_close() {
            for game_object in self.game_objects.iter_mut() {
                game_object.update(&self.rl);
            }

            let mut d = self.rl.begin_drawing(&self.thread);

            for game_object in &mut self.game_objects.iter_mut() {
                game_object.render(&mut d);
            }
        }
    }
}
