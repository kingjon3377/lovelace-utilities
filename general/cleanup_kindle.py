#!/usr/bin/env python3
"""Kindle cleanup script.


   A script to remove ebooks from an e-ink Kindle that are not in a "favorites"
   list, and check whether those that are in the list are up to date."""

# TODO: Add type hints

import os
from pathlib import Path, PurePath
import tomllib
import shutil
import re
import zipfile
import tempfile
import subprocess
from subprocess import CalledProcessError
from xdg import BaseDirectory
from unidecode import unidecode
import click


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


def empty_dir(path):
    """Whether the path is a directory, is present, and is empty."""
    if path.is_dir():
        with os.scandir(path) as it:
            if not any(it):
                return True
    return False


def suffix_sibling(parent, base, suffix):
    """Return the path in the 'parent' directory with the given 'base' name
       plus the given 'suffix'."""
    retval = list(parent.glob(base + suffix))
    if retval and len(retval) == 1:
        return retval[0]
    return retval


def user_approve(prompt):
    """Ask the user whether to perform an action, and return the user's
       response (True/False)."""
    return click.confirm(prompt, False, False, "", True, True)


def strip_calibre_markup(text):
    """Remove Calibre markup and normalize whitespace for the date-searching
       process."""
    new_text = re.sub('<[^>]*>', '', text)
    new_text = re.sub('[ 	][ 	]*', ' ', new_text)
    return re.sub('^ ', '', new_text).strip()


def extract_mobi_metadata(tmpdir, base, kindle_documents_dir):
    """Extract metadata from a Kindle-format file; return a Path to the
       directory where it was extracted, or None if the process failed."""
    args = ["mobitool", "-s", "-o", tmpdir, f"{base}.azw3"]
    try:
        subprocess.run(args, check=True, cwd=kindle_documents_dir,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except CalledProcessError:
        return None
    markup_dir = list(Path(tmpdir).glob(base + "_markup"))
    if markup_dir and markup_dir[0].is_dir():
        return markup_dir[0]
    return None


class CleanupKindleArguments:
    """Configuration for the "cleanup Kindle" process. Arguments (taken from
       the environment, with the keys uppercased):

       - kindle_dir: Where the Kindle is mounted. We check that it exists and
         contains a "documents" directory, but we don't actually check that
         it is a mount point.
       - kindle_favorites: The path to the "favorites" file. It should contain
         a list of files corresponding to every file that *should* be on the
         Kindle, other than directories, "My Clippings", and the Kindle User
         Guide, minus the ".azw3" or ".sdr" extension.  Each entry in this
         file is expected to be the path to an (existent) EPUB (other formats
         not yet supported) that was (or is to be) converted to that
         Kindle-format ebook. Files where the canonical name (listed in this
         file) includes non-ASCII characters are supported; on the Kindle
         their filenames should be the lowered-to-ASCII equivalent (with
         accents dropped, etc.)
       - cleanup_kindle_date_markers: An array of "marker strings" that
         indicate a line may contain an indication of the date/time that
         the ebook was published or updated; these lines are compared
         between the EPUB and the Kindle-format ebook to see if the latter
         is up to date. The default set should cover all EPUBs produced
         by FanFicFare or downloaded from AO3.
       - cleanup_kindle_whitelist_ncx: An optional array of patterns that,
         if present in an NCX in the EPUB, indicate that an inability to find
         dates in the EPUB is not a problem worth warning about.
       - cleanup_kindle_whitelist_opf: Similarly, an optional array of
         patterns that, if present in an OPF in the EPUB, indicate that an
         inability to find dates in the EPUB is not a problem worth
         warning about.
       - cleanup_kindle_whitelist: Similarly, but finally, an optional
         array of patterns that, if matched anywhere in the EPUB,
         indicate that an inability to find dates in the EPUB is not a
         problem worth warning about.

       This class also contains methods to load config from file or the
       environment (config expected to be an array is not loaded from the
       environment), as well as helper methods using these arguments, primarily
       to test whether an EPUB matches one of the whitelists."""

    def __init__(self):
        self.kindle_dir = "/mnt/kindle"
        self.kindle_favorites = Path.home().glob("favorite_fanfics.txt")
        self.cleanup_kindle_date_markers = ["Published:", "Updated:",
                                            "Packaged:", "Completed:"]
        self.cleanup_kindle_whitelist_ncx = []
        self.cleanup_kindle_whitelist_opf = []
        self.cleanup_kindle_whitelist = []

    _CONFIG_STRING_KEYS = ["KINDLE_DIR", "KINDLE_FAVORITES"]
    _CONFIG_ARRAY_KEYS = ["CLEANUP_KINDLE_DATE_MARKERS",
                          "CLEANUP_KINDLE_WHITELIST_NCX",
                          "CLEANUP_KINDLE_WHITELIST_OPF",
                          "CLEANUP_KINDLE_WHITELIST"]

    def load_from_file(self, config_file):
        """Load config from a TOML file."""
        with open(config_file, "rb") as f:
            config = tomllib.load(f)
            for key in config:
                upper_k = key.upper()
                if (upper_k in CleanupKindleArguments._CONFIG_STRING_KEYS or
                        upper_k in CleanupKindleArguments._CONFIG_ARRAY_KEYS):
                    setattr(self, key.lower(), config[key])
                    debug_print(f"In config file, {key} is {config[key]}")

    def load_from_environ(self):
        """Load config (only keys expected to be single strings) from the
           environment."""
        for k, v in os.environ.items():
            if k in CleanupKindleArguments._CONFIG_STRING_KEYS:
                setattr(self, k.lower(), v)
                debug_print(f"In environment, {k} is {v}")

    def dates_lines_epub(self, archive):
        """Get lines containing date markers from an archive."""
        temp = []
        with zipfile.ZipFile(archive) as f:
            for subfile in f.namelist():
                if re.search('htm', subfile):
                    with f.open(subfile) as sf:
                        temp += self.dates_lines_text(sf.readlines())
        temp.sort()
        return temp

    def dates_lines_text(self, file):
        """Get lines containing date markers from a text file."""
        temp = []
        for line in file:
            try:
                line = line.decode('utf-8')
            except UnicodeDecodeError:
                # probably not a text file, skip
                continue
            except AttributeError:
                pass
            for pattern in self.cleanup_kindle_date_markers:
                if re.search(pattern, line) is not None:
                    temp.append(strip_calibre_markup(line))
        temp.sort()
        return temp

    def matches_ncx_whitelist(self, archive):
        """Whether any NCX in the archive matches any pattern in the "NCX
           whitelist"."""
        with zipfile.ZipFile(archive) as f:
            for file in f.infolist():
                if (not file.is_dir()
                        and file.filename.endswith('.ncx')):
                    with f.open(file) as ncx:
                        for line in ncx.readlines():
                            try:
                                line = line.decode('utf-8')
                            except (UnicodeDecodeError, AttributeError):
                                pass
                            for pattern in self.cleanup_kindle_whitelist_ncx:
                                if re.search(pattern, line) is not None:
                                    return True
        return False

    def matches_opf_whitelist(self, archive):
        """Whether any OPF in the archive matches any pattern in the "OPF
           whitelist"."""
        with zipfile.ZipFile(archive) as f:
            for file in f.infolist():
                if (not file.is_dir()
                        and file.filename.endswith('.opf')):
                    with f.open(file) as opf:
                        for line in opf.readlines():
                            try:
                                line = line.decode('utf-8')
                            except (UnicodeDecodeError, AttributeError):
                                pass
                            for pattern in self.cleanup_kindle_whitelist_opf:
                                if re.search(pattern, line) is not None:
                                    return True
        return False

    def matches_general_whitelist(self, archive):
        """Whether any (HTML, NCX, or OPF) file in the archive matches any pattern in the
           "general whitelist"."""
        with zipfile.ZipFile(archive) as f:
            for file in f.infolist():
                if not file.is_dir():
                    with f.open(file) as subfile:
                        for line in subfile.readlines():
                            try:
                                line = line.decode('utf-8')
                            except UnicodeDecodeError:
                                # file is not a text file, skip
                                continue
                            except AttributeError:
                                pass
                            for pattern in self.cleanup_kindle_whitelist:
                                if re.search(pattern, line) is not None:
                                    return True
        return False


class FavoritesCollection:
    """The collection of ebooks the user wants on the Kindle, represented as a
       mapping from master-file pathnames to FAT-safe equivalent basenames and
       vice versa."""
    def __init__(self, path):
        self._main_dict = {}
        self._path_dict = {}
        count = 0
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("#"):
                    continue
                line_path = PurePath(line)
                decoded = unidecode(str(line_path.name))
                decoded = re.sub('[:\\?*]', '', decoded)
                self._main_dict[decoded] = line_path
                self._path_dict[str(line_path)] = decoded
                count += 1
        debug_print(f"Number of favorites loaded: {count}")

    def __repr__(self):
        return f"main: {self._main_dict}\npath: {self._path_dict}"

    def get_kindle_name(self, path):
        """Get the filename basename on the Kindle for the given source EPUB
           path."""
        path = str(path)
        if path in self._path_dict:
            return self._path_dict[path]
        return None

    def get_source_path(self, name):
        """Get the source EPUB path for the given on-Kindle basename."""
        name = str(name)
        if name in self._main_dict:
            return self._main_dict[name]
        return None

    def get_path_iterator(self):
        """Get the mapping from source filenames to Kindle basenames to iterate
           over."""
        return self._path_dict.items()


def is_expected_file(file):
    """If a file is one we expect to see but don't want to bother
       the user about, such as a dictionary or "My Clippings",
       debug-print and return False. If the file is an unexpected
       file type, print a warning and return False. But if the
       file is an AZW or SDR, silently return True."""
    if file.name.startswith("dictionaries"):
        debug_print("a dictionary")
        return False
    if file.name.startswith("My Clippings"):
        debug_print("user clippings")
        return False
    if re.fullmatch("Kindle.User.*", file.name):
        debug_print("User Guide")
        return False
    if file.name.endswith(".azw3") or file.name.endswith(".sdr"):
        return True
    print(f"Unexpected file {file}")
    return False


def check_kindle_file(file, favorites, kindle_documents_dir, already_handled):
    """Check whether a file on the Kindle corresponds to any in the favorites
       list."""
    debug_print(f"Checking {file}")
    if not is_expected_file(file):
        return
    base = file.stem

    if favorites.get_source_path(base) is not None:
        debug_print("in favorites")
        return
    if file.name in already_handled:
        debug_print("already removed/kept")
        return
    if empty_dir(file):
        debug_print("Removing empty directory")
        file.rmdir()
        return
    azw = suffix_sibling(kindle_documents_dir, base, ".azw3")
    sdr = suffix_sibling(kindle_documents_dir, base, ".sdr")
    if azw and sdr and sdr.is_dir():
        debug_print("Removing AZW and SDR")
        suffixes = "{azw,sdr}"
        if user_approve(f"Remove {base}.{suffixes} ?"):
            azw.unlink()
            shutil.rmtree(sdr)
        already_handled.append(base + ".azw3")
        already_handled.append(base + ".sdr")
        return
    if file.is_dir():
        debug_print("Removing non-empty directory")
        if user_approve(f"Remove {file.name}/ ?"):
            shutil.rmtree(file)
        already_handled.append(file.name)
    else:
        debug_print("Removing ordinary file")
        if user_approve(f"Remove {file.name} ?"):
            file.unlink()
        already_handled.append(file.name)


def check_mobi_dates(markup_dir, config, target, orig, dates_in_epub):
    """Get dates from an unpacked Kindle file and compare with those from the
       EPUB."""
    global ANY_PRINTED
    dates_in_azw = []
    for file in markup_dir.rglob("*.*htm*"):
        with open(file) as f:
            dates_in_azw += config.dates_lines_text(f)
    dates_in_azw.sort()
    if not dates_in_azw:
        print(f"Failed to detect dates in {target}.azw3")
    elif dates_in_epub == dates_in_azw:
        debug_print(f"{target}.azw3 appears to be up to date with {orig}")
    else:
        print(f"{target}.azw3 may not be up to date from {orig}")
        debug_print(f"EPUB dates:\n{dates_in_epub}")
        debug_print(f"\nAZW dates:\n{dates_in_azw}")


def check_favorites_files(tmpdir, config, favorites, kindle_documents_dir):
    """For each file in the favorites list, check whether it and the AZW exist
       and their dates match."""
    for orig, target in favorites.get_path_iterator():
        orig = Path(orig)
        debug_print(f"line is {orig}, considering {target}")
        if not suffix_sibling(kindle_documents_dir, target, ".azw3"):
            print(f"{orig} missing from Kindle")
            # TODO: If $orig exists, use ebook-convert (or equivalent,
            # since Calibre is written in Python) to load it
            continue
        if not orig.exists():
            print(f"{orig} missing from filesystem (wrong directory?)")
            continue
        dates_in_epub = config.dates_lines_epub(orig)
        if not dates_in_epub:
            if config.matches_ncx_whitelist(orig):
                debug_print(f"{orig} matches an NCX whitelist pattern")
            elif config.matches_opf_whitelist(orig):
                debug_print(f"{orig} matches an OPF whitelist pattern")
            elif config.matches_general_whitelist(orig):
                debug_print(f"{orig} matches a general whitelist pattern")
            else:
                print(f"Failed to detect dates in {orig}")
            continue
        markup_dir = extract_mobi_metadata(tmpdir, target,
                                           kindle_documents_dir)
        if not markup_dir:
            print(f"Failed to extract metadata from {target}.azw3")
            continue
        check_mobi_dates(markup_dir, config, target, orig, dates_in_epub)
        debug_print(f"Finished with {orig}")


def main():
    """Main method."""
    config = CleanupKindleArguments()
    cfg_file = BaseDirectory.load_first_config(
        "lovelace-utilities/config.toml")
    config.load_from_file(cfg_file)
    config.load_from_environ()
    favorites = FavoritesCollection(Path(config.kindle_favorites))

    kindle_documents_dir = list(Path(config.kindle_dir).glob("documents"))
    if not kindle_documents_dir or not kindle_documents_dir[0].is_dir():
        raise FileNotFoundError(f"Kindle not mounted at {config.kindle_dir}")
    kindle_documents_dir = kindle_documents_dir[0]
    already_handled = []

    for file in list(kindle_documents_dir.iterdir()):
        check_kindle_file(file, favorites, kindle_documents_dir,
                          already_handled)

    debug_print("Finished pass through files on Kindle")
    debug_print("About to start going through favorites list")

    # TODO: Once on Python 3.12, pass "delete=(not DEBUG_PRINT.debug)" as param
    with tempfile.TemporaryDirectory() as tmpdir:
        check_favorites_files(tmpdir, config, favorites, kindle_documents_dir)


if __name__ == "__main__":
    main()
