#!/usr/bin/env python3
"""Draws the flat category illustrations -> assets/categories/<id>.png (transparent, 480x480).

Style: Cova cyan circle + flat-colour objects. Run from the project root:
    python3 tools/make_category_art.py
Edit the draw_* functions to change a picture. Coordinates are 0..1000.
"""
import math
from pathlib import Path

from PIL import Image, ImageDraw

K = 3          # supersampling (draw big, shrink for smooth edges)
OUT = 480

BLACK = (10, 10, 10); WHITE = (255, 255, 255); CYAN = (56, 255, 248); CYAN_D = (20, 207, 199)
RED = (229, 72, 77); RED_D = (179, 38, 43); ORANGE = (255, 138, 31); YELLOW = (255, 210, 63)
GREEN = (59, 178, 115); GREEN_D = (31, 122, 76); BROWN = (122, 74, 43); BROWN_D = (75, 42, 24)
CREAM = (246, 235, 217); TAN = (217, 138, 61); BLUE = (58, 123, 213); BLUE_D = (35, 84, 160)
PINK = (255, 143, 171); GRAY = (201, 209, 214); GRAY_D = (150, 160, 168); AMBER = (242, 169, 0)


class Canvas:
    def __init__(self):
        self.img = Image.new("RGBA", (1000 * K, 1000 * K), (0, 0, 0, 0))
        self.d = ImageDraw.Draw(self.img)

    # --- primitives (unit coordinates) ---
    def _s(self, *v):
        return [x * K for x in v]

    def ell(self, x0, y0, x1, y1, fill=None, outline=None, w=0):
        self.d.ellipse(self._s(x0, y0, x1, y1), fill=fill, outline=outline, width=int(w * K))

    def circ(self, cx, cy, r, fill=None, outline=None, w=0):
        self.ell(cx - r, cy - r, cx + r, cy + r, fill, outline, w)

    def rr(self, x0, y0, x1, y1, r, fill):
        self.d.rounded_rectangle(self._s(x0, y0, x1, y1), radius=r * K, fill=fill)

    def poly(self, pts, fill):
        self.d.polygon([v * K for p in pts for v in p], fill=fill)

    def line(self, pts, w, fill):
        flat = [v * K for p in pts for v in p]
        self.d.line(flat, fill=fill, width=int(w * K), joint="curve")
        for x, y in (pts[0], pts[-1]):  # round caps
            self.circ(x, y, w / 2, fill)

    def arc(self, box, a0, a1, w, fill):
        self.d.arc(self._s(*box), a0, a1, fill=fill, width=int(w * K))

    def rotated(self, fn, angle, cx, cy):
        """Draw with fn(canvas) on a fresh layer, rotate it around (cx, cy), paste."""
        layer = Canvas()
        fn(layer)
        rot = layer.img.rotate(-angle, center=(cx * K, cy * K), resample=Image.BICUBIC)
        self.img.alpha_composite(rot)

    # --- shared scene bits ---
    def backdrop(self):
        self.circ(500, 480, 380, CYAN)
        # soft crescent shade at the bottom-right for depth
        mask = Image.new("L", self.img.size, 0)
        md = ImageDraw.Draw(mask)
        md.ellipse([120 * K, 100 * K, 880 * K, 860 * K], fill=255)
        md.ellipse([95 * K, 60 * K, 855 * K, 820 * K], fill=0)
        shade = Image.new("RGBA", self.img.size, (20, 207, 199, 120))
        shade.putalpha(mask.point(lambda v: 120 if v else 0))
        self.img.alpha_composite(shade)

    def ground(self):
        self.ell(170, 770, 830, 850, (0, 0, 0, 38))
        self.line([(190, 812), (810, 812)], 7, (10, 10, 10, 150))

    def save(self, path):
        self.img.resize((OUT, OUT), Image.LANCZOS).save(path, optimize=True)


def scene(fn):
    c = Canvas()
    c.backdrop()
    c.ground()
    fn(c)
    return c


# ---------------------------------------------------------------- pictures
def produce(c):
    c.ell(300, 300, 700, 700, GREEN)                       # leafy greens behind
    c.line([(500, 330), (500, 700)], 14, GREEN_D)
    # carrot
    def carrot(cv):
        cv.poly([(235, 470), (365, 470), (300, 800)], ORANGE)
        cv.ell(235, 440, 365, 500, ORANGE)
        for y in (560, 630, 700):
            cv.line([(262, y), (300, y + 12)], 9, (214, 100, 10))
        for dx, h in ((-40, 190), (0, 230), (40, 190)):
            cv.ell(300 + dx - 20, 470 - h, 300 + dx + 20, 470, GREEN)
    c.rotated(carrot, -14, 300, 600)
    # tomato
    c.circ(650, 650, 150, RED); c.ell(560, 540, 640, 600, (255, 255, 255, 110))
    c.poly([(650, 520), (680, 545), (720, 540), (692, 570), (710, 605), (650, 585), (590, 605), (608, 570), (580, 540), (620, 545)], GREEN_D)
    # lemon
    c.ell(430, 650, 600, 780, YELLOW); c.ell(455, 668, 505, 700, (255, 245, 170))


def dairy(c):
    # carton
    c.rr(215, 400, 405, 800, 14, WHITE)
    c.poly([(215, 400), (310, 310), (405, 400)], (232, 238, 244))
    c.rect = None
    c.rr(215, 540, 405, 700, 6, BLUE)
    c.circ(310, 620, 40, WHITE); c.poly([(310, 560), (282, 612), (338, 612)], WHITE)
    # bottle
    c.rr(450, 450, 580, 800, 44, WHITE); c.rr(490, 340, 540, 470, 14, WHITE)
    c.rr(485, 310, 545, 350, 10, BLUE_D); c.rr(450, 580, 580, 690, 6, BLUE)
    # cheese
    c.poly([(610, 800), (870, 800), (870, 600)], YELLOW)
    c.poly([(610, 800), (870, 600), (840, 585), (610, 690)], (255, 232, 110))
    for (x, y, r) in ((780, 740, 22), (730, 775, 14), (825, 690, 14)):
        c.circ(x, y, r, (230, 170, 20))


def bakery(c):
    def baguette(cv):
        cv.rr(340, 250, 440, 780, 50, TAN)
        for y in (330, 440, 550, 660):
            cv.line([(360, y), (420, y + 40)], 10, (170, 100, 35))
    c.rotated(baguette, 32, 390, 520)
    c.rr(190, 540, 520, 800, 120, TAN)
    c.ell(210, 545, 500, 700, (240, 170, 90))
    for x in (290, 355, 420):
        c.line([(x, 590), (x + 30, 660)], 14, (170, 100, 35))
    c.ell(560, 580, 850, 800, (232, 166, 74)); c.ell(585, 595, 800, 700, (250, 200, 120))
    for (x, y) in ((650, 640), (700, 620), (750, 650), (690, 690), (740, 700), (620, 690)):
        c.ell(x, y, x + 20, y + 11, CREAM)


def coffee(c):
    # saucer + cup in Cova colours
    c.ell(230, 745, 770, 835, CYAN_D); c.ell(260, 745, 740, 810, (24, 226, 217))
    c.ell(330, 770, 670, 815, (10, 150, 145))
    c.circ(705, 610, 70, None, BLACK, 26)                      # handle
    c.rr(330, 470, 670, 790, 110, BLACK)
    c.ell(330, 440, 670, 530, WHITE); c.ell(345, 452, 655, 520, BROWN)
    c.ell(430, 468, 570, 506, CREAM); c.ell(470, 474, 530, 500, BROWN)   # latte art
    c.circ(500, 650, 52, CYAN); c.circ(500, 650, 34, BLACK)
    c.arc((466, 616, 534, 684), 40, 320, 11, CYAN)
    for x in (430, 500, 570):                                  # steam
        c.line([(x, 410), (x - 18, 360), (x + 10, 310), (x - 10, 260)], 16, (255, 255, 255, 220))
    for (x, y, a) in ((790, 760, 20), (835, 725, -25)):        # beans
        def bean(cv, x=x, y=y):
            cv.ell(x - 38, y - 26, x + 38, y + 26, BROWN_D)
            cv.line([(x - 28, y), (x + 28, y)], 6, (40, 20, 10))
        c.rotated(bean, a, x, y)


def drinks(c):
    c.rr(215, 380, 375, 800, 64, (59, 31, 20)); c.rr(265, 260, 325, 400, 16, (59, 31, 20))
    c.rr(257, 232, 333, 275, 14, RED); c.rr(215, 520, 375, 650, 6, WHITE); c.rr(215, 560, 375, 610, 0, RED)
    c.rr(430, 450, 590, 800, 30, BLUE); c.ell(430, 430, 590, 485, GRAY); c.rr(430, 580, 590, 660, 0, WHITE)
    c.line([(445, 620), (480, 600), (515, 640), (550, 600), (578, 620)], 12, BLUE_D)
    c.poly([(650, 520), (860, 520), (825, 800), (685, 800)], (255, 255, 255, 190))
    c.poly([(660, 580), (850, 580), (822, 800), (688, 800)], ORANGE)
    c.line([(790, 540), (840, 360)], 22, RED); c.line([(802, 500), (820, 440)], 22, WHITE)
    c.circ(850, 530, 58, YELLOW); c.circ(850, 530, 40, (255, 232, 110))


def snacks(c):
    def lolli(cv):
        cv.rr(488, 330, 512, 700, 10, CREAM); cv.circ(500, 280, 130, PINK)
        cv.arc((400, 180, 600, 380), 20, 300, 26, WHITE); cv.circ(500, 280, 22, WHITE)
    c.rotated(lolli, 12, 500, 400)
    def bar(cv):
        cv.rr(230, 480, 590, 720, 26, BROWN)
        for x in (320, 410, 500):
            cv.line([(x, 490), (x, 710)], 8, BROWN_D)
        for y in (560, 640):
            cv.line([(240, y), (580, y)], 8, BROWN_D)
        cv.rr(230, 620, 590, 730, 20, GRAY); cv.line([(250, 660), (570, 660)], 6, WHITE)
    c.rotated(bar, -16, 410, 600)
    c.circ(700, 680, 130, (222, 160, 90)); c.circ(700, 680, 130, None, (180, 115, 55), 10)
    for (x, y) in ((660, 630), (730, 640), (690, 710), (750, 700), (650, 700)):
        c.circ(x, y, 17, BROWN_D)


def pantry(c):
    c.rr(215, 440, 455, 800, 70, AMBER); c.rr(240, 390, 430, 455, 14, BROWN_D)
    c.rr(250, 560, 420, 700, 20, CREAM); c.circ(335, 630, 36, AMBER); c.rr(240, 470, 262, 760, 11, (255, 215, 90))
    c.rr(510, 430, 740, 800, 22, CREAM)
    c.poly([(510, 430), (535, 395), (560, 430), (585, 395), (610, 430), (635, 395), (660, 430), (685, 395), (710, 430), (740, 430)], (225, 210, 180))
    c.rr(510, 560, 740, 690, 0, GREEN); c.circ(625, 625, 42, WHITE); c.circ(625, 625, 24, GREEN_D)
    c.rr(775, 600, 885, 800, 16, RED); c.rr(775, 600, 885, 640, 10, GRAY); c.rr(775, 760, 885, 800, 10, GRAY)
    c.circ(830, 700, 30, WHITE)


def frozen(c):
    for a in range(0, 360, 60):
        x = 500 + 250 * math.cos(math.radians(a)); y = 420 + 250 * math.sin(math.radians(a))
        c.line([(500, 420), (x, y)], 24, WHITE)
        for t in (0.55, 0.8):
            bx = 500 + 250 * t * math.cos(math.radians(a)); by = 420 + 250 * t * math.sin(math.radians(a))
            for s in (-35, 35):
                ex = bx + 70 * math.cos(math.radians(a + s)); ey = by + 70 * math.sin(math.radians(a + s))
                c.line([(bx, by), (ex, ey)], 14, WHITE)
    c.circ(500, 420, 34, WHITE)
    c.rr(240, 520, 400, 760, 70, PINK); c.rr(240, 520, 400, 610, 60, BROWN_D)
    c.rr(310, 740, 335, 830, 10, CREAM)
    c.rr(540, 500, 760, 800, 22, BLUE); c.rr(540, 500, 760, 545, 10, (120, 170, 235))
    for (x, y) in ((600, 640), (650, 620), (700, 660), (640, 700), (690, 730), (595, 735)):
        c.circ(x, y, 24, GREEN)


def care(c):
    c.rr(215, 430, 395, 800, 52, WHITE); c.rr(215, 560, 395, 700, 0, CYAN_D); c.circ(305, 630, 34, WHITE)
    c.rr(280, 380, 330, 440, 8, GRAY); c.rr(255, 330, 385, 385, 20, BLACK); c.rr(370, 340, 450, 362, 10, BLACK)
    def tube(cv):
        cv.rr(470, 590, 800, 720, 40, WHITE); cv.rr(470, 640, 800, 670, 0, RED)
        cv.rr(780, 615, 870, 695, 14, BLACK)
        cv.poly([(470, 590), (440, 600), (440, 710), (470, 720)], GRAY)
    c.rotated(tube, -14, 650, 650)
    c.rr(480, 735, 720, 815, 34, PINK); c.rr(500, 745, 700, 775, 14, (255, 190, 205))
    for (x, y, r) in ((740, 690, 26), (775, 730, 18), (700, 640, 14)):
        c.circ(x, y, r, (255, 255, 255, 190), WHITE, 5)


def home(c):
    c.rr(215, 470, 405, 800, 46, GREEN); c.rr(240, 560, 380, 720, 12, WHITE); c.circ(310, 640, 34, GREEN)
    c.rr(270, 400, 350, 480, 12, GREEN_D); c.rr(250, 330, 420, 410, 28, BLACK)
    c.rr(410, 345, 495, 372, 12, BLACK); c.rr(340, 410, 395, 480, 14, GRAY_D)
    c.rr(490, 650, 770, 800, 34, YELLOW); c.rr(490, 650, 770, 715, 30, GREEN)
    for (x, y) in ((540, 745), (610, 765), (680, 740), (730, 770)):
        c.ell(x, y, x + 26, y + 16, (214, 170, 20))
    for (x, y, r) in ((650, 340, 64), (760, 450, 44), (560, 470, 34), (830, 310, 30)):
        c.circ(x, y, r, (255, 255, 255, 70), WHITE, 7); c.circ(x - r * .3, y - r * .3, r * .16, WHITE)


def deals(c):
    def tag(cv):
        cv.poly([(300, 410), (500, 290), (700, 410), (700, 760), (300, 760)], BLACK)
        cv.line([(500, 380), (452, 250), (520, 205), (548, 300)], 13, BLACK)
        cv.circ(500, 380, 34, CYAN)
        cv.circ(500, 380, 20, BLACK)
        cv.circ(420, 520, 42, None, CYAN, 22); cv.circ(580, 680, 42, None, CYAN, 22)
        cv.line([(610, 500), (390, 700)], 34, CYAN)
    c.rotated(tag, 14, 500, 530)


def all_products(c):
    def baguette(cv):
        cv.rr(300, 220, 380, 600, 40, TAN)
        for y in (290, 380, 470):
            cv.line([(315, y), (365, y + 30)], 9, (170, 100, 35))
    c.rotated(baguette, -18, 340, 420)
    c.rr(430, 300, 530, 560, 36, WHITE); c.rr(445, 270, 515, 320, 12, BLUE_D); c.rr(430, 400, 530, 470, 0, BLUE)
    c.rr(570, 360, 740, 560, 14, RED); c.rr(570, 420, 740, 470, 0, YELLOW)
    c.ell(250, 420, 420, 540, GREEN)
    c.arc((290, 230, 710, 640), 180, 360, 30, BLACK)
    c.poly([(210, 500), (790, 500), (710, 800), (290, 800)], BLACK)
    c.rr(190, 480, 810, 535, 24, BLACK)
    for x in (340, 430, 500, 570, 660):
        c.line([(x - (500 - x) * 0.0, 545), (x + (x - 500) * .12, 785)], 12, CYAN)
    c.line([(255, 640), (745, 640)], 12, CYAN)


ART = {"produce": produce, "dairy": dairy, "bakery": bakery, "coffee": coffee, "drinks": drinks,
       "snacks": snacks, "pantry": pantry, "frozen": frozen, "care": care, "home": home,
       "deals": deals, "all": all_products}

if __name__ == "__main__":
    out = Path(__file__).resolve().parent.parent / "assets" / "categories"
    out.mkdir(parents=True, exist_ok=True)
    for name, fn in ART.items():
        scene(fn).save(out / f"{name}.png")
        print("wrote", name)
