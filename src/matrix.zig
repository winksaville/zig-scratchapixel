const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn Matrix(comptime T: type, comptime m: usize, comptime n: usize) type {
    return struct.{
        const Self = @This();

        pub mat: [m][n]T,

        /// Initialize Matrix to a value
        pub fn init(val: T) Self {
            var r: Self = undefined;
            return r.visit(fillFunc, val).*;
        }

        /// Initialize Matrix as a Unit matrix with 1's on the diagonal
        pub fn initUnit() Self {
            comptime if (m != n) @compileError("initUnit: not a square matrix");
            var r: Self = undefined;
            return r.visit(unitFunc, 0).*;
        }

        /// Return true of pSelf.mat == pOther.mat
        pub fn eql(pSelf: *Self, pOther: *const Self) bool {
            var eqlParam = EqlParam.{
                .pOther = pOther,
                .result = undefined,
            };
            _ = pSelf.visit(eqlFunc, &eqlParam);
            return eqlParam.result;
        }

        /// Visit each matrix value starting at [0][0], [0][1] .. [m][n]
        /// calling func for each passing the Matrix and current i, j plus
        /// the parameter. To continue looping func returns true or false
        /// to stop looping.
        pub fn visit(
            pSelf: *Self,
            comptime func: fn (pSelf: *Self, i: usize, j: usize, param: var) bool,
            param: var,
        ) *Self {
            // Unroll the loops for speed
            comptime var i: usize = 0;
            done: inline while (i < m) : (i += 1) {
                //warn("visit {}:", i);
                comptime var j: usize = 0;
                inline while (j < m) : (j += 1) {
                    if (!func(pSelf, i, j, param)) {
                        break :done;
                    }
                    //warn(" {}", pSelf.mat[i][j]);
                }
                //warn("\n");
            }
            return pSelf;
        }

        /// Print the Matrix
        pub fn print(pSelf: *const Self, s: []const u8) void {
            warn("{}", s);
            for (pSelf.mat) |row, i| {
                warn("{}: []{}.{{ ", i, @typeName(T));
                for (row) |val, j| {
                    warn("{.7}{} ", val, if (j < (row.len - 1)) "," else "");
                }
                warn("}},\n");
            }
        }

        fn unitFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            pSelf.mat[i][j] = if (i == j) T(1) else T(0);
            return true;
        }

        fn fillFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            pSelf.mat[i][j] = param;
            return true;
        }

        const EqlParam = struct.{
            pOther: *const Self,
            result: bool,
        };

        fn eqlFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            param.result = pSelf.mat[i][j] == param.pOther.mat[i][j];
            //warn("eqlFunc: {}:{} l.mat:{} o.mat:{} result={}\n",
            //    i, j, pSelf.mat[i][j], param.pOther.mat[i][j], param.result);
            return param.result; // Stop if not equal
        }
    };
}

test "mat.init" {
    warn("\n");
    var mf32 = Matrix(f32, 4, 4).init(1);
    mf32.print("mf32: init(1)\n");

    for (mf32.mat) |row| {
        for (row) |val| {
            assert(val == 1);
        }
    }

    var mf64 = Matrix(f64, 4, 4).initUnit();
    mf64.print("mf64: initUnit\n");
    for (mf64.mat) |row, i| {
        for (row) |val, j| {
            if (i == j) {
                assert(val == 1);
            } else {
                assert(val == 0);
            }
        }
    }
}

test "mat.eql" {
    warn("\n");
    var m0 = Matrix(f32, 4, 4).init(0);
    for (m0.mat) |row| {
        for (row) |val| {
            assert(val == 0);
        }
    }
    var o0 = Matrix(f32, 4, 4).init(0);
    assert(m0.eql(&o0));

    o0.mat[3][3] = 1;
    o0.print("mat.eql: o0\n");
    assert(!m0.eql(&o0));

    o0.mat[0][0] = 1;
    o0.print("mat.eql: o0\n");
    assert(!m0.eql(&o0));
}
