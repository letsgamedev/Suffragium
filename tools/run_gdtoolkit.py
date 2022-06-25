#!/usr/bin/env python3
"""This Script runs gdformat and gdlint on all files in game folder.
https://github.com/Scony/godot-gdscript-toolkit
"""
import sys
import argparse
import subprocess

from os.path import abspath, dirname, join
from typing import Union


def main() -> Union[int, str, None]:
    """Execute gdformat and gdlint and return whether there was an error."""
    parser = argparse.ArgumentParser(
        description="This Script runs gdformat and gdlint on all files in game folder",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "-d",
        "--diff",
        action="store_true",
        help="Don't write the files back, just suggest formattting changes",
    )
    parser.add_argument(
        "-s", "--skip", action="store_true", help="Skip the pause at the end on windows"
    )
    args = parser.parse_args()
    config = vars(args)

    err: Union[int, str, None]
    if sys.version_info < (3, 7):
        err = "Please upgrade your Python version to 3.7.0 or higher"
    else:
        game_path = join(dirname(dirname(abspath(__file__))), "game")

        try:
            print("--- Format ---")
            parameters = ["gdformat", game_path]
            if config.get("diff"):
                parameters.append("-d")
            err = run_command(parameters)

            print("\n--- Lint ---")
            err = err or run_command(["gdlint", game_path])
        except OSError:
            err = "ERROR: GDScript Toolkit not installed!"

    if sys.platform != "win32" or config.get("skip"):
        return err

    if err and isinstance(err, str):
        print(err)

    input("\nPress Enter to close.")
    return 1 if err else 0


def run_command(args: list[str]) -> int:
    """Run a given command with the given arguments."""
    result = subprocess.run(args, stderr=sys.stderr, stdout=sys.stdout, check=False)
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
