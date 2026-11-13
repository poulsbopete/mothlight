#!/usr/bin/env python3
"""Generate Mothlight app icon PNGs (pure stdlib)."""
import json
import math
import os
import struct
import zlib

ROOT = os.path.join(os.path.dirname(__file__), "..", "Mothlight", "Mothlight", "Assets.xcassets", "AppIcon.appiconset")


def png_chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def write_png(path: str, width: int, height: int, rgba_rows):
    raw = b""
    for row in rgba_rows:
        raw += b"\x00"
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))
    compressed = zlib.compress(raw, 9)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n"
    png += png_chunk(b"IHDR", ihdr)
    png += png_chunk(b"IDAT", compressed)
    png += png_chunk(b"IEND", b"")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)


def render(size: int):
    cx, cy = size / 2, size / 2
    rows = []
    for y in range(size):
        row = []
        for x in range(size):
            # Night gradient background
            t = y / max(size - 1, 1)
            bg_r = int(18 + t * 22)
            bg_g = int(12 + t * 28)
            bg_b = int(48 + t * 40)
            r, g, b, a = bg_r, bg_g, bg_b, 255

            # Moon
            dx, dy = x - size * 0.78, y - size * 0.22
            if dx * dx + dy * dy < (size * 0.12) ** 2:
                r, g, b = 255, 248, 210

            # Moth body (ellipse)
            mx, my = x - cx, y - (cy + size * 0.05)
            if (mx / (size * 0.08)) ** 2 + (my / (size * 0.14)) ** 2 < 1:
                r, g, b = 230, 235, 245

            # Wings
            for side in (-1, 1):
                wx = mx - side * size * 0.06
                wy = my - abs(mx) * 0.3
                if (wx / (size * 0.22)) ** 2 + (wy / (size * 0.18)) ** 2 < 1 and wy < size * 0.05:
                    glow = 180 + int(60 * math.sin(x * 0.2))
                    r, g, b = glow, glow + 20, 90

            # Soft vignette
            dist = math.hypot(x - cx, y - cy) / (size * 0.72)
            if dist > 1:
                fade = min(1.0, (dist - 1) * 2)
                r = int(r * (1 - fade))
                g = int(g * (1 - fade))
                b = int(b * (1 - fade))

            row.append((max(0, min(255, r)), max(0, min(255, g)), max(0, min(255, b)), a))
        rows.append(row)
    return rows


def main():
    icons = [
        ("Icon-20@2x.png", 40),
        ("Icon-20@3x.png", 60),
        ("Icon-29@2x.png", 58),
        ("Icon-29@3x.png", 87),
        ("Icon-40@2x.png", 80),
        ("Icon-40@3x.png", 120),
        ("Icon-60@2x.png", 120),
        ("Icon-60@3x.png", 180),
        ("Icon-1024.png", 1024),
    ]
    for name, sz in icons:
        if sz >= 512:
            base = render(180)
            upscaled = []
            for y in range(sz):
                row = []
                by = min(179, int(y / sz * 180))
                for x in range(sz):
                    bx = min(179, int(x / sz * 180))
                    row.append(base[by][bx])
                upscaled.append(row)
            write_png(os.path.join(ROOT, name), sz, sz, upscaled)
        else:
            write_png(os.path.join(ROOT, name), sz, sz, render(sz))

    contents = {
        "images": [
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-20@2x.png", "scale": "2x"},
            {"size": "20x20", "idiom": "iphone", "filename": "Icon-20@3x.png", "scale": "3x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-29@2x.png", "scale": "2x"},
            {"size": "29x29", "idiom": "iphone", "filename": "Icon-29@3x.png", "scale": "3x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-40@2x.png", "scale": "2x"},
            {"size": "40x40", "idiom": "iphone", "filename": "Icon-40@3x.png", "scale": "3x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-60@2x.png", "scale": "2x"},
            {"size": "60x60", "idiom": "iphone", "filename": "Icon-60@3x.png", "scale": "3x"},
            {"size": "1024x1024", "idiom": "ios-marketing", "filename": "Icon-1024.png", "scale": "1x"},
        ],
        "info": {"version": 1, "author": "xcode"},
    }
    os.makedirs(ROOT, exist_ok=True)
    with open(os.path.join(ROOT, "Contents.json"), "w", encoding="utf-8") as f:
        json.dump(contents, f, indent=2)
    print("Generated icons in", ROOT)


if __name__ == "__main__":
    main()
