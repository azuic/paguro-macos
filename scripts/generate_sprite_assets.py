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


def claw_shapes(side: str, pose: str):
    left = {
        "idle": {
            "arm": [(13, 27), (10, 27), (8, 30), (9, 34), (12, 35), (15, 33), (16, 30)],
            "claw": [(7, 25), (3, 27), (2, 32), (5, 36), (10, 37), (13, 34), (12, 29)],
            "pinch": [(7, 25), (4, 21), (4, 18), (7, 17), (10, 20), (10, 24)],
        },
        "walk_a": {
            "arm": [(13, 26), (10, 26), (8, 29), (9, 33), (12, 34), (15, 32), (16, 29)],
            "claw": [(6, 24), (2, 26), (1, 31), (4, 35), (9, 36), (12, 33), (11, 28)],
            "pinch": [(6, 24), (3, 20), (3, 17), (6, 16), (9, 19), (9, 23)],
        },
        "walk_b": {
            "arm": [(14, 28), (11, 28), (9, 31), (10, 35), (13, 36), (16, 34), (17, 31)],
            "claw": [(8, 26), (4, 28), (3, 33), (6, 37), (11, 38), (14, 35), (13, 30)],
            "pinch": [(8, 26), (5, 22), (5, 19), (8, 18), (11, 21), (11, 25)],
        },
    }
    right = {
        "idle": {
            "arm": [(24, 29), (26, 27), (28, 27), (29, 30), (28, 33), (25, 33)],
            "claw": [(28, 27), (31, 26), (34, 27), (36, 30), (35, 33), (32, 34), (29, 32)],
            "pinch": [(31, 26), (34, 23), (35, 20), (34, 17), (31, 17), (29, 20), (29, 24)],
        },
        "walk_a": {
            "arm": [(25, 28), (27, 26), (29, 26), (30, 29), (29, 32), (26, 32)],
            "claw": [(29, 26), (32, 25), (35, 26), (37, 29), (36, 32), (33, 33), (30, 31)],
            "pinch": [(32, 25), (35, 22), (36, 19), (35, 16), (32, 16), (30, 19), (30, 23)],
        },
        "walk_b": {
            "arm": [(23, 30), (25, 28), (27, 28), (28, 31), (27, 34), (24, 34)],
            "claw": [(27, 28), (30, 27), (33, 28), (35, 31), (34, 34), (31, 35), (28, 33)],
            "pinch": [(30, 27), (33, 24), (34, 21), (33, 18), (30, 18), (28, 21), (28, 25)],
        },
    }
    return left[pose] if side == "left" else right[pose]


def leg_points(pose: str):
    return {
        "idle": [
            [(17, 34), (14, 39), (13, 43)],
            [(21, 35), (20, 41), (20, 44)],
            [(25, 35), (26, 40), (28, 43)],
            [(28, 34), (31, 39), (33, 42)],
        ],
        "walk_a": [
            [(17, 34), (14, 38), (11, 40)],
            [(21, 35), (20, 40), (21, 44)],
            [(25, 35), (27, 39), (30, 41)],
            [(28, 34), (31, 40), (32, 44)],
        ],
        "walk_b": [
            [(17, 35), (15, 40), (15, 44)],
            [(21, 35), (18, 39), (16, 42)],
            [(25, 35), (27, 39), (28, 42)],
            [(28, 35), (31, 38), (34, 40)],
        ],
    }[pose]


def head_shapes(pose: str):
    head = {
        "idle": [(12, 20), (16, 18), (20, 18), (23, 20), (24, 24), (22, 27), (17, 28), (13, 26), (11, 23)],
        "walk_a": [(12, 19), (16, 17), (20, 17), (23, 19), (24, 23), (22, 26), (17, 27), (13, 25), (11, 22)],
        "walk_b": [(13, 21), (17, 19), (21, 19), (24, 21), (25, 25), (23, 28), (18, 29), (14, 27), (12, 24)],
    }
    muzzle = {
        "idle": [(14, 23), (17, 22), (20, 22), (22, 24), (21, 26), (17, 27), (14, 26)],
        "walk_a": [(14, 22), (17, 21), (20, 21), (22, 23), (21, 25), (17, 26), (14, 25)],
        "walk_b": [(15, 24), (18, 23), (21, 23), (23, 25), (22, 27), (18, 28), (15, 27)],
    }
    antennae = {
        "idle": [[(15, 19), (12, 15), (9, 11), (7, 7)], [(17, 19), (17, 14), (16, 10), (15, 6)]],
        "walk_a": [[(15, 18), (12, 14), (9, 10), (7, 6)], [(17, 18), (17, 13), (16, 9), (15, 5)]],
        "walk_b": [[(16, 20), (13, 16), (10, 12), (8, 8)], [(18, 20), (18, 15), (17, 11), (16, 7)]],
    }
    return head[pose], muzzle[pose], antennae[pose]


def draw_body_frame(pose: str) -> None:
    body = new_canvas()
    claws = new_canvas()
    head = new_canvas()

    body_draw = ImageDraw.Draw(body)
    claw_draw = ImageDraw.Draw(claws)
    head_draw = ImageDraw.Draw(head)

    shell_bridge = [(20, 19), (24, 18), (28, 19), (29, 22), (27, 25), (22, 25), (19, 23)]
    torso = [(16, 26), (19, 24), (23, 23), (26, 24), (28, 27), (28, 31), (26, 35), (22, 36), (18, 35), (15, 32), (14, 29)]
    abdomen = [(18, 29), (21, 28), (25, 29), (26, 32), (24, 35), (21, 35), (18, 34), (16, 31)]

    body_draw.polygon(shell_bridge, fill=BODY_SHADE)
    draw_closed_path(body_draw, shell_bridge, OUTLINE)
    body_draw.polygon(torso, fill=BODY_LIGHT)
    body_draw.polygon(abdomen, fill=BODY_SHADE)
    draw_closed_path(body_draw, torso, OUTLINE)
    body_draw.arc((17, 27, 26, 35), start=195, end=340, fill=OUTLINE)
    body_draw.line([(18, 28), (24, 28)], fill=BODY_DEEP, width=1)
    body_draw.line([(18, 31), (24, 31)], fill=BODY_DEEP, width=1)
    body_draw.rounded_rectangle((18, 30, 24, 35), radius=2, fill=BELLY)
    body_draw.rounded_rectangle((19, 31, 23, 35), radius=2, fill=BELLY_SHADE)

    for points in leg_points(pose):
        body_draw.line(points, fill=BODY_LIGHT, width=2)
        body_draw.line(points, fill=OUTLINE, width=1)

    for side in ("left", "right"):
        shapes = claw_shapes(side, pose)
        claw_draw.polygon(shapes["arm"], fill=BODY_LIGHT)
        claw_draw.polygon(shapes["claw"], fill=BODY_LIGHT)
        claw_draw.polygon(shapes["pinch"], fill=BODY_SHADE)
        draw_closed_path(claw_draw, shapes["arm"], OUTLINE)
        draw_closed_path(claw_draw, shapes["claw"], OUTLINE)
        draw_closed_path(claw_draw, shapes["pinch"], OUTLINE)
        claw_draw.line([shapes["claw"][1], shapes["claw"][4]], fill=BODY_DEEP, width=1)

    head_shape, muzzle, antennae = head_shapes(pose)
    head_draw.polygon(head_shape, fill=BODY_LIGHT)
    head_draw.polygon(muzzle, fill=BODY_SHADE)
    draw_closed_path(head_draw, head_shape, OUTLINE)
    head_draw.arc((14, 22, 22, 28), start=15, end=165, fill=BODY_DEEP)
    for antenna in antennae:
        head_draw.line(antenna, fill=OUTLINE, width=1)

    save(body, f"body/body_{pose}.png")
    save(claws, f"claws/claws_{pose}.png")
    save(head, f"head/head_{pose}.png")


def draw_pattern_assets() -> None:
    speckles = new_canvas()
    speckle_draw = ImageDraw.Draw(speckles)
    for x, y in [(12, 28), (18, 27), (23, 26), (28, 28), (16, 32), (24, 33), (31, 30)]:
        speckle_draw.rectangle((x, y, x + 1, y + 1), fill=(255, 255, 255, 255))
    save(speckles, "pattern/pattern_speckles.png")

    stripes = new_canvas()
    stripe_draw = ImageDraw.Draw(stripes)
    stripe_draw.rectangle((14, 27, 15, 35), fill=(255, 255, 255, 255))
    stripe_draw.rectangle((20, 24, 21, 36), fill=(255, 255, 255, 255))
    stripe_draw.rectangle((26, 25, 27, 36), fill=(255, 255, 255, 255))
    save(stripes, "pattern/pattern_stripes.png")


def draw_face_assets() -> None:
    eyes_open = new_canvas()
    draw = ImageDraw.Draw(eyes_open)
    draw.ellipse((15, 22, 17, 25), fill=EYE)
    draw.ellipse((20, 22, 22, 25), fill=EYE)
    draw.point((16, 23), fill=SPARKLE)
    draw.point((21, 23), fill=SPARKLE)
    save(eyes_open, "face/eyes_open.png")

    eyes_blink = new_canvas()
    draw = ImageDraw.Draw(eyes_blink)
    draw.line([(15, 24), (17, 24)], fill=OUTLINE, width=1)
    draw.line([(20, 24), (22, 24)], fill=OUTLINE, width=1)
    save(eyes_blink, "face/eyes_blink.png")

    mouth_neutral = new_canvas()
    draw = ImageDraw.Draw(mouth_neutral)
    draw.line([(17, 27), (19, 27)], fill=OUTLINE, width=1)
    save(mouth_neutral, "face/mouth_neutral.png")

    mouth_smile = new_canvas()
    draw = ImageDraw.Draw(mouth_smile)
    draw.arc((16, 26, 20, 29), start=15, end=165, fill=OUTLINE)
    save(mouth_smile, "face/mouth_smile.png")

    mouth_sleepy = new_canvas()
    draw = ImageDraw.Draw(mouth_sleepy)
    draw.line([(16, 27), (20, 27)], fill=OUTLINE, width=1)
    draw.point((18, 28), fill=OUTLINE)
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
