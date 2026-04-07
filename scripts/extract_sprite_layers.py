#!/usr/bin/env python3

from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


CANVAS = 96
ROOT = Path(__file__).resolve().parents[1] / "Resources" / "Sprites" / "paguro"


def load(relative_path: str) -> Image.Image:
    return Image.open(ROOT / relative_path).convert("RGBA")


def save(image: Image.Image, relative_path: str) -> None:
    destination = ROOT / relative_path
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination)


def new_mask() -> Image.Image:
    return Image.new("L", (CANVAS, CANVAS), 0)


def masked(image: Image.Image, mask: Image.Image) -> Image.Image:
    red, green, blue, alpha = image.split()
    masked_alpha = ImageChops.multiply(alpha, mask)
    return Image.merge("RGBA", (red, green, blue, masked_alpha))


def scale_points(points):
    return [(x * 2, y * 2) for x, y in points]


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


def head_region():
    return [(14, 20), (20, 18), (28, 18), (34, 20), (35, 26), (31, 31), (23, 31), (16, 29), (12, 25)]


def shell_bridge():
    return [(24, 17), (28, 16), (31, 18), (31, 21), (28, 22), (24, 21), (22, 19)]


def build_claw_mask(pose: str) -> Image.Image:
    mask = new_mask()
    draw = ImageDraw.Draw(mask)
    for claw in (claw_points("left", pose), claw_points("right", pose)):
        scaled = scale_points(claw)
        draw.polygon(scaled, fill=255)
        draw.line(scaled + [scaled[0]], fill=255, width=6)
    return mask


def build_head_mask() -> Image.Image:
    mask = new_mask()
    draw = ImageDraw.Draw(mask)
    region = scale_points(head_region())
    bridge = scale_points(shell_bridge())
    draw.polygon(region, fill=255)
    draw.line(region + [region[0]], fill=255, width=6)
    draw.polygon(bridge, fill=255)
    return mask


def main() -> None:
    static_head_mask = build_head_mask()

    for pose in ("idle", "walk_a", "walk_b"):
        body_fill = load(f"body/body_fill_{pose}.png")
        body_outline = load(f"body/body_outline_{pose}.png")
        claw_mask = build_claw_mask(pose)

        save(masked(body_fill, claw_mask), f"claws/claws_fill_{pose}.png")
        save(masked(body_outline, claw_mask), f"claws/claws_outline_{pose}.png")
        save(masked(body_fill, static_head_mask), f"head/head_fill_{pose}.png")
        save(masked(body_outline, static_head_mask), f"head/head_outline_{pose}.png")


if __name__ == "__main__":
    main()
