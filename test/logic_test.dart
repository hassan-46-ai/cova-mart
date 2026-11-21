import 'package:cova_mart/core/utils/validators.dart';
import 'package:cova_mart/data/models/cart.dart';
import 'package:cova_mart/data/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(double price) => Product(
      id: 'p',
      categoryId: 'pantry',
      nameEn: 'Rice',
      nameAr: 'أرز',
      descEn: '',
      descAr: '',
      price: price,
      oldPrice: null,
      unitEn: '1 kg',
      unitAr: '1 كجم',
      rating: 4.5,
      reviews: 10,
      inStock: true,
      image: 'assets/products/p.jpg',
    );

void main() {
  group('Validators', () {
    test('Egyptian phone numbers', () {
      expect(Validators.egyptPhone('01012345678'), isTrue);
      expect(Validators.egyptPhone('+201012345678'), isTrue);
      expect(Validators.egyptPhone('0212345678'), isFalse);
    });

    test('card number uses Luhn', () {
      expect(CardValidators.number('4242 4242 4242 4242'), isTrue);
      expect(CardValidators.number('4242 4242 4242 4241'), isFalse);
    });

    test('expiry must not be in the past', () {
      final now = DateTime(2026, 11, 20);
      expect(CardValidators.expiry('12/27', now), isTrue);
      expect(CardValidators.expiry('10/26', now), isFalse);
      expect(CardValidators.expiry('13/27', now), isFalse);
    });
  });

  group('CartSummary', () {
    test('promo COVA25 takes 25% and a small order pays delivery', () {
      final s = CartSummary.compute([CartLine(_product(100), 2)], 'cova25');
      expect(s.subtotal, 200);
      expect(s.discount, 50);
      expect(s.deliveryFee, 15);
      expect(s.total, 165);
    });

    test('big orders get free delivery and the discount is capped', () {
      final s = CartSummary.compute([CartLine(_product(100), 10)], 'COVA25');
      expect(s.discount, 100); // capped
      expect(s.deliveryFee, 0); // 900 left after discount
      expect(s.total, 900);
    });

    test('minimum order', () {
      expect(CartSummary.compute([CartLine(_product(20), 1)], null).meetsMinimum, isFalse);
      expect(CartSummary.compute([CartLine(_product(60), 1)], null).meetsMinimum, isTrue);
    });
  });
}
