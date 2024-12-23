use crate::game::{Game, GameObject, SCREEN_HEIGHT, SCREEN_WIDTH};
use crate::sprite_sheet::{update_movement_sprite_index, SpriteSheetAnimation, FRAME_TIME};
use raylib::drawing::RaylibDrawHandle;
use raylib::prelude::{
    Camera2D, Color, KeyboardKey, RaylibDraw, RaylibMode2DExt, Rectangle, Vector2,
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

impl GameObject for Player {
    fn update(&mut self, rl: &RaylibHandle) {
        let position = &mut self.position;
        let anim = &mut self.animation;
        let camera = &mut self.camera;

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

        camera.target = self.position;
    }

    fn render(&mut self, draw_handle: &mut RaylibDrawHandle) {
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

        let mut draw_handle_2d = draw_handle.begin_mode2D(self.camera);
        // TODO - This is a hack to clear the screen, we should have a better way to do this
        draw_handle_2d.clear_background(Color::KHAKI);
        draw_handle_2d.draw_text("Sand, blood, water.", 100, 200, 20, Color::BLUE);

        draw_handle_2d.draw_texture_pro(
            &anim.texture,
            source_rec,
            dest_rec,
            origin,
            anim.rotation,
            Color::WHITE,
        );
    }
}

impl Player {
    pub fn init(game: &mut Game) -> Self {
        let half_width: f32 = SCREEN_WIDTH as f32 / 2.0;
        let half_height: f32 = SCREEN_HEIGHT as f32 / 2.0;

        let texture =
            game.rl
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
            x: half_width,
            y: half_height,
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


