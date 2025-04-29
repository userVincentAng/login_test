import 'package:flutter/material.dart';

class PriceService {
  static const double PRICE_INCREASE_PERCENTAGE = 0.10; // 10% increase
  static const double HANDLING_FEE_NON_COD =
      10.0; // 10 pesos handling fee for non-COD

  static double calculateProductPrice(double originalPrice) {
    return originalPrice * (1 + PRICE_INCREASE_PERCENTAGE);
  }

  static double calculateDeliveryFee({
    required double distanceInKM,
    double plugRate = 50.0,
    double firstKMRate = 4.0,
    double perKMRate = 10.0,
  }) {
    if (distanceInKM <= firstKMRate) {
      return plugRate;
    }

    double additionalKM = distanceInKM - firstKMRate;
    double additionalFee = additionalKM * perKMRate;
    return plugRate + additionalFee;
  }

  static double calculateTotalWithFees({
    required double subtotal,
    required double deliveryFee,
    required bool isCOD,
  }) {
    double total = subtotal + deliveryFee;
    if (!isCOD) {
      total += HANDLING_FEE_NON_COD;
    }
    return total;
  }
}
