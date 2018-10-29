const std = @import("std");
const math = std.math;
const assert = std.debug.assert;
const warn = std.debug.warn;

pub fn Matrix(comptime T: type, comptime m: usize, comptime n: usize) type {
    return struct.{
        const Self = @This();

        pub row_cnt: usize,
        pub col_cnt: usize,
        pub data: [m][n]T,

        /// Initialize Matrix to a value
        pub fn init() Self {
            return Self.{
                .row_cnt = m,
                .col_cnt = n,
                .data = undefined,
            };
        }

        /// Initialize Matrix to a value
        pub fn initVal(val: T) Self {
            var r = Self.init();
            return r.visit(fillFunc, val).*;
        }

        /// Initialize Matrix as a Unit matrix with 1's on the diagonal
        pub fn initUnit() Self {
            comptime if (m != n) @compileError("initUnit: not a square matrix");
            var r = Self.init();
            return r.visit(unitFunc, 0).*;
        }

        /// Return true of pSelf.data == pOther.data
        pub fn eql(pSelf: *Self, pOther: *const Self) bool {
            var eqlParam = EqlParam.{
                .pOther = pOther,
                .result = undefined,
            };
            _ = pSelf.visit(eqlFunc, &eqlParam);
            return eqlParam.result;
        }

        /// Multiply two matrixes
        pub fn mul(pSelf: *const Self, pOther: *const Self) !Self {
            if (pSelf.row_cnt != pOther.col_cnt) {
                return error.MulDoesNotResultInASqureMatrix;
            }

            var r = Matrix(T, m, m).init();
            var i: usize = 0;
            done: while (i < pSelf.row_cnt) : (i += 1) {
                //warn("mul {}:\n", i);
                var j: usize = 0;
                while (j < pOther.col_cnt) : (j += 1) {
                    //warn(" ({}:", j);
                    comptime var k: usize = 0;
                    inline while (k < m) : (k += 1) {
                        var val = pSelf.data[i][k] * pOther.data[k][j];
                        if (k == 0) {
                            r.data[i][j] = val;
                            //warn(" {}:{}={} * {}", k, val, pSelf.data[i][k], pOther.data[k][j]);
                        } else {
                            r.data[i][j] += pSelf.data[i][k] * pOther.data[k][j];
                            //warn(" {}:{}={} * {}", k, val, pSelf.data[i][k], pOther.data[k][j]);
                        }
                    }
                    //warn(" {})\n", r.data[i][j]);
                }
            }
            return r;
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
                inline while (j < n) : (j += 1) {
                    if (!func(pSelf, i, j, param)) {
                        break :done;
                    }
                    //warn(" {}", pSelf.data[i][j]);
                }
                //warn("\n");
            }
            return pSelf;
        }

        /// Print the Matrix
        pub fn print(pSelf: *const Self, s: []const u8) void {
            warn("{}", s);
            for (pSelf.data) |row, i| {
                warn("{}: []{}.{{ ", i, @typeName(T));
                for (row) |val, j| {
                    warn("{.7}{} ", val, if (j < (row.len - 1)) "," else "");
                }
                warn("}},\n");
            }
        }

        fn unitFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            pSelf.data[i][j] = if (i == j) T(1) else T(0);
            return true;
        }

        fn fillFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            pSelf.data[i][j] = param;
            return true;
        }

        const EqlParam = struct.{
            pOther: *const Self,
            result: bool,
        };

        fn eqlFunc(pSelf: *Self, i: usize, j: usize, param: var) bool {
            param.result = pSelf.data[i][j] == param.pOther.data[i][j];
            //warn("eqlFunc: {}:{} l.data:{} o.data:{} result={}\n",
            //    i, j, pSelf.data[i][j], param.pOther.data[i][j], param.result);
            return param.result; // Stop if not equal
        }
    };
}

test "matrix.init" {
    warn("\n");
    var mf32 = Matrix(f32, 4, 4).initVal(1);
    mf32.print("mf32: init(1)\n");

    for (mf32.data) |row| {
        for (row) |val| {
            assert(val == 1);
        }
    }

    var mf64 = Matrix(f64, 4, 4).initUnit();
    mf64.print("mf64: initUnit\n");
    for (mf64.data) |row, i| {
        for (row) |val, j| {
            if (i == j) {
                assert(val == 1);
            } else {
                assert(val == 0);
            }
        }
    }
}

test "matrix.eql" {
    warn("\n");
    var m0 = Matrix(f32, 4, 4).initVal(0);
    for (m0.data) |row| {
        for (row) |val| {
            assert(val == 0);
        }
    }
    var o0 = Matrix(f32, 4, 4).initVal(0);
    assert(m0.eql(&o0));

    o0.data[3][3] = 1;
    o0.print("data.eql: o0\n");
    assert(!m0.eql(&o0));

    o0.data[0][0] = 1;
    o0.print("data.eql: o0\n");
    assert(!m0.eql(&o0));
}

test "matrix.mul" {
    warn("\n");
    var m1 = Matrix(f32, 2, 2).init();
    var m2 = Matrix(f32, 2, 2).init();
    m1.data = [][2]f32.{
        []f32.{ 1, 2 },
        []f32.{ 3, 4 },
    };
    m2.data = [][2]f32.{
        []f32.{ 5, 6 },
        []f32.{ 7, 8 },
    };
    m1.print("matrix.mul m1:\n");
    m2.print("matrix.mul m2:\n");
    var m3 = try m1.mul(&m2);
    m3.print("matrix.mul m3:\n");

    var expected = Matrix(f32, 2, 2).init();
    expected.data = [][2]f32.{
        []f32.{
            (m1.data[0][0] * m2.data[0][0]) + (m1.data[0][1] * m2.data[1][0]),
            (m1.data[0][0] * m2.data[0][1]) + (m1.data[0][1] * m2.data[1][1]),
        },
        []f32.{
            (m1.data[1][0] * m2.data[0][0]) + (m1.data[1][1] * m2.data[1][0]),
            (m1.data[1][0] * m2.data[0][1]) + (m1.data[1][1] * m2.data[1][1]),
        },
    };
    expected.print("matrix.mul expected:\n");
    assert(m3.eql(&expected));
}
