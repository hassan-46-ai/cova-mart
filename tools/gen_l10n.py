#!/usr/bin/env python3
"""Single source of truth for UI text (English + Arabic).

Edit STRINGS below, then run from the project root:   python3 tools/gen_l10n.py
It regenerates lib/core/l10n/{app_localizations,strings_en,strings_ar}.dart and
fails if a key used in lib/ is missing.  Placeholders: {n} (int), {name}/{amount} (String).
A tuple for English means (singular, plural) - used when n == 1.
"""
import re
import sys
from pathlib import Path

S = []
def add(key, en, ar):
    S.append((key, en, ar))

# ---- navigation / splash / onboarding
add("navHome", "Home", "الرئيسية")
add("navCategories", "Categories", "الأقسام")
add("navFavourites", "Favourites", "المفضلة")
add("navMore", "More", "المزيد")
add("splashTagline", "Everything you need, in minutes.", "كل ما تحتاجه، في دقائق.")
add("onboardingTitle1", "Fresh essentials, minutes away", "احتياجاتك الطازجة، على بُعد دقائق")
add("onboardingBody1", "Your neighbourhood Cova Mart brings groceries, coffee and daily needs right to your door.", "ماركت كوفا القريب منك يوصّل البقالة والقهوة واحتياجاتك اليومية حتى باب بيتك.")
add("onboardingTitle2", "A small mart, beautifully curated", "ماركت صغير، باختيار أنيق")
add("onboardingBody2", "Around 200 everyday products picked with care. No endless aisles, just what you actually need.", "حوالي 200 منتج يومي مختار بعناية. بدون زحمة، فقط ما تحتاجه فعلاً.")
add("onboardingTitle3", "Pin your door, track your order", "حدّد موقعك وتابع طلبك")
add("onboardingBody3", "Drop a pin on the map and follow your order from our shelves to your doorstep.", "حدّد موقعك على الخريطة وتابع طلبك من رفوفنا حتى باب بيتك.")
add("skip", "Skip", "تخطي")
add("next", "Next", "التالي")
add("getStarted", "Get Started", "ابدأ الآن")
# ---- auth
add("loginTitle", "Welcome back", "أهلاً بعودتك")
add("loginSubtitle", "Log in to continue shopping with Cova Mart.", "سجّل الدخول لتكمل التسوق مع كوفا مارت.")
add("email", "Email", "البريد الإلكتروني")
add("password", "Password", "كلمة المرور")
add("loginButton", "Log in", "تسجيل الدخول")
add("noAccount", "Don't have an account?", "ليس لديك حساب؟")
add("signUp", "Sign up", "إنشاء حساب")
add("signupTitle", "Create your account", "أنشئ حسابك")
add("signupSubtitle", "Join Cova Mart and get groceries in minutes.", "انضم إلى كوفا مارت واحصل على طلباتك في دقائق.")
add("fullName", "Full name", "الاسم الكامل")
add("phone", "Phone number", "رقم الهاتف")
add("confirmPassword", "Confirm password", "تأكيد كلمة المرور")
add("createAccount", "Create account", "إنشاء الحساب")
add("haveAccount", "Already have an account?", "لديك حساب بالفعل؟")
add("errRequired", "This field is required", "هذا الحقل مطلوب")
add("errEmail", "Enter a valid email", "أدخل بريداً إلكترونياً صحيحاً")
add("errPhone", "Enter a valid Egyptian mobile number", "أدخل رقم موبايل مصري صحيح")
add("errPasswordShort", "At least 6 characters", "6 أحرف على الأقل")
add("errPasswordMatch", "Passwords don't match", "كلمتا المرور غير متطابقتين")
add("errEmailInUse", "This email is already registered", "هذا البريد مسجّل بالفعل")
add("errInvalidCredentials", "Wrong email or password", "البريد أو كلمة المرور غير صحيحة")
add("errCardNumber", "Invalid card number", "رقم البطاقة غير صحيح")
add("errExpiry", "Invalid expiry date", "تاريخ الانتهاء غير صحيح")
add("errCvc", "Invalid CVC", "رمز CVC غير صحيح")
# ---- home
add("greeting", "Hey, {name}", "أهلاً، {name}")
add("homeSubtitle", "What would you like today?", "ماذا تحتاج اليوم؟")
add("searchHint", "Search products", "ابحث عن منتج")
add("deliveryTo", "DELIVERY TO", "التوصيل إلى")
add("addAddress", "Add delivery address", "أضف عنوان التوصيل")
add("within", "WITHIN", "خلال")
add("minutesShort", "{n} min", "{n} دقيقة")
add("promoOff", "OFF", "خصم")
add("promoFirstOrder", "On your first order", "على أول طلب لك")
add("promoFreeDelivery", "Free delivery", "توصيل مجاني")
add("promoFreeDeliveryBody", "On orders over {amount}", "على الطلبات فوق {amount}")
add("promoCoffeeTitle", "Cova Coffee Corner", "ركن قهوة كوفا")
add("promoCoffeeBody", "Beans, syrups & tea for café quality at home", "بن وسيرب وشاي لجودة الكافيه في بيتك")
add("categories", "Categories", "الأقسام")
add("seeAll", "See all", "عرض الكل")
add("recommended", "Recommended", "مقترح لك")
add("hotDeals", "Hot deals", "عروض ساخنة")
add("coffeeCorner", "Coffee corner", "ركن القهوة")
add("freshToday", "Fresh today", "طازج اليوم")
add("track", "Track", "تتبّع")
# ---- categories / filters
add("shop", "Shop", "تسوّق")
add("byCategory", "By Category", "حسب القسم")
add("startingFrom", "Starting from", "يبدأ من")
add("allProducts", "All products", "كل المنتجات")
add("browseCategories", "Pick a category to start shopping", "اختر قسماً لتبدأ التسوق")
add("itemsCount", ("{n} item", "{n} items"), "{n} منتج")
add("filters", "Filters", "تصفية")
add("reset", "Reset", "إعادة ضبط")
add("sortBy", "Sort by", "ترتيب حسب")
add("sortPopular", "Popular", "الأكثر شعبية")
add("sortPriceLow", "Low price", "الأقل سعراً")
add("sortPriceHigh", "High price", "الأعلى سعراً")
add("sortRating", "Top rated", "الأعلى تقييماً")
add("sortDiscount", "Biggest discount", "أكبر خصم")
add("priceRange", "Price range", "نطاق السعر")
add("minRating", "Minimum rating", "أقل تقييم")
add("anyRating", "Any", "أي تقييم")
add("onlyOffers", "Only items on offer", "المنتجات المخفّضة فقط")
add("onOffer", "On offer", "عروض")
add("showItems", ("Show {n} item", "Show {n} items"), "عرض {n} منتج")
add("noResults", "No results found", "لا توجد نتائج")
add("noResultsFilters", "Try changing or resetting your filters.", "جرّب تغيير الفلاتر أو إعادة ضبطها.")
add("noResultsSearch", "Check the spelling or try a different word.", "تأكد من الكتابة أو جرّب كلمة أخرى.")
# ---- product
add("outOfStock", "Out of stock", "غير متوفر")
add("addToCart", "Add to cart", "أضف للسلة")
add("added", "Added", "تمت الإضافة")
add("buyNow", "Buy now", "اشترِ الآن")
add("addedToCart", "Added to your cart", "تمت الإضافة إلى السلة")
add("viewCart", "View cart", "عرض السلة")
add("quantity", "Quantity", "الكمية")
add("details", "Details", "التفاصيل")
add("productInfo", "Product info", "معلومات المنتج")
add("size", "Size", "الحجم")
add("category", "Category", "القسم")
add("storage", "Storage", "التخزين")
add("delivery", "Delivery", "التوصيل")
add("deliveryInfo", "Delivered in about 30 minutes", "يصلك خلال حوالي 30 دقيقة")
add("reviews", "Reviews", "التقييمات")
add("reviewsCount", ("{n} review", "{n} reviews"), "{n} تقييم")
add("youSave", "You save {amount}", "وفّرت {amount}")
add("youMayAlsoLike", "You may also like", "قد يعجبك أيضاً")
add("productNotFound", "Product not found", "المنتج غير موجود")
# ---- favourites / search
add("favouritesTitle", "Favourites", "المفضلة")
add("savedItems", ("{n} saved item", "{n} saved items"), "{n} منتج محفوظ")
add("noFavourites", "No favourites yet", "لا توجد منتجات مفضلة")
add("noFavouritesBody", "Tap the heart on any product to save it here.", "اضغط على القلب في أي منتج ليظهر هنا.")
add("browseProducts", "Browse products", "تصفّح المنتجات")
add("recentSearches", "Recent searches", "عمليات البحث الأخيرة")
add("clearAll", "Clear all", "مسح الكل")
add("popularSearches", "Popular searches", "الأكثر بحثاً")
# ---- cart
add("cartTitle", "Shopping Cart ({n})", "سلة التسوق ({n})")
add("cartEmpty", "Your cart is empty", "سلتك فارغة")
add("cartEmptyBody", "Add a few items and they'll show up here.", "أضف بعض المنتجات وستظهر هنا.")
add("startShopping", "Start shopping", "ابدأ التسوق")
add("useCodeHint", "Use code COVA25 at checkout. Tap to apply", "استخدم الكود COVA25 عند الدفع. اضغط للتطبيق")
add("promoCode", "Promo code", "كود الخصم")
add("apply", "Apply", "تطبيق")
add("promoApplied", "Promo applied", "تم تطبيق الكود")
add("promoInvalid", "That code isn't valid", "هذا الكود غير صالح")
add("removedFromCart", "Item removed", "تم حذف المنتج")
add("undo", "Undo", "تراجع")
add("addForFreeDelivery", "Add {amount} more for free delivery", "أضف {amount} للحصول على توصيل مجاني")
add("freeDeliveryUnlocked", "You've unlocked free delivery!", "حصلت على توصيل مجاني!")
add("subtotal", "Subtotal", "المجموع الفرعي")
add("discount", "Discount", "الخصم")
add("deliveryFee", "Delivery", "التوصيل")
add("free", "Free", "مجاني")
add("total", "Total", "الإجمالي")
add("minOrderWarning", "Add {amount} more to reach the minimum order", "أضف {amount} للوصول إلى الحد الأدنى للطلب")
add("proceedToCheckout", "Proceed to checkout", "المتابعة للدفع")
# ---- checkout
add("checkout", "Checkout", "إتمام الطلب")
add("deliveryAddress", "Delivery address", "عنوان التوصيل")
add("change", "Change", "تغيير")
add("deliveryTime", "Delivery time", "وقت التوصيل")
add("slotAsap", "As soon as possible (~30 min)", "في أسرع وقت (~30 دقيقة)")
add("slotWithinHour", "Within 1 hour", "خلال ساعة")
add("slotEvening", "Today 6–8 PM", "اليوم 6–8 مساءً")
add("slotTomorrow", "Tomorrow 10 AM–12 PM", "غداً 10 ص – 12 ظ")
add("paymentMethod", "Payment method", "طريقة الدفع")
add("cashOnDelivery", "Cash on delivery", "الدفع عند الاستلام")
add("cashOnDeliveryBody", "Pay the rider when your order arrives", "ادفع للمندوب عند وصول طلبك")
add("payByCard", "Pay by card", "الدفع بالبطاقة")
add("payByCardBody", "Credit or debit card", "بطاقة ائتمان أو خصم")
add("cardHolder", "Card holder name", "اسم حامل البطاقة")
add("cardNumber", "Card number", "رقم البطاقة")
add("expiry", "Expiry (MM/YY)", "تاريخ الانتهاء (MM/YY)")
add("cardDemoNote", "Demo only: card details are not stored or charged. Connect a payment provider before going live.", "للتجربة فقط: لا يتم حفظ بيانات البطاقة أو الخصم منها. اربط مزود دفع قبل الإطلاق.")
add("orderNote", "Order note", "ملاحظات الطلب")
add("orderNoteHint", "Anything we should know? (optional)", "أي ملاحظات؟ (اختياري)")
add("orderSummary", "Order summary", "ملخص الطلب")
add("placeOrder", "Place order", "تأكيد الطلب")
add("selectAddressFirst", "Please add a delivery address", "من فضلك أضف عنوان التوصيل")
add("approveOrder", "Approve your order", "وافق على طلبك")
add("approveOrderBody", "Please review the details below before we start preparing it.", "راجع التفاصيل أدناه قبل أن نبدأ بتجهيزه.")
add("items", "Items", "المنتجات")
add("deliverTo", "Deliver to", "التوصيل إلى")
add("confirmOrder", "Confirm & place order", "تأكيد وإرسال الطلب")
add("reviewOrder", "Review order", "مراجعة الطلب")
add("orderApproved", "Order approved!", "تمت الموافقة على طلبك!")
add("orderApprovedBody", "We're preparing your order now. It should reach you in about {n} minutes.", "نجهّز طلبك الآن. سيصلك خلال حوالي {n} دقيقة.")
add("trackOrder", "Track order", "تتبّع الطلب")
add("backToHome", "Back to home", "العودة للرئيسية")
# ---- orders
add("myOrders", "My orders", "طلباتي")
add("active", "Active", "الحالية")
add("past", "Past", "السابقة")
add("noOrders", "No orders yet", "لا توجد طلبات بعد")
add("noOrdersBody", "Your orders will appear here.", "ستظهر طلباتك هنا.")
add("reorder", "Reorder", "إعادة الطلب")
add("itemsAddedToCart", "Items added to your cart", "تمت إضافة المنتجات إلى السلة")
add("statusPlaced", "Order placed", "تم استلام الطلب")
add("statusPreparing", "Preparing your order", "جارٍ تجهيز طلبك")
add("statusOnTheWay", "On the way", "في الطريق إليك")
add("statusDelivered", "Delivered", "تم التوصيل")
# ---- addresses / map
add("savedAddresses", "Saved addresses", "العناوين المحفوظة")
add("noAddresses", "No saved addresses", "لا توجد عناوين محفوظة")
add("noAddressesBody", "Add your delivery address to order faster.", "أضف عنوان التوصيل لتطلب أسرع.")
add("addNewAddress", "Add new address", "إضافة عنوان جديد")
add("addressHome", "Home", "المنزل")
add("addressWork", "Work", "العمل")
add("addressOther", "Other", "آخر")
add("searchAddress", "Search for an address", "ابحث عن عنوان")
add("confirmLocation", "Confirm location", "تأكيد الموقع")
add("addressDetails", "Address details (street, building, floor)", "تفاصيل العنوان (الشارع، العمارة، الدور)")
add("locationUnavailable", "Couldn't get a GPS fix. Move to an open area or search for your address instead.", "تعذّر تحديد موقعك. جرّب مكاناً مفتوحاً أو ابحث عن عنوانك.")
add("locationServiceOff", "Location (GPS) is turned off. Please turn it on.", "خدمة الموقع (GPS) مغلقة. من فضلك فعّلها.")
add("locationDenied", "Location permission was denied.", "تم رفض إذن الموقع.")
add("locationDeniedForever", "Location permission is blocked. Enable it from the app settings.", "إذن الموقع محظور. فعّله من إعدادات التطبيق.")
add("locationNotConfigured", "Location permission is missing from the app configuration (AndroidManifest / Info.plist).", "إذن الموقع غير مُضاف إلى إعدادات التطبيق (AndroidManifest / Info.plist).")
add("openSettings", "Settings", "الإعدادات")
add("deliveryLocation", "Delivery location", "موقع التوصيل")
# ---- profile
add("editProfile", "Edit profile", "تعديل الملف الشخصي")
add("saveChanges", "Save changes", "حفظ التغييرات")
add("profileSaved", "Profile updated", "تم تحديث الملف الشخصي")
add("language", "Language", "اللغة")
add("appearance", "Appearance", "المظهر")
add("themeSystem", "System", "حسب الجهاز")
add("themeLight", "Light", "فاتح")
add("themeDark", "Dark", "داكن")
add("about", "About", "عن التطبيق")
add("logout", "Log out", "تسجيل الخروج")
add("logoutConfirm", "Are you sure you want to log out?", "هل تريد تسجيل الخروج؟")
add("cancel", "Cancel", "إلغاء")
# ---- notifications
add("notifOrderTitle", "Order #{name}", "الطلب #{name}")
add("notifPreparingBody", "We're preparing your order now.", "نجهّز طلبك الآن.")
add("notifOnTheWayBody", "Your order is on its way to you.", "طلبك في الطريق إليك.")
add("notifDeliveredBody", "Your order has been delivered. Enjoy!", "تم توصيل طلبك. بالهنا والشفا!")
add("notifChannelName", "Order updates", "تحديثات الطلبات")
add("notifChannelDesc", "Status updates for your Cova Mart orders", "تحديثات حالة طلباتك من كوفا مارت")
add("notificationsTitle", "Order notifications", "إشعارات الطلبات")
add("notificationsSubtitle", "Alert me when my order status changes", "نبّهني عند تغيّر حالة طلبي")
add("notifPermissionDenied", "Notifications are blocked. Enable them in the app settings.", "الإشعارات محظورة. فعّلها من إعدادات التطبيق.")

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "lib/core/l10n"


def q(s: str) -> str:
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def params(text: str):
    return list(dict.fromkeys(re.findall(r"\{(\w+)\}", text)))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    en_map, ar_map, getters = {}, {}, []
    for key, en, ar in S:
        plural = isinstance(en, tuple)
        en_one, en_other = en if plural else (en, en)
        ps = params(en_other)
        en_map[key] = en_other
        ar_map[key] = ar
        if plural:
            en_map[key + ".one"] = en_one
            ar_map[key + ".one"] = ar
        if not ps:
            getters.append(f"  String get {key} => _t({q(key)});")
        else:
            sig = ", ".join(("int " if p == "n" else "String ") + p for p in ps)
            args = ", ".join(f"{q(p)}: {p}" for p in ps)
            k = f"n == 1 ? {q(key + '.one')} : {q(key)}" if plural else q(key)
            getters.append(f"  String {key}({sig}) => _f({k}, {{{args}}});")

    def dump(name, m):
        body = "\n".join(f"  {q(k)}: {q(v)}," for k, v in m.items())
        (OUT / f"strings_{name}.dart").write_text(
            f"// GENERATED by tools/gen_l10n.py - do not edit by hand.\nconst Map<String, String> strings{name.capitalize()} = {{\n{body}\n}};\n",
            encoding="utf-8")

    dump("en", en_map)
    dump("ar", ar_map)
    (OUT / "app_localizations.dart").write_text(f"""// GENERATED by tools/gen_l10n.py - do not edit by hand.
import 'package:flutter/widgets.dart';

import 'strings_ar.dart';
import 'strings_en.dart';

/// Typed access to every UI string. Use `context.l10n.someKey`.
class AppLocalizations {{
  AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  Map<String, String> get _strings => locale.languageCode == 'ar' ? stringsAr : stringsEn;

  String _t(String key) => _strings[key] ?? stringsEn[key] ?? key;

  String _f(String key, Map<String, Object> args) {{
    var text = _t(key);
    args.forEach((k, v) => text = text.replaceAll('{{$k}}', '$v'));
    return text;
  }}

{chr(10).join(getters)}
}}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {{
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}}

extension AppLocalizationsX on BuildContext {{
  AppLocalizations get l10n => AppLocalizations.of(this);
}}
""", encoding="utf-8")

    used = set()
    for f in (ROOT / "lib").rglob("*.dart"):
        if "core/l10n" in str(f):
            continue
        used |= set(re.findall(r"l10n\.(\w+)", f.read_text(encoding="utf-8")))
    defined = {k for k, _, _ in S}
    missing = sorted(used - defined)
    unused = sorted(defined - used)
    print(f"{len(S)} strings generated.")
    if unused:
        print("unused keys:", ", ".join(unused))
    if missing:
        print("MISSING keys:", ", ".join(missing))
        sys.exit(1)


if __name__ == "__main__":
    main()
