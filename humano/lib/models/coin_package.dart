class CoinPackage {
  final String id;
  final int coins;
  final double priceUSD;
  final String displayPrice;
  final bool isPopular;
  final int? bonusCoins;

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.priceUSD,
    required this.displayPrice,
    this.isPopular = false,
    this.bonusCoins,
  });

  int get totalCoins => coins + (bonusCoins ?? 0);

  // Paquetes disponibles (Precios en MXN)
  static const List<CoinPackage> available = [
    CoinPackage(
      id: 'coins_100',
      coins: 100,
      priceUSD: 30.0,
      displayPrice: '\$30 MXN',
    ),
    CoinPackage(
      id: 'coins_300',
      coins: 300,
      priceUSD: 80.0,
      displayPrice: '\$80 MXN',
      bonusCoins: 20, // 6% bonus
    ),
    CoinPackage(
      id: 'coins_700',
      coins: 700,
      priceUSD: 170.0,
      displayPrice: '\$170 MXN',
      isPopular: true,
      bonusCoins: 80, // 11% bonus
    ),
    CoinPackage(
      id: 'coins_1500',
      coins: 1500,
      priceUSD: 350.0,
      displayPrice: '\$350 MXN',
      bonusCoins: 250, // 16% bonus
    ),
  ];
}
