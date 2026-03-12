import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransaction {
  final String id;
  final String userId;
  final String packageId;
  final int coinsAdded;
  final double amountUSD;
  final String paymentIntentId;
  final String status; // 'succeeded', 'failed', 'canceled'
  final DateTime timestamp;

  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.coinsAdded,
    required this.amountUSD,
    required this.paymentIntentId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'packageId': packageId,
      'coinsAdded': coinsAdded,
      'amountUSD': amountUSD,
      'paymentIntentId': paymentIntentId,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PaymentTransaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return PaymentTransaction(
      id: snapshot.id,
      userId: data['userId'] as String,
      packageId: data['packageId'] as String,
      coinsAdded: data['coinsAdded'] as int,
      amountUSD: (data['amountUSD'] as num).toDouble(),
      paymentIntentId: data['paymentIntentId'] as String,
      status: data['status'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
