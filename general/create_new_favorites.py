#!/usr/bin/env python3
"""Create, or maintain, "favorites" subset(s) of a music collection.

   Creates, or maintains by asking only about files added to the main
   collection since last checked, a "favorites" directory or directories. This
   reliess on several environment variables for configuration, which can also
   be provided via config.toml in the lovelace-utilities config directory:

   - MUSIC_COLLECTION is the root directory under which the collection is
     stored.
   - MUSIC_ROOT_DIRS is an array of directories under that root to consider
     files from.
   - MUSIC_FAVORITES_DIRS is an array of "favorites"-type directories to
     maintain, also under that root. Each will have "favorite" music hardlinked
     into it in a tree mirroring the main collection.
   - PLAYER_COMMAND is the command to use to play each music file.
"""

# TODO: Extract this config-handling into a library (or find one that does what
# we want)

# TODO: Add type hints

import os
from pathlib import Path
import tomllib
import subprocess
from xdg import BaseDirectory
from blessed import Terminal


class DebugPrinter:
    """Conceptually, a simple wrapper around "print()" that only calls
       it if we are in debug mode---but implementing this in a way that
       the linter won't object to proved far more complicated."""
    def __init__(self, debug=False):
        self.debug = debug

    def __call__(self, *args):
        if self.debug:
            print(*args)

    def enable_debug(self):
        """Turn on debug mode."""
        self.debug = True

    def disable_debug(self):
        """Turn off debug mode."""
        self.debug = False


DEBUG_PRINT = DebugPrinter()


def debug_print(*args):
    """Print the provided message if in debug mode; no-op otherwise."""
    DEBUG_PRINT(*args)


term = Terminal()


def user_approve(prompt, default=None):
    """Ask the user whether to perform an action, and return the user's
       response (True/False)."""
    with term.cbreak():
        print(prompt, end='', flush=True)
        while True:
            inp = term.inkey(timeout=10)
            if not inp:
                if default is True:
                    print('(y)')
                elif default is False:
                    print('(n)')
                elif default is None:
                    print()
                else:
                    print(f'({default})')
                return default
            if inp.lower() == 'y':
                print(inp)
                return True
            if inp.lower() == 'n':
                print(inp)
                return False


class ManageFavoritesArguments:
    """Configuration for the "manage favorites" process. Arguments (taken from
       the environment, with the keys uppercased):

       - music_collection: The root directory under which the collection is
         stored.
       - music_root_dirs: an array of directories under that root to consider
         files from.
       - music_favorites_dirs: an array of "favorites"-type directories to
         maintain, also under that root. Each will have "favorite" music
         hardlinked into it in a tree mirroring the main collection.
       - player_command: The command to play the music file.

       This class also contains methods to load config from file or the
       environment (config expected to be an array is not loaded from the
       environment), as well as helper methods using these arguments."""

    def __init__(self):
        self.music_collection = Path.home().glob("music/")
        self.music_root_dirs = ["sorted"]
        self.music_favorites_dirs = ["favorites"]
        self.player_command = "/usr/bin/mplayer"

    _CONFIG_STRING_KEYS = ["MUSIC_COLLECTION", "PLAYER_COMMAND"]
    _CONFIG_ARRAY_KEYS = ["MUSIC_ROOT_DIRS", "MUSIC_FAVORITES_DIRS"]

    def load_from_file(self, config_file):
        """Load config from a TOML file."""
        with open(config_file, "rb") as f:
            config = tomllib.load(f)
            for key in config:
                upper_k = key.upper()
                str_keys = ManageFavoritesArguments._CONFIG_STRING_KEYS
                arr_keys = ManageFavoritesArguments._CONFIG_ARRAY_KEYS
                if (upper_k in str_keys or upper_k in arr_keys):
                    setattr(self, key.lower(), config[key])
                    debug_print(f"In config file, {key} is {config[key]}")

    def load_from_environ(self):
        """Load config (only keys expected to be single strings) from the
           environment."""
        for k, v in os.environ.items():
            if k in ManageFavoritesArguments._CONFIG_STRING_KEYS:
                setattr(self, k.lower(), v)
                debug_print(f"In environment, {k} is {v}")


class CheckedFileCache:
    """Caches of files that have been checked for various "favorites"
       collections, canonically stored in text files but maintained here for
       performance."""
    def __init__(self, music_collection):
        self.cache = {}
        self.music_collection = music_collection

    def in_checked_file(self, collection, file):
        """Whether the given file is in the "checked" set for the given
           collection."""
        if collection in self.cache:
            cache = self.cache[collection]
        else:
            cache = set()
            checked_file = f"{self.music_collection}/checked-{collection}.txt"
            with open(checked_file, 'r', encoding='utf-8') as f:
                for line in f:
                    cache.add(line.rstrip())
            self.cache[collection] = cache
        return str(file.resolve()) in cache

    def add_to_cache(self, collection, file):
        """Mark the given file as having been checked for the given
           collection."""
        checked_file = f"{self.music_collection}/checked-{collection}.txt"
        if collection in self.cache:
            cache = self.cache[collection]
        else:
            cache = set()
            with open(checked_file, 'r', encoding='utf-8') as f:
                for line in f:
                    cache.add(line.rstrip())
            self.cache[collection] = cache
        if not str(file.resolve()) in cache:
            with open(checked_file, 'a', encoding='utf-8') as f:
                f.write(str(file.resolve()) + "\n")


def play_file(player, file):
    """Play the give file using the given player."""
    subprocess.run([player, file], check=False)


def check_file(config, music_favorites_dirs, checked_file_cache, folder, file):
    """Check a single file: if it exists and is not in the checked-files cache
       for any of the favorites collections, play it and ask the user whether
       it should be included in each of the collections it has not been checked
       against."""
    if not file.is_file():
        return False
    music_collection = Path(config.music_collection)
    relpath = file.relative_to(folder.parent)
    missing_favorites = []
    for collection in music_favorites_dirs:
        in_collection = music_collection / collection / relpath
        if in_collection.is_file():
            return False
        if checked_file_cache.in_checked_file(collection, file):
            return False
        missing_favorites.append(collection)
    if not missing_favorites:
        return False
    play_file(config.player_command, file)
    for collection in missing_favorites:
        in_collection = music_collection / collection / relpath
        if in_collection.is_file():
            checked_file_cache.add_to_cache(collection, file)
            continue
        if user_approve(f"Is {relpath} in {collection}? ", default=False):
            parent = in_collection.parent
            parent.mkdir(parents=True, exist_ok=True)
            in_collection.hardlink_to(file)
        checked_file_cache.add_to_cache(collection, file)
    return True


def main():
    """Main method."""
    config = ManageFavoritesArguments()
    cfg_file = BaseDirectory.load_first_config(
        "lovelace-utilities/config.toml")
    config.load_from_file(cfg_file)
    config.load_from_environ()
    music_collection = Path(config.music_collection)
    if not music_collection.is_dir():
        raise FileNotFoundError("MUSIC_COLLECTION (root) is not a directory")
    music_favorites_dirs = []
    for dir_name in config.music_favorites_dirs:
        folder = music_collection / dir_name
        folder.mkdir(exist_ok=True)
        music_favorites_dirs.append(dir_name)
    checked_file_cache = CheckedFileCache(music_collection)
    for root in config.music_root_dirs:
        folder = music_collection / root
        for file in folder.rglob('*'):
            check_result = check_file(config, music_favorites_dirs,
                                      checked_file_cache, folder, file)
            if check_result and not user_approve("Keep going? ", default=True):
                break


if __name__ == "__main__":
    main()
