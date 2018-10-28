const std = @import("std");
const assert = std.debug.assert;

pub fn Vec3(comptime T: type) type {
    return struct.{
        const Self = @This();

        pub x: T,
        pub y: T,
        pub z: T,

        pub fn init(x: T, y: T, z: T) Self {
            return Self.{ .x = x, .y = y, .z = z };
        }

        pub fn init0() Self {
            return init(0, 0, 0);
        }
    };
}

test "vec3.init" {
    const vf64 = Vec3(f64).init0();
    assert(vf64.x == 0);
    assert(vf64.y == 0);
    assert(vf64.z == 0);

    const vf32 = Vec3(f32).init0();
    assert(vf32.x == 0);
    assert(vf32.y == 0);
    assert(vf32.z == 0);

    const vi32 = Vec3(i32).init0();
    assert(vi32.x == 0);
    assert(vi32.y == 0);
    assert(vi32.z == 0);
}
