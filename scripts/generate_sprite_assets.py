#!/usr/bin/env python3

from pathlib import Path

from PIL import Image, ImageDraw


CANVAS = 48
SCALE = 2
ROOT = Path(__file__).resolve().parents[1] / "Resources" / "Sprites" / "paguro"

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (87, 39, 43, 255)
BODY_LIGHT = (242, 242, 242, 255)
BODY_SHADE = (205, 205, 205, 255)
BODY_DEEP = (174, 174, 174, 255)
BELLY = (250, 247, 241, 255)
BELLY_SHADE = (238, 232, 225, 255)
EYE = (25, 25, 25, 255)
SPARKLE = (255, 255, 255, 255)

SHELL_VARIANTS = {
    "shell_sand": {
        "base": (193, 152, 116, 255),
        "shade": (154, 114, 86, 255),
        "accent": (221, 189, 152, 255),
        "rim": (202, 173, 145, 255),
        "opening": (112, 78, 61, 255),
    },
    "shell_sunset": {
        "base": (205, 132, 121, 255),
        "shade": (165, 93, 94, 255),
        "accent": (238, 182, 170, 255),
        "rim": (233, 210, 203, 255),
        "opening": (118, 69, 72, 255),
    },
    "shell_lagoon": {
        "base": (128, 176, 175, 255),
        "shade": (90, 140, 140, 255),
        "accent": (187, 224, 220, 255),
        "rim": (222, 242, 239, 255),
        "opening": (72, 101, 104, 255),
    },
}


def new_canvas():
    return Image.new("RGBA", (CANVAS, CANVAS), TRANSPARENT)


def save(image: Image.Image, relative_path: str) -> None:
    destination = ROOT / relative_path
    destination.parent.mkdir(parents=True, exist_ok=True)
    scaled = image.resize((CANVAS * SCALE, CANVAS * SCALE), Image.NEAREST)
    scaled.save(destination)


def draw_closed_path(draw: ImageDraw.ImageDraw, points, fill) -> None:
    draw.line(points + [points[0]], fill=fill, width=1)


def draw_shell(name: str, colors: dict) -> None:
    image = new_canvas()
    draw = ImageDraw.Draw(image)

    shell = [
        (26, 5), (31, 4), (36, 6), (40, 10), (42, 15), (42, 21), (40, 27),
        (36, 31), (31, 33), (26, 32), (22, 29), (20, 25), (19, 19), (19, 12), (21, 8),
    ]
    rim = [(22, 18), (29, 17), (32, 19), (33, 23), (31, 27), (27, 29), (22, 28), (19, 24), (19, 20)]
    opening = [(23, 19), (28, 18), (31, 20), (31, 23), (29, 26), (25, 27), (22, 25), (21, 22)]
    highlight = [(28, 7), (30, 6), (32, 7), (31, 13), (29, 15), (28, 12)]

    draw.polygon(shell, fill=colors["base"])
    draw_closed_path(draw, shell, OUTLINE)

    draw.polygon([(29, 9), (34, 11), (36, 16), (35, 21), (31, 24), (27, 23), (25, 18), (26, 13)], fill=colors["shade"])
    draw.polygon([(31, 12), (35, 14), (36, 18), (34, 22), (31, 24), (28, 21), (28, 16)], fill=colors["base"])

    draw.polygon(rim, fill=colors["rim"])
    draw_closed_path(draw, rim, OUTLINE)

    draw.polygon(opening, fill=colors["opening"])
    draw_closed_path(draw, opening, OUTLINE)

    draw.polygon(highlight, fill=colors["accent"])
    draw.line([(32, 8), (35, 10), (37, 14), (37, 19)], fill=colors["accent"], width=1)
    draw.line([(30, 12), (34, 14), (35, 18), (34, 22)], fill=colors["accent"], width=1)
    draw.line([(27, 16), (31, 18), (32, 22), (31, 26)], fill=colors["accent"], width=1)

    draw.rectangle((24, 20, 25, 24), fill=(255, 255, 255, 40))
    draw.rectangle((20, 20, 21, 23), fill=(255, 255, 255, 60))

    save(image, f"shell/{name}.png")


def claw_points(side: str, pose: str):
    left = {
        "idle": [(8, 23), (4, 25), (3, 30), (5, 34), (9, 35), (12, 32), (12, 28)],
        "walk_a": [(7, 22), (3, 24), (2, 29), (4, 33), (8, 34), (11, 31), (12, 27)],
        "walk_b": [(9, 24), (5, 26), (4, 31), (6, 35), (10, 36), (13, 33), (13, 29)],
    }
    right = {
        "idle": [(31, 25), (34, 22), (39, 23), (42, 27), (41, 31), (37, 33), (33, 31)],
        "walk_a": [(32, 26), (35, 23), (40, 24), (43, 28), (42, 32), (38, 34), (34, 32)],
        "walk_b": [(30, 24), (33, 21), (38, 22), (41, 26), (40, 30), (36, 32), (32, 30)],
    }
    return left[pose] if side == "left" else right[pose]


def leg_points(side: str, index: int, pose: str):
    left_legs = {
        "idle": [[(15, 35), (11, 39), (9, 42)], [(18, 36), (15, 41), (13, 44)], [(21, 36), (19, 41), (18, 44)]],
        "walk_a": [[(15, 35), (11, 38), (8, 40)], [(18, 36), (16, 41), (15, 44)], [(21, 36), (20, 41), (21, 44)]],
        "walk_b": [[(15, 35), (12, 40), (11, 44)], [(18, 36), (14, 39), (11, 41)], [(21, 36), (18, 40), (16, 43)]],
    }
    right_legs = {
        "idle": [[(31, 35), (35, 39), (37, 42)], [(28, 36), (31, 41), (33, 44)], [(25, 36), (27, 41), (28, 44)]],
        "walk_a": [[(31, 35), (34, 40), (35, 44)], [(28, 36), (32, 39), (35, 41)], [(25, 36), (28, 40), (30, 43)]],
        "walk_b": [[(31, 35), (35, 38), (38, 40)], [(28, 36), (30, 41), (31, 44)], [(25, 36), (26, 41), (25, 44)]],
    }
    return left_legs[pose][index] if side == "left" else right_legs[pose][index]


def draw_body_frame(pose: str) -> None:
    fill = new_canvas()
    belly = new_canvas()
    outline = new_canvas()

    fill_draw = ImageDraw.Draw(fill)
    belly_draw = ImageDraw.Draw(belly)
    outline_draw = ImageDraw.Draw(outline)

    shell_bridge = [(24, 17), (28, 16), (31, 18), (31, 21), (28, 22), (24, 21), (22, 19)]
    torso = [(12, 24), (17, 21), (24, 20), (31, 21), (35, 25), (36, 31), (34, 35), (28, 38), (21, 39), (15, 38), (11, 34), (10, 28)]
    shade = [(14, 24), (20, 22), (28, 22), (33, 25), (34, 29), (29, 31), (20, 31), (14, 29)]

    fill_draw.polygon(shell_bridge, fill=BODY_SHADE)
    outline_draw.polygon(shell_bridge, fill=OUTLINE)
    draw_closed_path(outline_draw, shell_bridge, OUTLINE)

    fill_draw.polygon(torso, fill=BODY_LIGHT)
    fill_draw.polygon(shade, fill=BODY_SHADE)
    fill_draw.rectangle((18, 24, 30, 27), fill=BODY_DEEP)
    draw_closed_path(outline_draw, torso, OUTLINE)

    left_claw = claw_points("left", pose)
    right_claw = claw_points("right", pose)
    fill_draw.polygon(left_claw, fill=BODY_LIGHT)
    fill_draw.polygon(right_claw, fill=BODY_LIGHT)
    fill_draw.polygon([left_claw[0], left_claw[1], left_claw[2], left_claw[3], left_claw[4]], fill=BODY_SHADE)
    fill_draw.polygon([right_claw[0], right_claw[1], right_claw[2], right_claw[3], right_claw[4]], fill=BODY_SHADE)
    draw_closed_path(outline_draw, left_claw, OUTLINE)
    draw_closed_path(outline_draw, right_claw, OUTLINE)

    for side in ("left", "right"):
        for index in range(3):
            points = leg_points(side, index, pose)
            fill_draw.line(points, fill=BODY_LIGHT, width=2)
            outline_draw.line(points, fill=OUTLINE, width=1)

    belly_draw.rounded_rectangle((16, 28, 30, 38), radius=5, fill=BELLY)
    belly_draw.rounded_rectangle((18, 30, 28, 37), radius=5, fill=BELLY_SHADE)
    belly_draw.ellipse((19, 30, 24, 34), fill=(255, 255, 255, 60))

    outline_draw.arc((15, 27, 31, 39), start=200, end=340, fill=OUTLINE)
    outline_draw.arc((12, 23, 18, 31), start=225, end=20, fill=OUTLINE)
    outline_draw.arc((29, 23, 36, 31), start=160, end=320, fill=OUTLINE)

    save(fill, f"body/body_fill_{pose}.png")
    save(belly, f"body/body_belly_{pose}.png")
    save(outline, f"body/body_outline_{pose}.png")


def draw_pattern_assets() -> None:
    speckles = new_canvas()
    speckle_draw = ImageDraw.Draw(speckles)
    for x, y in [(17, 27), (24, 26), (30, 28), (20, 31), (27, 33), (15, 33)]:
        speckle_draw.rectangle((x, y, x + 1, y + 1), fill=(255, 255, 255, 255))
    save(speckles, "pattern/pattern_speckles.png")

    stripes = new_canvas()
    stripe_draw = ImageDraw.Draw(stripes)
    stripe_draw.rectangle((18, 25, 19, 35), fill=(255, 255, 255, 255))
    stripe_draw.rectangle((23, 24, 24, 36), fill=(255, 255, 255, 255))
    stripe_draw.rectangle((28, 25, 29, 35), fill=(255, 255, 255, 255))
    save(stripes, "pattern/pattern_stripes.png")


def draw_face_assets() -> None:
    eyes_open = new_canvas()
    draw = ImageDraw.Draw(eyes_open)
    draw.ellipse((18, 27, 21, 31), fill=EYE)
    draw.ellipse((27, 27, 30, 31), fill=EYE)
    draw.point((19, 28), fill=SPARKLE)
    draw.point((28, 28), fill=SPARKLE)
    save(eyes_open, "face/eyes_open.png")

    eyes_blink = new_canvas()
    draw = ImageDraw.Draw(eyes_blink)
    draw.line([(18, 29), (21, 29)], fill=OUTLINE, width=1)
    draw.line([(27, 29), (30, 29)], fill=OUTLINE, width=1)
    save(eyes_blink, "face/eyes_blink.png")

    mouth_neutral = new_canvas()
    draw = ImageDraw.Draw(mouth_neutral)
    draw.line([(23, 33), (26, 33)], fill=OUTLINE, width=1)
    save(mouth_neutral, "face/mouth_neutral.png")

    mouth_smile = new_canvas()
    draw = ImageDraw.Draw(mouth_smile)
    draw.arc((22, 31, 27, 35), start=15, end=165, fill=OUTLINE)
    save(mouth_smile, "face/mouth_smile.png")

    mouth_sleepy = new_canvas()
    draw = ImageDraw.Draw(mouth_sleepy)
    draw.line([(22, 33), (27, 33)], fill=OUTLINE, width=1)
    draw.point((24, 34), fill=OUTLINE)
    save(mouth_sleepy, "face/mouth_sleepy.png")


def main() -> None:
    for name, colors in SHELL_VARIANTS.items():
        draw_shell(name, colors)

    for pose in ("idle", "walk_a", "walk_b"):
        draw_body_frame(pose)

    draw_pattern_assets()
    draw_face_assets()


if __name__ == "__main__":
    main()
