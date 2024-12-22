mod player;

use crate::player::player_update;
use raylib::color::Color;
use raylib::ffi::DrawTexturePro;
use raylib::prelude::{Camera2D, RaylibDraw, Rectangle, Vector2};
use raylib::{prelude as rl, RaylibHandle, RaylibThread};
use std::ops::Deref;

const FRAME_TIME: f32 = 0.05;
const INTERVAL: f32 = 2.0;
const SPEED: f32 = 1.2;

struct GameObject {
    position: Vector2,
    animation: SpriteSheetAnimation,
    update: fn(rl: &RaylibHandle, game_object: &mut GameObject),
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
    pub camera: Camera2D,
    game_objects: Vec<GameObject>,
}

impl Game {
    fn new() -> Self {
        let mut rlb = rl::init();
        rlb.height(400).width(800).title("Sand, blood, water.");
        let (rl, thread) = rlb.build();

        let camera: Camera2D = Camera2D {
            offset: Vector2 { x: 0.0, y: 0.0 },
            target: Vector2 { x: 0.0, y: 0.0 },
            rotation: 0.0,
            zoom: 1.0,
        };

        Self {
            rl,
            thread,
            camera,
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

        self.camera.target = position;
        self.camera.offset = position;

        self.game_objects.push(GameObject {
            position,
            animation,
            update: player_update,
        });
    }

    fn run(&mut self) {
        while !self.rl.window_should_close() {
            for mut game_object in self.game_objects.iter_mut() {
                (game_object.update)(&self.rl, game_object);
            }

            let mut d = self.rl.begin_drawing(&self.thread);

            d.clear_background(Color::BLACK);
            d.draw_text("Sand, blood, water.", 100, 200, 20, Color::GOLD);

            for game_object in &self.game_objects {
                draw_sprite_animation(&game_object);
            }
        }
    }
}


fn main() {
    let mut game = Game::new();
    game.init();
    game.run();
}

fn draw_sprite_animation(obj: &GameObject) {
    let anim = &obj.animation;
    let position = obj.position;

    let source_rec = Rectangle {
        x: (anim.current_frame * anim.frame_width) as f32,
        y: (anim.current_row * anim.frame_height) as f32,
        width: anim.frame_width as f32,
        height: anim.frame_height as f32,
    };

    let dest_rec = Rectangle {
        x: position.x,
        y: position.y,
        width: anim.frame_width as f32,
        height: anim.frame_height as f32,
    };

    let origin = Vector2 {
        x: (anim.frame_width / 2) as f32,
        y: (anim.frame_height / 2) as f32,
    };

    unsafe {
        DrawTexturePro(
            *anim.texture,
            source_rec.into(),
            dest_rec.into(),
            origin.into(),
            0.0,
            Color::WHITE.into(),
        )
    }
}
