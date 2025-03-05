test "labeled switch" {
    foo: switch (@as(u8, 1)) {
        1 => continue :foo 2,
        2 => continue :foo 3,
        3 => return,
        4 => {},
        else => unreachable,
    }
    return error.Unexpected;
}

test "emulate labeled switch" {
    var op: u8 = 1;
    while (true) {
        switch (op) {
            1 => {
                op = 2;
                continue;
            },
            2 => {
                op = 3;
                continue;
            },
            3 => return,
            4 => {},
            else => unreachable,
        }
        break;
    }
    return error.Unexpected;
}

// test
