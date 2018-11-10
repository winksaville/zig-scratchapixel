const std = @import("std");

pub fn testExpected(expected: []const u8, actual: []const u8) !void {
    if (std.mem.eql(u8, expected, actual)) return;

    std.debug.warn("\n====== expected this output: =========\n");
    std.debug.warn("{}", expected);
    std.debug.warn("\n======== instead found this: =========\n");
    std.debug.warn("{}", actual);
    std.debug.warn("\n======================================\n");
    return error.TestFailed;
}

