


def convert_minutes(total_minutes: int) -> str:
    if not isinstance(total_minutes, int):
        raise TypeError(f"Expected int, got {type(total_minutes).__name__}")
    if total_minutes < 0:
        raise ValueError("Minutes cannot be negative.")

    hours = total_minutes // 60        # integer division
    remaining_minutes = total_minutes % 60   # modulo gives the remainder

    # Build a user-friendly string
    if hours == 0:
        return f"{remaining_minutes} minutes"
    elif remaining_minutes == 0:
        return f"{hours} hrs"
    else:
        return f"{hours} hrs {remaining_minutes} minutes"


# ---------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------
if __name__ == "__main__":
    test_cases = [130, 60, 45, 0, 90, 125, 200, 1, 61]

    print("=" * 40)
    print(f"{'Input (mins)':<15} {'Output'}")
    print("=" * 40)
    for mins in test_cases:
        result = convert_minutes(mins)
        print(f"{mins:<15} {result}")
    print("=" * 40)

    # Interactive mode
    print("\nEnter a number of minutes to convert (or 'quit' to exit):")
    while True:
        user_input = input("Minutes: ").strip()
        if user_input.lower() in ("quit", "q", "exit"):
            print("Goodbye!")
            break
        try:
            result = convert_minutes(int(user_input))
            print(f"  → {result}")
        except (ValueError, TypeError) as e:
            print(f"  Error: {e}")
