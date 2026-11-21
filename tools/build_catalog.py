#!/usr/bin/env python3
"""Generates assets/data/catalog.json (10 categories x 20 products = 200).

Run from the project root:  python3 tools/build_catalog.py
Prices are placeholder EGP values - replace them with your real price list.
"""
import hashlib
import json
import re
from pathlib import Path

UNIT_AR = {
    "kg": "كجم", "g": "جم", "L": "لتر", "ml": "مل", "pcs": "قطعة", "pc": "قطعة",
    "pack": "عبوة", "bags": "كيس", "sachets": "ظرف", "rolls": "لفة", "m": "متر",
    "sheets": "منديل", "sticks": "عود", "bunch": "حزمة",
}

# id, nameEn, nameAr, subtitleEn, subtitleAr, tint, icon, photoHint, descEn, descAr, storageEn, storageAr
CATEGORIES = [
    ("produce", "Fresh Produce", "خضار وفاكهة", "Picked fresh daily", "طازجة كل يوم", "D8F5E3", "produce", "fresh",
     "{n}, selected daily and packed fresh for your table.",
     "{n} يتم اختياره يومياً ويصلك طازجاً لمائدتك.",
     "Keep refrigerated and rinse before eating.", "يُحفظ في الثلاجة ويُغسل قبل الاستخدام."),
    ("dairy", "Dairy & Eggs", "ألبان وبيض", "Chilled & creamy", "باردة وكريمية", "DCEBFF", "dairy", "",
     "{n}: a daily essential from the chilled aisle.",
     "{n} من أساسيات المطبخ اليومية، محفوظ بارداً.",
     "Store between 2°C and 6°C. Check the date on the pack.", "يُحفظ بين 2 و6 درجات مئوية. راجع تاريخ الصلاحية."),
    ("bakery", "Bakery", "مخبوزات", "Oven fresh", "طازجة من الفرن", "FFE8CF", "bakery", "bakery",
     "{n}, baked fresh and best enjoyed the same day.",
     "{n} مخبوز طازجاً ويُفضّل تناوله في نفس اليوم.",
     "Keep in a cool, dry place and eat within 2 days.", "يُحفظ في مكان بارد وجاف ويُستهلك خلال يومين."),
    ("coffee", "Coffee & Tea", "قهوة وشاي", "From the Cova coffee bar", "من ركن قهوة كوفا", "E9DFD3", "coffee", "",
     "{n}, chosen to bring the Cova coffee bar experience home.",
     "{n} مختار ليمنحك تجربة ركن قهوة كوفا في بيتك.",
     "Seal tightly and keep away from light and moisture.", "يُغلق جيداً ويُحفظ بعيداً عن الضوء والرطوبة."),
    ("drinks", "Beverages", "مشروبات", "Cold & refreshing", "باردة ومنعشة", "D5F6F5", "drinks", "drink",
     "{n}, served best chilled.",
     "{n} الأفضل عند تقديمه بارداً.",
     "Serve chilled. Refrigerate after opening.", "يُقدّم بارداً ويُحفظ في الثلاجة بعد الفتح."),
    ("snacks", "Snacks & Sweets", "سناكس وحلويات", "Treat yourself", "دلّع نفسك", "FFE1E6", "snacks", "snack",
     "{n}, a small treat for any time of day.",
     "{n} مكافأة صغيرة في أي وقت من اليوم.",
     "Store in a cool, dry place.", "يُحفظ في مكان بارد وجاف."),
    ("pantry", "Pantry", "بقالة", "Kitchen staples", "أساسيات المطبخ", "F2EBD0", "pantry", "",
     "{n}, a dependable kitchen staple in a mart-friendly size.",
     "{n} من أساسيات المطبخ بحجم مناسب للاستخدام اليومي.",
     "Store in a cool, dry place away from sunlight.", "يُحفظ في مكان بارد وجاف بعيداً عن الشمس."),
    ("frozen", "Frozen", "مجمدات", "Ready when you are", "جاهزة وقت ما تحب", "E0E7FF", "frozen", "frozen",
     "{n}, frozen at its best so dinner is never far away.",
     "{n} مجمّد في أفضل حالاته ليكون العشاء جاهزاً دائماً.",
     "Keep frozen at -18°C. Do not refreeze after thawing.", "يُحفظ مجمداً عند -18 درجة. لا يُعاد تجميده بعد الإذابة."),
    ("care", "Personal Care", "عناية شخصية", "Everyday essentials", "احتياجاتك اليومية", "F3E3FF", "care", "product",
     "{n} for your everyday routine.",
     "{n} لروتينك اليومي.",
     "Store at room temperature, away from direct heat.", "يُحفظ في درجة حرارة الغرفة بعيداً عن الحرارة المباشرة."),
    ("home", "Home & Cleaning", "منزل ومنظفات", "Keep it spotless", "بيت نظيف ولامع", "E4F1F4", "home", "household",
     "{n}, a practical pick to keep the home fresh and tidy.",
     "{n} اختيار عملي ليبقى بيتك نظيفاً ومنعشاً.",
     "Keep out of reach of children. Store in a dry place.", "يُحفظ بعيداً عن متناول الأطفال وفي مكان جاف."),
]

PRODUCTS = {
"produce": """Bananas|موز|38|1 kg
Red Apples|تفاح أحمر|75|1 kg
Oranges|برتقال|28|1 kg
Lemons|ليمون|45|500 g
Strawberries|فراولة|60|500 g
Green Grapes|عنب أخضر|80|1 kg
Avocado|أفوكادو|95|500 g
Tomatoes|طماطم|22|1 kg
Cucumbers|خيار|20|1 kg
Potatoes|بطاطس|25|1 kg
Red Onions|بصل أحمر|18|1 kg
Carrots|جزر|20|1 kg
Bell Peppers|فلفل رومي ملون|55|500 g
Lettuce|خس|15|1 pc
Baby Spinach|سبانخ بيبي|28|200 g
Zucchini|كوسة|24|500 g
Fresh Garlic|ثوم طازج|30|250 g
Fresh Mint|نعناع طازج|8|1 bunch
Fresh Parsley|بقدونس|8|1 bunch
Broccoli|بروكلي|35|500 g""",
"dairy": """Full Cream Milk|حليب كامل الدسم|42|1 L
Low Fat Milk|حليب قليل الدسم|42|1 L
Lactose-Free Milk|حليب خالي من اللاكتوز|58|1 L
Natural Yogurt|زبادي طبيعي|12|170 g
Greek Yogurt|زبادي يوناني|26|150 g
Cream Cheese|جبنة كريمي|32|150 g
Domiati Cheese|جبنة دمياطي|45|250 g
Mozzarella Cheese|جبنة موزاريلا|55|200 g
Cheddar Slices|شرائح تشيدر|48|150 g
Halloumi Cheese|جبنة حلومي|70|200 g
Salted Butter|زبدة مملحة|38|100 g
Cooking Cream|كريمة طبخ|30|200 ml
Eggs|بيض|60|12 pcs
Small Eggs Pack|بيض عبوة صغيرة|32|6 pcs
Laban Rayeb|لبن رايب|18|500 ml
Chocolate Milk|حليب بالشوكولاتة|14|200 ml
Strawberry Milk|حليب بالفراولة|14|200 ml
Plain Labneh|لبنة سادة|28|200 g
Feta Cheese|جبنة فيتا|35|250 g
Rice Pudding|أرز بلبن|16|150 g""",
"bakery": """Baladi Bread|عيش بلدي|10|5 pcs
Sliced White Toast|توست أبيض|32|400 g
Whole Wheat Toast|توست أسمر|36|400 g
Butter Croissant|كرواسون بالزبدة|22|1 pc
Chocolate Croissant|كرواسون بالشوكولاتة|28|1 pc
Almond Croissant|كرواسون باللوز|34|1 pc
Brioche Buns|خبز بريوش|40|4 pcs
Fino Bread|عيش فينو|12|4 pcs
Burger Buns|خبز برجر|30|4 pcs
Hot Dog Buns|خبز هوت دوج|28|4 pcs
Pita Bread|خبز بيتا|18|6 pcs
Cinnamon Roll|رول القرفة|32|1 pc
Blueberry Muffin|مافن التوت|24|1 pc
Chocolate Muffin|مافن الشوكولاتة|24|1 pc
Glazed Donut|دونات مغطى|20|1 pc
Cheese Fatayer|فطيرة جبنة|26|1 pc
Butter Rusk|بقسماط بالزبدة|30|200 g
Kaak Biscuits|كعك بسكويت|25|250 g
Chocolate Cake Slice|شريحة كيك الشوكولاتة|40|1 pc
Banana Loaf|كيكة الموز|35|1 pc""",
"coffee": """Espresso Beans|حبوب إسبريسو|220|250 g
Medium Roast Ground Coffee|بن مطحون تحميص متوسط|120|200 g
Turkish Coffee|قهوة تركي|65|100 g
Instant Coffee|قهوة سريعة التحضير|110|100 g
3-in-1 Coffee Sachets|قهوة 3 في 1|45|10 sachets
Cold Brew Coffee|كولد برو|55|250 ml
Black Tea Bags|شاي أسود أكياس|50|25 bags
Loose Black Tea|شاي أسود سايب|60|250 g
Green Tea Bags|شاي أخضر|48|20 bags
Mint Tea|شاي بالنعناع|40|20 bags
Chamomile Tea|شاي بابونج|42|20 bags
Hibiscus Tea|كركديه|35|100 g
Hazelnut Syrup|سيرب بندق|140|250 ml
Vanilla Syrup|سيرب فانيليا|140|250 ml
Caramel Syrup|سيرب كراميل|140|250 ml
Hot Chocolate Powder|هوت شوكليت بودر|85|250 g
Coffee Creamer|مبيض قهوة|60|200 g
Brown Sugar Sticks|سكر بني أعواد|32|20 sticks
Ground Cardamom|حبهان مطحون|45|50 g
Matcha Powder|ماتشا بودر|180|50 g""",
"drinks": """Still Water|مياه معدنية|6|600 ml
Still Water Large|مياه معدنية كبيرة|12|1.5 L
Sparkling Water|مياه غازية طبيعية|18|330 ml
Cola|مشروب كولا|15|330 ml
Lemon Lime Soda|مشروب ليمون غازي|15|330 ml
Orange Soda|مشروب برتقال غازي|15|330 ml
Orange Juice|عصير برتقال|48|1 L
Mango Juice|عصير مانجو|42|1 L
Apple Juice|عصير تفاح|12|250 ml
Guava Juice|عصير جوافة|12|235 ml
Energy Drink|مشروب طاقة|30|250 ml
Peach Iced Tea|آيس تي خوخ|20|500 ml
Lemon Iced Tea|آيس تي ليمون|20|500 ml
Sports Drink|مشروب رياضي|25|500 ml
Coconut Water|ماء جوز الهند|35|330 ml
Malt Drink|مشروب الشعير|18|330 ml
Fresh Lemonade|ليمونادة|28|500 ml
Tamarind Drink|عصير تمر هندي|30|500 ml
Mixed Berry Juice|عصير توت مشكل|45|1 L
Protein Shake|مشروب بروتين|55|330 ml""",
"snacks": """Salted Potato Chips|بطاطس شيبس بالملح|10|40 g
Cheese Potato Chips|بطاطس شيبس بالجبنة|10|40 g
Tortilla Chips|تورتيلا شيبس|22|100 g
Salted Popcorn|فشار مملح|18|60 g
Mixed Nuts|مكسرات مشكلة|95|150 g
Roasted Almonds|لوز محمص|85|100 g
Cashew Nuts|كاجو|110|100 g
Pistachios|فستق|130|100 g
Salted Peanuts|فول سوداني مملح|20|100 g
Dark Chocolate Bar|شوكولاتة داكنة|45|80 g
Milk Chocolate Bar|شوكولاتة بالحليب|35|80 g
Chocolate Wafer|ويفر بالشوكولاتة|12|1 pack
Chocolate Biscuits|بسكويت بالشوكولاتة|18|1 pack
Butter Cookies|كوكيز بالزبدة|40|200 g
Oat Bar|لوح الشوفان|20|1 pc
Granola Bar|لوح جرانولا|22|1 pc
Gummy Bears|جيلي دببة|18|100 g
Mint Candies|حلوى النعناع|10|1 pack
Medjool Dates|تمر مجدول|120|250 g
Dried Apricots|مشمش مجفف|55|200 g""",
"pantry": """Basmati Rice|أرز بسمتي|65|1 kg
Egyptian Rice|أرز مصري|38|1 kg
Spaghetti|مكرونة اسباجيتي|16|400 g
Penne Pasta|مكرونة بيني|16|400 g
Vermicelli|شعرية|14|250 g
Sunflower Oil|زيت دوار الشمس|68|700 ml
Extra Virgin Olive Oil|زيت زيتون بكر ممتاز|230|500 ml
White Sugar|سكر أبيض|32|1 kg
Table Salt|ملح طعام|10|700 g
All-Purpose Flour|دقيق متعدد الاستخدامات|28|1 kg
Yellow Lentils|عدس أصفر|36|500 g
Chickpeas|حمص|40|500 g
Canned Fava Beans|فول مدمس معلب|18|400 g
Tomato Paste|صلصة طماطم|14|135 g
Canned Tuna|تونة معلبة|55|160 g
Canned Sweet Corn|ذرة حلوة معلبة|28|340 g
Tahini|طحينة|65|300 g
Natural Honey|عسل نحل|130|250 g
Strawberry Jam|مربى فراولة|38|350 g
Peanut Butter|زبدة فول سوداني|75|340 g""",
"frozen": """Frozen Peas|بسلة مجمدة|30|450 g
Frozen Mixed Vegetables|خضروات مشكلة مجمدة|32|450 g
French Fries|بطاطس مجمدة|55|750 g
Frozen Molokhia|ملوخية مجمدة|28|400 g
Frozen Okra|بامية مجمدة|35|400 g
Chicken Nuggets|ناجتس دجاج|85|400 g
Chicken Breast Fillets|صدور دجاج|110|500 g
Beef Burger Patties|برجر لحم|95|4 pcs
Fish Fillet|فيليه سمك|120|400 g
Frozen Shrimp|جمبري مجمد|160|250 g
Vanilla Ice Cream|آيس كريم فانيليا|70|500 ml
Chocolate Ice Cream|آيس كريم شوكولاتة|70|500 ml
Ice Cream Sticks|آيس كريم أعواد|60|4 pcs
Frozen Pizza|بيتزا مجمدة|90|350 g
Puff Pastry Sheets|عجينة بف باستري|45|400 g
Cheese Sambousek|سمبوسك جبنة|50|10 pcs
Frozen Spring Rolls|سبرينج رول مجمد|58|10 pcs
Frozen Strawberries|فراولة مجمدة|45|400 g
Mozzarella Sticks|أصابع موزاريلا|75|8 pcs
Ice Cubes|مكعبات ثلج|15|1 kg""",
"care": """Shampoo|شامبو|85|200 ml
Conditioner|بلسم|85|200 ml
Shower Gel|جل استحمام|70|250 ml
Bar Soap|صابون|45|4 pcs
Hand Wash|سائل غسيل اليدين|40|250 ml
Toothpaste|معجون أسنان|38|75 ml
Soft Toothbrush|فرشاة أسنان ناعمة|25|1 pc
Mouthwash|غسول فم|65|250 ml
Roll-On Deodorant|مزيل عرق رول|50|50 ml
Deodorant Spray|مزيل عرق بخاخ|75|150 ml
Face Wash|غسول وجه|90|150 ml
Moisturizing Cream|كريم مرطب|80|100 ml
Sunscreen SPF 50|واقي شمس|160|50 ml
Lip Balm|مرطب شفاه|35|1 pc
Disposable Razors|شفرات حلاقة|45|3 pcs
Shaving Foam|رغوة حلاقة|70|200 ml
Facial Tissues|مناديل ورقية|28|150 sheets
Wet Wipes|مناديل مبللة|25|20 pcs
Cotton Pads|قطن للوجه|22|100 pcs
Hand Sanitizer|معقم يدين|30|100 ml""",
"home": """Dish Soap|سائل غسيل الأطباق|40|500 ml
Laundry Detergent|مسحوق غسيل|85|1 kg
Fabric Softener|منعم أقمشة|60|1 L
Multi-Surface Cleaner|منظف متعدد الأسطح|45|500 ml
Glass Cleaner|منظف زجاج|38|500 ml
Bleach|كلور|25|1 L
Floor Cleaner|منظف أرضيات|42|1 L
Toilet Paper|ورق تواليت|55|4 rolls
Paper Towels|مناديل مطبخ|48|2 rolls
Trash Bags|أكياس قمامة|30|20 pcs
Kitchen Sponges|اسفنج مطبخ|20|3 pcs
Aluminum Foil|ورق ألومنيوم|40|10 m
Cling Film|فيلم تغليف|35|30 m
Zipper Storage Bags|أكياس حفظ|32|20 pcs
Paper Napkins|مناديل سفرة|18|100 pcs
Air Freshener|معطر جو|55|300 ml
Insect Spray|مبيد حشرات|75|300 ml
AA Batteries|بطاريات AA|45|4 pcs
LED Light Bulb|لمبة ليد|40|1 pc
Paper Cups|أكواب ورقية|35|25 pcs""",
}


def h(text: str) -> int:
    return int(hashlib.md5(text.encode()).hexdigest(), 16)


def unit_ar(unit_en: str) -> str:
    m = re.match(r"^([\d.]+)\s*(\w+)$", unit_en)
    if not m:
        return unit_en
    return f"{m.group(1)} {UNIT_AR.get(m.group(2), m.group(2))}"


def main() -> None:
    cats, prods = [], []
    n = 0
    for cid, en, ar, sen, sar, tint, icon, hint, den, dar, stren, strar in CATEGORIES:
        cats.append({"id": cid, "nameEn": en, "nameAr": ar, "subtitleEn": sen, "subtitleAr": sar,
                     "tint": tint, "icon": icon, "storageEn": stren, "storageAr": strar})
        rows = [r.split("|") for r in PRODUCTS[cid].strip().splitlines()]
        assert len(rows) == 20, (cid, len(rows))
        for i, (name_en, name_ar, price, unit) in enumerate(rows):
            n += 1
            pid = f"p{n:03d}"
            price = float(price)
            old = None
            if i % 4 == 1 and price >= 12:
                factor = (1.15, 1.2, 1.25, 1.3)[h(pid) % 4]
                old = float(round(price * factor))
            rating = round(3.9 + (h(pid + "r") % 11) / 10, 1)
            prods.append({
                "id": pid, "categoryId": cid, "nameEn": name_en, "nameAr": name_ar,
                "descEn": den.format(n=name_en), "descAr": dar.format(n=name_ar),
                "price": price, "oldPrice": old, "unitEn": unit, "unitAr": unit_ar(unit),
                "rating": rating, "reviews": 12 + h(pid + "v") % 470,
                "inStock": h(pid + "s") % 37 != 0,
                "image": f"assets/products/{pid}.jpg",
                "imageQuery": f"{name_en.lower()} {hint}".strip(),
            })
    out = Path(__file__).resolve().parent.parent / "assets" / "data" / "catalog.json"
    out.write_text(json.dumps({"categories": cats, "products": prods}, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(cats)} categories, {len(prods)} products -> {out}")


if __name__ == "__main__":
    main()
