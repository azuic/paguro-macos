#!/usr/bin/env python3

from pathlib import Path

from PIL import Image, ImageDraw


CANVAS = 48
SCALE = 2
ROOT = Path(__file__).resolve().parents[1] / "Resources" / "Sprites" / "paguro"

TRANSPARENT = (0, 0, 0, 0)
OUTLINE = (79, 36, 32, 255)
BODY_BASE = (235, 224, 218, 255)
BODY_SHADE = (196, 184, 177, 255)
BODY_DEEP = (154, 144, 140, 255)
EYE = (19, 17, 19, 255)
SPARKLE = (255, 255, 255, 255)

SHELL_VARIANTS = {
    "shell_sand": {
        "base": (196, 161, 114, 255),
        "shade": (164, 127, 88, 255),
        "band": (236, 228, 210, 255),
        "lip": (247, 243, 232, 255),
        "opening": (108, 78, 57, 255),
        "speck": (141, 106, 76, 255),
    },
    "shell_sunset": {
        "base": (203, 132, 117, 255),
        "shade": (165, 95, 88, 255),
        "band": (243, 223, 214, 255),
        "lip": (249, 241, 236, 255),
        "opening": (114, 69, 67, 255),
        "speck": (149, 90, 84, 255),
    },
    "shell_lagoon": {
        "base": (124, 171, 165, 255),
        "shade": (88, 136, 131, 255),
        "band": (216, 236, 232, 255),
        "lip": (240, 247, 245, 255),
        "opening": (68, 97, 99, 255),
        "speck": (84, 128, 128, 255),
    },
}


def new_canvas() -> Image.Image:
    return Image.new("RGBA", (CANVAS, CANVAS), TRANSPARENT)


def save(image: Image.Image, relative_path: str) -> None:
    destination = ROOT / relative_path
    destination.parent.mkdir(parents=True, exist_ok=True)
    scaled = image.resize((CANVAS * SCALE, CANVAS * SCALE), Image.NEAREST)
    scaled.save(destination)


def close_loop(draw: ImageDraw.ImageDraw, points, fill, width=1) -> None:
    draw.line(points + [points[0]], fill=fill, width=width)


def draw_shell(name: str, colors: dict) -> None:
    image = new_canvas()
    draw = ImageDraw.Draw(image)

    shell = [
        (27, 4), (34, 4), (39, 6), (42, 10), (43, 16), (42, 22),
        (39, 27), (34, 31), (28, 33), (24, 32), (21, 29), (19, 24),
        (18, 17), (19, 10), (22, 6),
    ]
    lower_mass = [(22, 23), (28, 23), (33, 24), (37, 27), (36, 31), (31, 34), (25, 33), (22, 30)]
    lip = [(18, 18), (22, 16), (27, 16), (31, 18), (32, 21), (30, 24), (26, 25), (21, 24), (18, 21)]
    opening = [(19, 19), (23, 18), (27, 18), (29, 20), (29, 22), (27, 24), (23, 24), (20, 23), (19, 21)]

    draw.polygon(shell, fill=colors["base"])
    close_loop(draw, shell, OUTLINE)

    draw.polygon(lower_mass, fill=colors["shade"])
    draw.line([(30, 5), (35, 8), (38, 13), (39, 19), (38, 24)], fill=colors["band"], width=2)
    draw.line([(27, 8), (31, 11), (34, 16), (35, 21), (34, 26)], fill=colors["band"], width=2)
    draw.line([(24, 11), (28, 14), (30, 19), (30, 24)], fill=colors["band"], width=2)

    draw.polygon(lip, fill=colors["lip"])
    close_loop(draw, lip, OUTLINE)
    draw.polygon(opening, fill=colors["opening"])
    close_loop(draw, opening, OUTLINE)

    for x, y in [(28, 6), (31, 7), (34, 9), (36, 12), (38, 16), (37, 21), (33, 28), (27, 30)]:
        draw.point((x, y), fill=colors["speck"])
        draw.point((x + 1, y), fill=colors["speck"])

    draw.rectangle((24, 8, 25, 17), fill=(255, 255, 255, 42))
    draw.rectangle((22, 11, 23, 18), fill=(255, 255, 255, 24))

    save(image, f"shell/{name}.png")


def claw_polygons(side: str, pose: str):
    left = {
        "idle": {
            "arm": [(9, 25), (12, 23), (15, 23), (16, 27), (14, 31), (10, 30)],
            "claw": [(3, 25), (8, 22), (11, 25), (10, 30), (6, 33), (2, 31)],
            "pinch": [(4, 24), (1, 21), (2, 18), (5, 17), (8, 20), (7, 24)],
        },
        "walk_a": {
            "arm": [(10, 24), (13, 22), (16, 22), (17, 26), (15, 30), (11, 29)],
            "claw": [(4, 24), (9, 21), (12, 24), (11, 29), (7, 32), (3, 30)],
            "pinch": [(5, 23), (2, 20), (2, 17), (6, 16), (9, 19), (8, 23)],
        },
        "walk_b": {
            "arm": [(8, 26), (11, 24), (14, 24), (15, 28), (13, 32), (9, 31)],
            "claw": [(2, 27), (7, 24), (10, 27), (9, 32), (5, 35), (1, 33)],
            "pinch": [(3, 26), (0, 23), (1, 20), (4, 19), (7, 22), (6, 26)],
        },
    }
    right = {
        "idle": {
            "arm": [(31, 24), (34, 22), (37, 22), (38, 26), (36, 30), (32, 29)],
            "claw": [(37, 24), (42, 21), (45, 24), (44, 29), (40, 32), (36, 30)],
            "pinch": [(40, 24), (43, 21), (45, 18), (44, 15), (41, 14), (38, 18), (39, 22)],
        },
        "walk_a": {
            "arm": [(32, 23), (35, 21), (38, 21), (39, 25), (37, 29), (33, 28)],
            "claw": [(38, 23), (43, 20), (46, 23), (45, 28), (41, 31), (37, 29)],
            "pinch": [(41, 23), (44, 20), (46, 17), (45, 14), (42, 13), (39, 17), (40, 21)],
        },
        "walk_b": {
            "arm": [(30, 25), (33, 23), (36, 23), (37, 27), (35, 31), (31, 30)],
            "claw": [(36, 25), (41, 22), (44, 25), (43, 30), (39, 33), (35, 31)],
            "pinch": [(39, 25), (42, 22), (44, 19), (43, 16), (40, 15), (37, 19), (38, 23)],
        },
    }
    return left[pose] if side == "left" else right[pose]


def head_shapes(pose: str):
    head = {
        "idle": [(18, 19), (21, 17), (25, 17), (27, 19), (27, 24), (24, 27), (20, 27), (17, 24)],
        "walk_a": [(18, 18), (21, 16), (25, 16), (27, 18), (27, 23), (24, 26), (20, 26), (17, 23)],
        "walk_b": [(19, 20), (22, 18), (26, 18), (28, 20), (28, 25), (25, 28), (21, 28), (18, 25)],
    }
    antennas = {
        "idle": [[(20, 18), (17, 14), (14, 10), (12, 6)], [(22, 18), (22, 14), (21, 10), (20, 6)]],
        "walk_a": [[(20, 17), (17, 13), (14, 9), (12, 5)], [(22, 17), (22, 13), (21, 9), (20, 5)]],
        "walk_b": [[(21, 19), (18, 15), (15, 11), (13, 7)], [(23, 19), (23, 15), (22, 11), (21, 7)]],
    }
    return head[pose], antennas[pose]


def leg_lines(pose: str):
    return {
        "idle": [[(18, 34), (16, 38), (14, 41)], [(23, 35), (22, 40), (22, 44)], [(28, 34), (30, 38), (32, 41)]],
        "walk_a": [[(18, 34), (15, 37), (13, 39)], [(23, 35), (23, 40), (24, 44)], [(28, 34), (31, 39), (33, 43)]],
        "walk_b": [[(18, 35), (16, 40), (16, 44)], [(23, 35), (21, 38), (20, 41)], [(28, 35), (30, 38), (31, 40)]],
    }[pose]


def draw_body_frame(pose: str) -> None:
    body = new_canvas()
    claws = new_canvas()
    head = new_canvas()

    body_draw = ImageDraw.Draw(body)
    claw_draw = ImageDraw.Draw(claws)
    head_draw = ImageDraw.Draw(head)

    under_shell = [(19, 22), (25, 21), (30, 22), (32, 25), (31, 31), (28, 34), (23, 35), (18, 34), (16, 30), (16, 25)]
    abdomen = [(19, 26), (24, 25), (29, 26), (30, 29), (28, 32), (23, 33), (19, 32), (17, 29)]

    body_draw.polygon(under_shell, fill=BODY_BASE)
    body_draw.polygon(abdomen, fill=BODY_SHADE)
    close_loop(body_draw, under_shell, OUTLINE)
    body_draw.line([(20, 27), (27, 27)], fill=BODY_DEEP, width=2)
    body_draw.line([(19, 30), (27, 30)], fill=BODY_DEEP, width=1)

    for points in leg_lines(pose):
        body_draw.line(points, fill=BODY_BASE, width=2)
        body_draw.line(points, fill=OUTLINE, width=1)

    for side in ("left", "right"):
        shapes = claw_polygons(side, pose)
        claw_draw.polygon(shapes["arm"], fill=BODY_BASE)
        claw_draw.polygon(shapes["claw"], fill=BODY_BASE)
        claw_draw.polygon(shapes["pinch"], fill=BODY_SHADE)
        close_loop(claw_draw, shapes["arm"], OUTLINE)
        close_loop(claw_draw, shapes["claw"], OUTLINE)
        close_loop(claw_draw, shapes["pinch"], OUTLINE)
        claw_draw.line([shapes["claw"][1], shapes["claw"][4]], fill=BODY_DEEP, width=1)

    head_shape, antenna_sets = head_shapes(pose)
    head_draw.polygon(head_shape, fill=BODY_BASE)
    close_loop(head_draw, head_shape, OUTLINE)
    head_draw.polygon([(19, 22), (22, 20), (26, 20), (26, 23), (23, 24), (20, 24)], fill=BODY_SHADE)
    head_draw.arc((18, 21, 26, 27), start=15, end=165, fill=BODY_DEEP)
    for antenna in antenna_sets:
        head_draw.line(antenna, fill=OUTLINE, width=1)

    save(body, f"body/body_{pose}.png")
    save(claws, f"claws/claws_{pose}.png")
    save(head, f"head/head_{pose}.png")


def draw_pattern_assets() -> None:
    speckles = new_canvas()
    speckle_draw = ImageDraw.Draw(speckles)
    for x, y in [(20, 23), (25, 22), (28, 24), (13, 27), (34, 26), (18, 29), (30, 29)]:
        speckle_draw.ellipse((x, y, x + 1, y + 1), fill=(255, 255, 255, 255))
    save(speckles, "pattern/pattern_speckles.png")

    stripes = new_canvas()
    stripe_draw = ImageDraw.Draw(stripes)
    stripe_draw.line([(18, 21), (14, 31)], fill=(255, 255, 255, 255), width=1)
    stripe_draw.line([(23, 20), (20, 33)], fill=(255, 255, 255, 255), width=1)
    stripe_draw.line([(28, 21), (27, 33)], fill=(255, 255, 255, 255), width=1)
    stripe_draw.line([(33, 23), (34, 31)], fill=(255, 255, 255, 255), width=1)
    save(stripes, "pattern/pattern_stripes.png")


def draw_face_assets() -> None:
    eyes_open = new_canvas()
    draw = ImageDraw.Draw(eyes_open)
    draw.ellipse((20, 21, 22, 24), fill=EYE)
    draw.ellipse((24, 21, 26, 24), fill=EYE)
    draw.point((21, 22), fill=SPARKLE)
    draw.point((25, 22), fill=SPARKLE)
    save(eyes_open, "face/eyes_open.png")

    eyes_blink = new_canvas()
    draw = ImageDraw.Draw(eyes_blink)
    draw.line([(20, 23), (22, 23)], fill=OUTLINE, width=1)
    draw.line([(24, 23), (26, 23)], fill=OUTLINE, width=1)
    save(eyes_blink, "face/eyes_blink.png")

    mouth_neutral = new_canvas()
    draw = ImageDraw.Draw(mouth_neutral)
    draw.line([(22, 25), (24, 25)], fill=OUTLINE, width=1)
    save(mouth_neutral, "face/mouth_neutral.png")

    mouth_smile = new_canvas()
    draw = ImageDraw.Draw(mouth_smile)
    draw.arc((21, 24, 25, 27), start=15, end=165, fill=OUTLINE)
    save(mouth_smile, "face/mouth_smile.png")

    mouth_sleepy = new_canvas()
    draw = ImageDraw.Draw(mouth_sleepy)
    draw.line([(21, 25), (25, 25)], fill=OUTLINE, width=1)
    draw.point((23, 26), fill=OUTLINE)
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
