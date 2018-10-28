const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

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

        pub fn length(pSelf: *const Self) T {
            return math.sqrt((pSelf.x * pSelf.x) + (pSelf.y * pSelf.y) + (pSelf.z * pSelf.z));
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

    const v1 = Vec3(f64).init(1, 2, 3);
    assert(v1.x == 1);
    assert(v1.y == 2);
    assert(v1.z == 3);

}

test "vec3.copy" {
    var v1 = Vec3(f32).init(1, 2, 3);
    assert(v1.x == 1);
    assert(v1.y == 2);
    assert(v1.z == 3);

    // Copy a vector
    var v2 = v1;
    assert(v2.x == 1);
    assert(v2.y == 2);
    assert(v2.z == 3);

    // Copy via a pointer
    var pV1 = &v1;
    var v3 = pV1.*;
    assert(v3.x == 1);
    assert(v3.y == 2);
    assert(v3.z == 3);
}

test "vec3.length" {
    const v1 = Vec3(f32).init(2, 3, 4);
    assert(v1.length() == math.sqrt(29.0));
}
