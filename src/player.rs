use crate::game::{Game, GameObject, SCREEN_HEIGHT, SCREEN_WIDTH};
use crate::sprite_sheet::{update_movement_sprite_index, SpriteSheetAnimation, FRAME_TIME};
use raylib::drawing::{RaylibDrawHandle, RaylibMode2D};
use raylib::prelude::{
    Camera2D, Color, KeyboardKey, RaylibDraw, Rectangle, Vector2,
};
use raylib::RaylibHandle;

const SPEED: f32 = 1.2;
const SHEET_COLUMNS: i32 = 9;
const SHEET_ROWS: i32 = 4;

pub struct Player {
    pub camera: Camera2D,
    pub position: Vector2,
    pub animation: SpriteSheetAnimation,
}

impl Player {
    pub fn init(game: &mut Game) -> Self {
        let texture = game
            .rl
            .load_texture(&game.thread, "assets/walk.png")
            .unwrap();

        let animation = SpriteSheetAnimation {
            frame_width: texture.width / SHEET_COLUMNS,
            frame_height: texture.height / SHEET_ROWS,
            texture,
            frame_count: SHEET_COLUMNS,
            frame_time: FRAME_TIME,
            current_frame: 0,
            current_row: 1,
            timer: 0.0,
            rotation: 0.0,
        };

        let position = Vector2 {
            x: 0.,
            y: 0.,
        };

        let camera = Camera2D {
            offset: position,
            target: position,
            rotation: 0.0,
            zoom: 1.0,
        };

        Player {
            camera,
            position,
            animation,
        }
    }
}

impl GameObject for Player {
    fn update(&mut self, rl: &mut RaylibHandle) {
        let position = &mut self.position;
        let anim = &mut self.animation;

        let mut moving = true;

        let (speed, running) = match rl.is_key_down(KeyboardKey::KEY_LEFT_SHIFT) {
            true => (SPEED * 2.0, true),
            false => (SPEED, false),
        };

        if rl.is_key_down(KeyboardKey::KEY_W) {
            anim.current_row = 0;
            position.y -= speed
        } else if rl.is_key_down(KeyboardKey::KEY_S) {
            anim.current_row = 1;
            position.y += speed
        } else if rl.is_key_down(KeyboardKey::KEY_A) {
            anim.current_row = 2;
            position.x -= speed
        } else if rl.is_key_down(KeyboardKey::KEY_D) {
            anim.current_row = 3;
            position.x += speed
        } else {
            moving = false
        }

        if moving {
            update_movement_sprite_index(rl, anim, running);
        } else {
            anim.current_frame = 0
        }
    }

    fn render(&mut self, draw_handle: &mut RaylibMode2D<RaylibDrawHandle>, camera: &mut Camera2D) {
        let anim = &self.animation;
        let position = self.position;

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

        // TODO - This is a hack to clear the screen, we should have a better way to do this

        draw_handle.draw_texture_pro(
            &anim.texture,
            source_rec,
            dest_rec,
            origin,
            anim.rotation,
            Color::WHITE,
        );

        camera.offset = Vector2 {
            x: (SCREEN_WIDTH / 2) as f32,
            y: (SCREEN_HEIGHT / 2) as f32,
        };
        camera.target = position;
    }
}
