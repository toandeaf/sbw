pub const GameObject = struct {
    updateFn: *const fn() void,
    renderFn: *const fn() void,

    pub fn update(self: GameObject) void {
        self.updateFn();
    }
    pub fn render(self: GameObject) void {
        self.renderFn();
    }
};