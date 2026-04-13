"""Sample buggy code — use with 06_bug_fixer.py to see the agent in action."""


def calculate_average(numbers):
    """Calculate the average of a list of numbers."""
    total = 0
    for n in numbers:
        total += n
    return total / len(numbers)  # Bug: crashes on empty list


def find_user(users, user_id):
    """Find a user by ID in a list of user dicts."""
    for user in users:
        if user["id"] == user_id:
            return user
    return user  # Bug: returns last user instead of None when not found


def parse_config(config_string):
    """Parse a key=value config string into a dict."""
    result = {}
    lines = config_string.split("\n")
    for line in lines:
        key, value = line.split("=")  # Bug: crashes on empty lines or lines without '='
        result[key] = value
    return result


def safe_divide(a, b):
    """Safely divide two numbers."""
    if b == 0:
        return 0
    return a / b


class TaskQueue:
    """A simple task queue."""

    def __init__(self):
        self.tasks = []

    def add(self, task):
        self.tasks.append(task)

    def get_next(self):
        return self.tasks.pop(0)  # Bug: crashes on empty queue

    def get_all_high_priority(self):
        """Return tasks with priority > 5."""
        return [t for t in self.tasks if t["priority"] > 5]  # Bug: no key check
