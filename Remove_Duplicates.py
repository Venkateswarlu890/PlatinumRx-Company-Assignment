def remove_duplicates(text: str) -> str:
    if not isinstance(text, str):
        raise TypeError(f"Expected str, got {type(text).__name__}")

    result = ""
    for char in text:
        if char not in result:   # only add if not already present
            result += char

    return result


# ---------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------
if __name__ == "__main__":
    test_cases = [
        "programming",
        "hello world",
        "aabbcc",
        "abcabc",
        "PlatinumRx",
        "112233",
        "",
        "a",
        "aaaa",
    ]

    print("=" * 50)
    print(f"{'Input':<20} {'Output (no duplicates)'}")
    print("=" * 50)
    for s in test_cases:
        result = remove_duplicates(s)
        print(f"{repr(s):<20} {repr(result)}")
    print("=" * 50)

    # Interactive mode
    print("\nEnter a string to remove duplicates (or 'quit' to exit):")
    while True:
        user_input = input("String: ")
        if user_input.lower() in ("quit", "q", "exit"):
            print("Goodbye!")
            break
        result = remove_duplicates(user_input)
        print(f"  → {repr(result)}")
