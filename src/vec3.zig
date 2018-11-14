const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();

        pub x: T,
        pub y: T,
        pub z: T,

        pub fn init(x: T, y: T, z: T) Self {
            return Self{ .x = x, .y = y, .z = z };
        }

        pub fn init0() Self {
            return init(0, 0, 0);
        }

        // What to do about TypeId.Int?
        pub fn length(pSelf: *const Self) T {
            return math.sqrt((pSelf.x * pSelf.x) +
                (pSelf.y * pSelf.y) +
                (pSelf.z * pSelf.z));
        }

        // What to do about TypeId.Int?
        pub fn dot(pSelf: *const Self, pOther: *const Self) T {
            return (pSelf.x * pOther.x) +
                (pSelf.y * pOther.y) +
                (pSelf.z * pOther.z);
        }

        // What to do about TypeId.Int?
        pub fn normalize(pSelf: *Self) void {
            var len = pSelf.length();
            if (len > 0) {
                var t = 1 / len;
                pSelf.x *= t;
                pSelf.y *= t;
                pSelf.z *= t;
            }
        }

        // What to do about TypeId.Int?
        pub fn cross(pSelf: *const Self, pOther: *const Self) Self {
            return Vec3(T).init(
                (pSelf.y * pOther.z) - (pSelf.z * pOther.y),
                (pSelf.z * pOther.x) - (pSelf.x * pOther.z),
                (pSelf.x * pOther.y) - (pSelf.y * pOther.x),
            );
        }

        // What to do about TypeId.Int?
        pub fn neg(pSelf: *const Self) Self {
            return Vec3(T).init(-pSelf.x, -pSelf.y, -pSelf.z);
        }

        // What to do about TypeId.Int?
        pub fn eql(pSelf: *const Self, pOther: *const Self) bool {
            return pSelf.x == pOther.x and
                pSelf.y == pOther.y and
                pSelf.z == pOther.z;
        }

        // What to do about TypeId.Int?
        pub fn add(pSelf: *const Self, pOther: *const Self) Self {
            return Vec3(T).init(
                (pSelf.x + pOther.x),
                (pSelf.y + pOther.y),
                (pSelf.z + pOther.z),
            );
        }

        // What to do about TypeId.Int?
        pub fn sub(pSelf: *const Self, pOther: *const Self) Self {
            return Vec3(T).init(
                (pSelf.x - pOther.x),
                (pSelf.y - pOther.y),
                (pSelf.z - pOther.z),
            );
        }

        // What to do about TypeId.Int?
        pub fn mul(pSelf: *const Self, pOther: *const Self) Self {
            return Vec3(T).init(
                (pSelf.x * pOther.x),
                (pSelf.y * pOther.y),
                (pSelf.z * pOther.z),
            );
        }

        // What to do about TypeId.Int?
        pub fn div(pSelf: *const Self, pOther: *const Self) Self {
            return Vec3(T).init(
                (pSelf.x / pOther.x),
                (pSelf.y / pOther.y),
                (pSelf.z / pOther.z),
            );
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

test "vec3.dot" {
    const v1 = Vec3(f32).init(3, 2, 1);
    const v2 = Vec3(f32).init(1, 2, 3);
    assert(v1.dot(&v2) == (3 * 1) + (2 * 2) + (3 * 1));

    // Sqrt of the dot product of itself is the length
    assert(math.sqrt(v2.dot(&v2)) == v2.length());
}

test "vec3.normalize" {
    var v1 = Vec3(f32).init0();
    v1.normalize();
    assert(v1.x == 0);
    assert(v1.y == 0);
    assert(v1.z == 0);

    v1 = Vec3(f32).init(1, 1, 1);
    v1.normalize();
    var len: f32 = math.sqrt(1.0 + 1.0 + 1.0);
    assert(v1.x == 1.0 / len);
    assert(v1.y == 1.0 / len);
    assert(v1.z == 1.0 / len);
}

test "vec3.cross.eql.neg" {
    var v1 = Vec3(f32).init(1, 0, 0); // Unit Vector X
    var v2 = Vec3(f32).init(0, 1, 0); // Unit Vector Y

    // Cross product of two unit vectors on X,Y yields unit vector Z
    var v3 = v1.cross(&v2);
    assert(v3.x == 0);
    assert(v3.y == 0);
    assert(v3.z == 1);

    v1 = Vec3(f32).init(3, 2, 1);
    v2 = Vec3(f32).init(1, 2, 3);
    v3 = v1.cross(&v2);
    assert(v3.x == 4);
    assert(v3.y == -8);
    assert(v3.z == 4);

    // Changing the order yields neg.
    var v4 = v2.cross(&v1);
    assert(v3.x == -v4.x);
    assert(v3.y == -v4.y);
    assert(v3.z == -v4.z);
    assert(v4.eql(&v3.neg()));
}

test "vec3.add" {
    const v1 = Vec3(f32).init(3, 2, 1);
    const v2 = Vec3(f32).init(1, 2, 3);
    const v3 = v1.add(&v2);
    assert(v3.x == 4);
    assert(v3.y == 4);
    assert(v3.z == 4);
}

test "vec3.sub" {
    const v1 = Vec3(f32).init(3, 2, 1);
    const v2 = Vec3(f32).init(1, 2, 3);
    const v3 = v1.sub(&v2);
    assert(v3.x == 2);
    assert(v3.y == 0);
    assert(v3.z == -2);
}

test "vec3.mul" {
    const v1 = Vec3(f32).init(3, 2, 1);
    const v2 = Vec3(f32).init(1, 2, 3);
    const v3 = v1.mul(&v2);
    assert(v3.x == 3);
    assert(v3.y == 4);
    assert(v3.z == 3);
}

test "vec3.div" {
    const v1 = Vec3(f32).init(3, 2, 1);
    const v2 = Vec3(f32).init(1, 2, 3);
    const v3 = v1.div(&v2);
    assert(v3.x == 3);
    assert(v3.y == 1);
    assert(v3.z == f32(1.0 / 3.0));
}
