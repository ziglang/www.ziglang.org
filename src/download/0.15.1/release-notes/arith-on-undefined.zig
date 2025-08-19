const a: u32 = 0;
const b: u32 = undefined;

test "arithmetic on undefined" {
    // This addition now triggers a compile error
    _ = a + b;
    // The solution is to simply avoid this operation!
}

// test_error=use of undefined value here causes illegal behavior
