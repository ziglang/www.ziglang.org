// zig-doctest: syntax --name fizzbuzz
export fn fizzbuzz(n: usize) ?[*:0]const u8 {
    if (n % 5 == 0) {
        if (n % 3 == 0) {
            return "fizzbuzz";
        } else {
            return "fizz";
        }
    } else if (n % 3 == 0) {
        return "buzz";
    }
    return null;
}
