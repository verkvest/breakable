#!/usr/bin/env python3
"""Draw the Clinkwell app icon at every iOS and Android size.

The mark is original: a teal court, three bricks, a paddle and a ball.
It does not reuse the game's brick textures.
"""

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
BG = (8, 42, 52, 255)
BG_DEEP = (4, 24, 32, 255)
BRICKS = [(224, 112, 74, 255), (242, 193, 78, 255), (125, 207, 182, 255)]
PADDLE = (244, 241, 222, 255)
BALL = (255, 252, 245, 255)
COURT = (12, 70, 82, 255)


def _rounded(draw, box, radius, fill):
    draw.rounded_rectangle(box, radius=radius, fill=fill)


def render(size: int, opaque: bool = True, foreground: bool = False, mono: bool = False) -> Image.Image:
    if foreground or mono:
        image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    else:
        image = Image.new("RGBA", (size, size), BG if opaque else (*BG[:3], 255))
    draw = ImageDraw.Draw(image)
    if not foreground and not mono:
        _rounded(draw, (0, 0, size - 1, size - 1), int(size * 0.22), BG)
        inset = int(size * 0.04)
        _rounded(draw, (inset, inset, size - 1 - inset, size - 1 - inset), int(size * 0.18), BG_DEEP)
    # Keep the mark inside the adaptive-icon safe zone (~66%).
    pad = int(size * (0.22 if foreground or mono else 0.16))
    left, top = pad, pad
    right, bottom = size - pad, size - pad
    width, height = right - left, bottom - top
    court = (left, top + int(height * 0.08), right, bottom - int(height * 0.02))
    if not mono:
        _rounded(draw, court, int(size * 0.08), COURT)
    brick_h = max(4, int(height * 0.11))
    brick_w = int(width * 0.62)
    gap = max(3, int(size * 0.025))
    brick_x = left + (width - brick_w) // 2
    brick_y = top + int(height * 0.22)
    for i, color in enumerate(BRICKS):
        y = brick_y + i * (brick_h + gap)
        fill = (255, 255, 255, 255) if mono else color
        _rounded(draw, (brick_x, y, brick_x + brick_w, y + brick_h), max(2, brick_h // 3), fill)
        if not mono:
            seam = brick_x + brick_w // 2
            draw.rectangle((seam - 1, y + 2, seam + 1, y + brick_h - 2), fill=COURT)
    paddle_w = int(width * 0.46)
    paddle_h = max(5, int(height * 0.055))
    paddle_x = left + (width - paddle_w) // 2
    paddle_y = bottom - int(height * 0.22)
    _rounded(
        draw,
        (paddle_x, paddle_y, paddle_x + paddle_w, paddle_y + paddle_h),
        paddle_h // 2,
        (255, 255, 255, 255) if mono else PADDLE,
    )
    ball_r = max(4, int(size * 0.045))
    ball_c = (left + width // 2, paddle_y - int(height * 0.12))
    draw.ellipse(
        (ball_c[0] - ball_r, ball_c[1] - ball_r, ball_c[0] + ball_r, ball_c[1] + ball_r),
        fill=(255, 255, 255, 255) if mono else BALL,
    )
    if opaque and not foreground and not mono:
        background = Image.new("RGB", (size, size), BG[:3])
        background.paste(image, mask=image.split()[-1])
        return background
    return image


IOS = {
    "icon_1024.png": 1024,
    "app_store_1024.png": 1024,
    "iphone_180.png": 180,
    "iphone_120.png": 120,
    "ipad_167.png": 167,
    "ipad_152.png": 152,
    "ios_192.png": 192,
    "ios_136.png": 136,
    "ios_128.png": 128,
    "spotlight_120.png": 120,
    "spotlight_80.png": 80,
    "settings_87.png": 87,
    "settings_58.png": 58,
    "notification_114.png": 114,
    "notification_76.png": 76,
    "notification_60.png": 60,
    "notification_40.png": 40,
}

ANDROID = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def main() -> None:
    ios_dir = ROOT / "icons" / "ios"
    ios_dir.mkdir(parents=True, exist_ok=True)
    for name, size in IOS.items():
        render(size, opaque=True).save(ios_dir / name, "PNG")
    icon = render(1024, opaque=True)
    icon.save(ROOT / "icons" / "icon.png", "PNG")
    # A 192 master used by some launchers, plus the store listing.
    render(192, opaque=True).save(ROOT / "icons" / "icon_192.png", "PNG")
    android = ROOT / "icons" / "android"
    android.mkdir(parents=True, exist_ok=True)
    render(192, opaque=True).save(android / "main_192.png", "PNG")
    render(512, opaque=True).save(android / "play_store_512.png", "PNG")
    render(432, opaque=False, foreground=True).save(android / "foreground_432.png", "PNG")
    render(432, opaque=True).save(android / "background_432.png", "PNG")
    render(432, opaque=False, mono=True).save(android / "monochrome_432.png", "PNG")
    for folder, size in ANDROID.items():
        dest = android / folder
        dest.mkdir(parents=True, exist_ok=True)
        render(size, opaque=True).save(dest / "ic_launcher.png", "PNG")
        render(size, opaque=False, foreground=True).save(dest / "ic_launcher_foreground.png", "PNG")
        render(size, opaque=True).save(dest / "ic_launcher_background.png", "PNG")
    print("icons written")


if __name__ == "__main__":
    main()
