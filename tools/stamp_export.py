#!/usr/bin/env python3
"""Stamp export_presets.cfg with the CI build number and, when present, the Android release keystore.

Reads ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS.
Never prints secret values.
"""

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRESET = ROOT / "export_presets.cfg"


def _quote(value: str) -> str:
    if any(ch in value for ch in "\n\r"):
        sys.exit("export value contains a newline")
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def _set(text: str, key: str, value: str) -> str:
    needle = key + "="
    lines = []
    found = False
    for line in text.splitlines():
        if line.startswith(needle):
            lines.append(needle + value)
            found = True
        else:
            lines.append(line)
    if not found:
        sys.exit(f"missing preset key {key}")
    return "\n".join(lines) + "\n"


def main() -> None:
    build = os.environ.get("BUILD_NUMBER", "").strip()
    if not build.isdigit():
        sys.exit("BUILD_NUMBER must be an integer")
    version_name = os.environ.get("MARKETING_VERSION", "0.1.0").strip() or "0.1.0"
    text = PRESET.read_text()
    text = _set(text, "application/version", _quote(build))
    text = _set(text, "application/short_version", _quote(version_name))
    text = _set(text, "version/code", build)
    text = _set(text, "version/name", _quote(version_name))
    keystore = os.environ.get("ANDROID_KEYSTORE_PATH", "").strip()
    password = os.environ.get("ANDROID_KEYSTORE_PASSWORD", "")
    alias = os.environ.get("ANDROID_KEY_ALIAS", "").strip()
    if keystore and password and alias:
        text = _set(text, "keystore/release", _quote(keystore))
        text = _set(text, "keystore/release_user", _quote(alias))
        text = _set(text, "keystore/release_password", _quote(password))
        print("stamp: release keystore configured")
    else:
        print("stamp: no release keystore (debug signing)")
    text = _set(text, "gradle_build/target_sdk", _quote("36"))
    PRESET.write_text(text)
    print(f"stamp: version {version_name} build {build} targetSdk 36")


if __name__ == "__main__":
    main()
