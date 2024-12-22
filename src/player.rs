use crate::{GameObject, SpriteSheetAnimation};
use raylib::prelude::{KeyboardKey, Vector2};
use raylib::RaylibHandle;

const FRAME_TIME: f32 = 0.05;
const INTERVAL: f32 = 2.0;
const SPEED: f32 = 1.2;

pub fn player_update(rl: &RaylibHandle, obj: &mut GameObject) {
    evaluate_input_and_update_animation(rl, &mut obj.animation, &mut obj.position)
}

fn evaluate_input_and_update_animation(
    rl: &RaylibHandle,
    anim: &mut SpriteSheetAnimation,
    position: &mut Vector2,
) {
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

    if moving {
        update_sprite_index(rl, anim, running)
    } else {
        anim.current_frame = 0
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
