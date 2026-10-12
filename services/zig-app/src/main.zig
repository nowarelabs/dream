const std = @import("std");

const body = "{\"service\":\"zig-app\"}";

pub fn main() !void {
    const port = std.posix.getenv("PORT") orelse "4026";
    const address = try std.net.Address.parseIp("0.0.0.0", try std.fmt.parseInt(u16, port, 10));
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("zig-app listening on http://127.0.0.1:{s}\n", .{port});

    while (true) {
        const conn = server.accept() catch continue;
        handle(conn) catch {};
        conn.stream.close();
    }
}

fn handle(conn: std.net.Server.Connection) !void {
    var buf: [4096]u8 = undefined;
    _ = conn.stream.read(&buf) catch 0;

    var out: [256]u8 = undefined;
    const response = try std.fmt.bufPrint(&out, "HTTP/1.1 200 OK\r\ncontent-type: application/json\r\ncontent-length: {d}\r\nconnection: close\r\n\r\n{s}", .{ body.len, body });
    try conn.stream.writeAll(response);
}
