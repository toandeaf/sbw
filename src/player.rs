use crate::{Game, GameObject, SpriteSheetAnimation};
use raylib::drawing::RaylibDrawHandle;
use raylib::prelude::{Color, KeyboardKey, RaylibDraw, RaylibMode2DExt, Rectangle, Vector2};
use raylib::RaylibHandle;

const FRAME_TIME: f32 = 0.05;
const SPEED: f32 = 1.2;

pub struct Player {
    pub position: Vector2,
    pub animation: SpriteSheetAnimation,
}

impl GameObject for Player {
    fn update(&mut self, rl: &RaylibHandle) {
        let position = &mut self.position;
        let anim = &mut self.animation;

        let mut moving = true;
        let running = rl.is_key_down(KeyboardKey::KEY_LEFT_SHIFT);

        let mut prospective_speed = SPEED;

        if running {
            prospective_speed = SPEED * 2.0
        }

        if rl.is_key_down(KeyboardKey::KEY_W) {
            anim.current_row = 0;
            position.y -= prospective_speed
        } else if rl.is_key_down(KeyboardKey::KEY_S) {
            anim.current_row = 1;
            position.y += prospective_speed
        } else if rl.is_key_down(KeyboardKey::KEY_A) {
            anim.current_row = 2;
            position.x -= prospective_speed
        } else if rl.is_key_down(KeyboardKey::KEY_D) {
            anim.current_row = 3;
            position.x += prospective_speed
        } else {
            moving = false
        }

        // game.camera.target = *position;

        if moving {
            update_sprite_index(rl, anim, running)
        } else {
            anim.current_frame = 0
        }
    }

    fn render(&mut self, rld: &mut RaylibDrawHandle) {
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

        // game.camera.target = position;

        rld.draw_texture_pro(
            &anim.texture,
            source_rec,
            dest_rec,
            origin,
            anim.rotation,
            Color::WHITE,
        );
    }
}

fn update_sprite_index(rl: &RaylibHandle, anim: &mut SpriteSheetAnimation, running: bool) {
    let delta_time = rl.get_frame_time();

    if running {
        anim.frame_time = anim.frame_time / 1.5
    } else {
        anim.frame_time = FRAME_TIME
    }

    anim.timer += delta_time;

    if anim.timer >= anim.frame_time {
        anim.timer -= anim.frame_time;
        anim.current_frame = (anim.current_frame + 1) % anim.frame_count;
    }
}
