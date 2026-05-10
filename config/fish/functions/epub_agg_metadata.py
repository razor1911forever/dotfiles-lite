#!/usr/bin/env python3

import re
import sys
import unicodedata
import zipfile
import xml.etree.ElementTree as ET


def local_name(tag: str) -> str:
    if "}" in tag:
        return tag.rsplit("}", 1)[1].lower()
    return tag.lower()


def sanitize(text: str) -> str:
    text = unicodedata.normalize("NFKC", text)
    text = re.sub(r"[\x00-\x1f<>:\"/\\\\|?*]+", " ", text)
    text = re.sub(r"\s+", " ", text).strip(" .-_")
    return text


def first_text(root: ET.Element, tag_name: str) -> str:
    for elem in root.iter():
        if local_name(elem.tag) != tag_name:
            continue
        if not elem.text:
            continue
        text = sanitize(elem.text)
        if text:
            return text
    return ""


def opf_path(epub: zipfile.ZipFile) -> str:
    container = ET.fromstring(epub.read("META-INF/container.xml"))
    for elem in container.iter():
        if local_name(elem.tag) != "rootfile":
            continue
        full_path = elem.attrib.get("full-path", "").strip()
        if full_path:
            return full_path
    raise ValueError("missing OPF path")


def metadata_name(epub_path: str) -> str:
    with zipfile.ZipFile(epub_path) as epub:
        package = ET.fromstring(epub.read(opf_path(epub)))

    title = first_text(package, "title")
    if not title:
        raise ValueError("missing title")

    creator = first_text(package, "creator")
    base = f"{creator} - {title}" if creator else title
    base = sanitize(base)
    if not base:
        raise ValueError("empty normalized name")
    return f"{base}.epub"


def main() -> int:
    if len(sys.argv) != 2:
        return 1

    try:
        print(metadata_name(sys.argv[1]))
    except Exception:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
