use raylib::prelude::Texture2D;
use raylib::RaylibHandle;

pub const FRAME_TIME: f32 = 0.05;

pub struct SpriteSheetAnimation {
    pub texture: Texture2D,
    pub frame_width: i32,
    pub frame_height: i32,
    pub frame_count: i32,
    pub frame_time: f32,
    pub current_frame: i32,
    pub current_row: i32,
    pub timer: f32,
    pub rotation: f32,
}

pub fn update_movement_sprite_index(rl: &RaylibHandle, anim: &mut SpriteSheetAnimation, running: bool) {
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