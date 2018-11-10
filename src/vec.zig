const builtin = @import("builtin");
const TypeId = builtin.TypeId;

const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;
const bufPrint = std.fmt.bufPrint;

const Matrix = @import("matrix.zig").Matrix;
const ae = @import("../modules/zig-approxEql/approxeql.zig");
const tc = @import("typeconversions.zig");
const testExpected = @import("testexpected.zig").testExpected;

const DBG = false;

pub fn Vec(comptime T: type, comptime size: usize) type {
    if (@typeId(T) != TypeId.Float) @compileError("Vec only support TypeId.Floats at this time");

    switch (size) {
        2 => {
            return struct.{
                const Self = @This();

                pub m: Matrix(T, 1, size),

                pub fn init(xp: T, yp: T) Self {
                    var mtrx: Self = undefined;
                    mtrx.m.data[0][0] = xp;
                    mtrx.m.data[0][1] = yp;
                    return mtrx;
                }

                pub fn initVal(val: T) Self {
                    return Vec(T, size).init(val, val);
                }

                pub fn x(pSelf: *const Self) T {
                    return pSelf.m.data[0][0];
                }

                pub fn y(pSelf: *const Self) T {
                    return pSelf.m.data[0][1];
                }

                pub fn setX(pSelf: *Self, v: T) void {
                    pSelf.m.data[0][0] = v;
                }

                pub fn setY(pSelf: *Self, v: T) void {
                    pSelf.m.data[0][1] = v;
                }

                pub fn neg(pSelf: *const Self) Self {
                    return Vec(T, size).init(-pSelf.x(), -pSelf.y());
                }

                pub fn eql(pSelf: *const Self, pOther: *const Self) bool {
                    return pSelf.x() == pOther.x() and pSelf.y() == pOther.y();
                }

                pub fn approxEql(pSelf: *const Self, pOther: *const Self, digits: usize) bool {
                    return ae.approxEql(pSelf.x(), pOther.x(), digits) and
                        ae.approxEql(pSelf.y(), pOther.y(), digits);
                }

                pub fn add(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init((pSelf.x() + pOther.x()), (pSelf.y() + pOther.y()));
                }

                pub fn sub(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() - pOther.x()),
                        (pSelf.y() - pOther.y()),
                    );
                }

                pub fn mul(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() * pOther.x()),
                        (pSelf.y() * pOther.y()),
                    );
                }

                pub fn div(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() / pOther.x()),
                        (pSelf.y() / pOther.y()),
                    );
                }

                /// Custom format routine
                pub fn format(
                    self: *const Self,
                    comptime fmt: []const u8,
                    context: var,
                    comptime FmtError: type,
                    output: fn (@typeOf(context), []const u8) FmtError!void,
                ) FmtError!void {
                    try formatVec(T, size, self, fmt, context, FmtError, output);
                }
            };
        },
        3 => {
            return struct.{
                const Self = @This();

                pub m: Matrix(T, 1, size),

                pub fn init(xp: T, yp: T, zp: T) Self {
                    var mtrx: Self = undefined;
                    mtrx.m.data[0][0] = xp;
                    mtrx.m.data[0][1] = yp;
                    mtrx.m.data[0][2] = zp;
                    return mtrx;
                }

                pub fn initVal(val: T) Self {
                    return Vec(T, size).init(val, val, val);
                }

                pub fn x(pSelf: *const Self) T {
                    return pSelf.m.data[0][0];
                }

                pub fn y(pSelf: *const Self) T {
                    return pSelf.m.data[0][1];
                }

                pub fn z(pSelf: *const Self) T {
                    return pSelf.m.data[0][2];
                }

                pub fn setX(pSelf: *Self, v: T) void {
                    pSelf.m.data[0][0] = v;
                }

                pub fn setY(pSelf: *Self, v: T) void {
                    pSelf.m.data[0][1] = v;
                }

                pub fn setZ(pSelf: *Self, v: T) void {
                    pSelf.m.data[0][2] = v;
                }
                pub fn neg(pSelf: *const Self) Self {
                    return Vec(T, size).init(-pSelf.x(), -pSelf.y(), -pSelf.z());
                }

                pub fn eql(pSelf: *const Self, pOther: *const Self) bool {
                    return pSelf.x() == pOther.x() and
                        pSelf.y() == pOther.y() and
                        pSelf.z() == pOther.z();
                }

                pub fn approxEql(pSelf: *const Self, pOther: *const Self, digits: usize) bool {
                    return ae.approxEql(pSelf.x(), pOther.x(), digits) and
                        ae.approxEql(pSelf.y(), pOther.y(), digits) and
                        ae.approxEql(pSelf.z(), pOther.z(), digits);
                }

                pub fn add(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() + pOther.x()),
                        (pSelf.y() + pOther.y()),
                        (pSelf.z() + pOther.z()),
                    );
                }

                pub fn sub(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() - pOther.x()),
                        (pSelf.y() - pOther.y()),
                        (pSelf.z() - pOther.z()),
                    );
                }

                pub fn mul(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() * pOther.x()),
                        (pSelf.y() * pOther.y()),
                        (pSelf.z() * pOther.z()),
                    );
                }

                pub fn div(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.x() / pOther.x()),
                        (pSelf.y() / pOther.y()),
                        (pSelf.z() / pOther.z()),
                    );
                }

                /// Custom format routine
                pub fn format(
                    self: *const Self,
                    comptime fmt: []const u8,
                    context: var,
                    comptime FmtError: type,
                    output: fn (@typeOf(context), []const u8) FmtError!void,
                ) FmtError!void {
                    try formatVec(T, size, self, fmt, context, FmtError, output);
                }

                /// Returns the length as a f64, f32 or f16
                pub fn length(pSelf: *const Self) T {
                    return math.sqrt(pSelf.normal());
                }

                pub fn dot(pSelf: *const Self, pOther: *const Self) T {
                    return (pSelf.x() * pOther.x()) +
                        (pSelf.y() * pOther.y()) +
                        (pSelf.z() * pOther.z());
                }

                pub fn normal(pSelf: *const Self) T {
                    return (pSelf.x() * pSelf.x()) + (pSelf.y() * pSelf.y()) + (pSelf.z() * pSelf.z());
                }

                pub fn normalize(pSelf: *const Self) Self {
                    var len = pSelf.length();
                    var v: Self = undefined;
                    if (len > 0) {
                        v.setX(pSelf.x() / len);
                        v.setY(pSelf.y() / len);
                        v.setZ(pSelf.z() / len);
                    } else {
                        v = pSelf.*;
                    }
                    return v;
                }

                pub fn cross(pSelf: *const Self, pOther: *const Self) Self {
                    return Vec(T, size).init(
                        (pSelf.y() * pOther.z()) - (pSelf.z() * pOther.y()),
                        (pSelf.z() * pOther.x()) - (pSelf.x() * pOther.z()),
                        (pSelf.x() * pOther.y()) - (pSelf.y() * pOther.x()),
                    );
                }
            };
        },
        else => @compileError("Only Vec size 2 and 3 supported"),
    }
}

/// Custom format routine
fn formatVec(
    comptime T: type,
    comptime size: usize,
    self: *const Vec(T, size),
    comptime fmt: []const u8,
    context: var,
    comptime FmtError: type,
    output: fn (@typeOf(context), []const u8) FmtError!void,
) FmtError!void {
    for (self.m.data) |row, i| {
        try std.fmt.format(context, FmtError, output, "[]{}.{{ ", @typeName(T));
        for (row) |col, j| {
            try std.fmt.format(context, FmtError, output, "{.7}{}", col, if (j < (row.len - 1)) ", " else " ");
        }
        try std.fmt.format(context, FmtError, output, "}}");
    }
}


test "vec.init" {
    const vf64 = Vec(f64, 3).initVal(0);
    assert(vf64.x() == 0);
    assert(vf64.y() == 0);
    assert(vf64.z() == 0);

    const vf32 = Vec(f32, 3).initVal(1);
    assert(vf32.x() == 1);
    assert(vf32.y() == 1);
    assert(vf32.z() == 1);

    const v1 = Vec(f64, 3).init(1, 2, 3);
    assert(v1.x() == 1);
    assert(v1.y() == 2);
    assert(v1.z() == 3);
}

test "vec.copy" {
    var v1 = Vec(f32, 3).init(1, 2, 3);
    assert(v1.x() == 1);
    assert(v1.y() == 2);
    assert(v1.z() == 3);

    // Copy a vector
    var v2 = v1;
    assert(v2.x() == 1);
    assert(v2.y() == 2);
    assert(v2.z() == 3);

    // Copy via a pointer
    var pV1 = &v1;
    var v3 = pV1.*;
    assert(v3.x() == 1);
    assert(v3.y() == 2);
    assert(v3.z() == 3);
}

test "vec.length" {
    const v1 = Vec(f32, 3).init(2, 3, 4);
    assert(v1.length() == math.sqrt(29.0));
}

test "vec.dot" {
    const v1 = Vec(f32, 3).init(3, 2, 1);
    const v2 = Vec(f32, 3).init(1, 2, 3);
    assert(v1.dot(&v2) == (3 * 1) + (2 * 2) + (3 * 1));

    // Sqrt of the dot product of itself is the length
    assert(math.sqrt(v2.dot(&v2)) == v2.length());
}

test "vec.normal" {
    var v0 = Vec(f32, 3).initVal(0);
    assert(v0.normal() == 0);

    v0 = Vec(f32, 3).init(4, 5, 6);
    assert(v0.normal() == 4 * 4 + 5 * 5 + 6 * 6);
}

test "vec.normalize" {
    var v0 = Vec(f32, 3).initVal(0);
    var v1 = v0.normalize();
    assert(v1.x() == 0);
    assert(v1.y() == 0);
    assert(v1.z() == 0);

    v0 = Vec(f32, 3).init(1, 1, 1);
    v1 = v0.normalize();
    var len: f32 = math.sqrt(1.0 + 1.0 + 1.0);
    assert(v1.x() == 1.0 / len);
    assert(v1.y() == 1.0 / len);
    assert(v1.z() == 1.0 / len);
}

test "vec.cross.eql.neg" {
    var v1 = Vec(f32, 3).init(1, 0, 0); // Unit Vector X
    var v2 = Vec(f32, 3).init(0, 1, 0); // Unit Vector Y

    // Cross product of two unit vectors on X,Y yields unit vector Z
    var v3 = v1.cross(&v2);
    assert(v3.x() == 0);
    assert(v3.y() == 0);
    assert(v3.z() == 1);

    v1 = Vec(f32, 3).init(3, 2, 1);
    v2 = Vec(f32, 3).init(1, 2, 3);
    v3 = v1.cross(&v2);
    assert(v3.x() == 4);
    assert(v3.y() == -8);
    assert(v3.z() == 4);

    // Changing the order yields neg.
    var v4 = v2.cross(&v1);
    assert(v3.x() == -v4.x());
    assert(v3.y() == -v4.y());
    assert(v3.z() == -v4.z());
    assert(v4.eql(&v3.neg()));
}

test "vec.approxEql" {
    const v1 = Vec(f32, 3).init(1.2345678, 2.3456789, 3.4567890);
    const v2 = Vec(f32, 3).init(1.2345600, 2.3456700, 3.4567800);
    assert(v1.approxEql(&v2, 1));
    assert(v1.approxEql(&v2, 2));
    assert(v1.approxEql(&v2, 3));
    assert(v1.approxEql(&v2, 4));
    assert(v1.approxEql(&v2, 5));
    assert(v1.approxEql(&v2, 6));
    assert(!v1.approxEql(&v2, 7));
    assert(!v1.approxEql(&v2, 8));
}

test "vec.add" {
    const v1 = Vec(f32, 3).init(3, 2, 1);
    const v2 = Vec(f32, 3).init(1, 2, 3);
    const v3 = v1.add(&v2);
    assert(v3.x() == 4);
    assert(v3.y() == 4);
    assert(v3.z() == 4);
}

test "vec.sub" {
    const v1 = Vec(f32, 3).init(3, 2, 1);
    const v2 = Vec(f32, 3).init(1, 2, 3);
    const v3 = v1.sub(&v2);
    assert(v3.x() == 2);
    assert(v3.y() == 0);
    assert(v3.z() == -2);
}

test "vec.mul" {
    const v1 = Vec(f32, 3).init(3, 2, 1);
    const v2 = Vec(f32, 3).init(1, 2, 3);
    const v3 = v1.mul(&v2);
    assert(v3.x() == 3);
    assert(v3.y() == 4);
    assert(v3.z() == 3);
}

test "vec.div" {
    const v1 = Vec(f32, 3).init(3, 2, 1);
    const v2 = Vec(f32, 3).init(1, 2, 3);
    const v3 = v1.div(&v2);
    assert(v3.x() == 3);
    assert(v3.y() == 1);
    assert(v3.z() == f32(1.0 / 3.0));
}

test "vec.format" {
    var buf: [100]u8 = undefined;

    const v2 = Vec(f32, 2).init(2, 1);
    var result = try bufPrint(buf[0..], "v2={}", v2);
    if (DBG) warn("\nvec.format: {}\n", result);
    try testExpected("v2=[]f32.{ 2.0000000, 1.0000000 }", result);

    const v3 = Vec(f32, 3).init(3, 2, 1);
    result = try bufPrint(buf[0..], "v3={}", v3);
    if (DBG) warn("vec.format: {}\n", result);
    try testExpected("v3=[]f32.{ 3.0000000, 2.0000000, 1.0000000 }", result);
}
