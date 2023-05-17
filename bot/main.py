import time


def format_world(message: str) -> str:
    return message + "cheese"


while True:
    print(format_world("Hello world!!"))
    time.sleep(2)
