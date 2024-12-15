package camera
import rl "vendor:raylib"

global_camera: rl.Camera2D

camera_init :: proc(position: rl.Vector2) {
    global_camera = rl.Camera2D{
        target  = position,
        offset  = position,
        rotation= 0.0,
        zoom    = 1.0,
    }
}