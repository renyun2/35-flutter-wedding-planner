import 'package:flutter/foundation.dart';

@immutable
class WeddingUser {
  const WeddingUser({
    required this.id,
    required this.phone,
    required this.name,
    this.weddingId,
  });

  factory WeddingUser.fromJson(Map<String, dynamic> json) => WeddingUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
        weddingId: json['wedding_id'] as String?,
      );

  final String id;
  final String phone;
  final String name;
  final String? weddingId;

  bool get hasWedding => weddingId != null && weddingId!.isNotEmpty;
}

@immutable
class Wedding {
  const Wedding({
    required this.id,
    required this.brideName,
    required this.groomName,
    this.weddingDate,
    this.dateLocked = false,
    this.totalBudget = 200000,
    this.depositPaid = 0,
    this.bindCode,
  });

  factory Wedding.fromJson(Map<String, dynamic> json) => Wedding(
        id: json['id'] as String,
        brideName: json['bride_name'] as String,
        groomName: json['groom_name'] as String,
        weddingDate: json['wedding_date'] as String?,
        dateLocked: json['date_locked'] == 1 || json['date_locked'] == true,
        totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 200000,
        depositPaid: (json['deposit_paid'] as num?)?.toDouble() ?? 0,
        bindCode: json['bind_code'] as String?,
      );

  final String id;
  final String brideName;
  final String groomName;
  final String? weddingDate;
  final bool dateLocked;
  final double totalBudget;
  final double depositPaid;
  final String? bindCode;
}

@immutable
class BudgetSummary {
  const BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalPaid,
    required this.totalPending,
    required this.remaining,
    required this.overBudget,
  });

  factory BudgetSummary.fromJson(Map<String, dynamic> json) => BudgetSummary(
        totalBudget: (json['total_budget'] as num).toDouble(),
        totalSpent: (json['total_spent'] as num).toDouble(),
        totalPaid: (json['total_paid'] as num).toDouble(),
        totalPending: (json['total_pending'] as num).toDouble(),
        remaining: (json['remaining'] as num).toDouble(),
        overBudget: json['over_budget'] == true,
      );

  final double totalBudget;
  final double totalSpent;
  final double totalPaid;
  final double totalPending;
  final double remaining;
  final bool overBudget;
}

@immutable
class BudgetItem {
  const BudgetItem({
    required this.id,
    required this.category,
    required this.title,
    required this.amount,
    required this.paidAmount,
    required this.status,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) => BudgetItem(
        id: json['id'] as String,
        category: json['category'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        paidAmount: (json['paid_amount'] as num).toDouble(),
        status: json['status'] as String,
      );

  final String id;
  final String category;
  final String title;
  final double amount;
  final double paidAmount;
  final String status;
}

@immutable
class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.minTables,
    required this.maxTables,
    required this.pricePerTable,
    required this.imageUrl,
    required this.description,
    required this.distanceKm,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        district: json['district'] as String? ?? '',
        minTables: (json['min_tables'] as num).toInt(),
        maxTables: (json['max_tables'] as num).toInt(),
        pricePerTable: (json['price_per_table'] as num).toDouble(),
        imageUrl: json['image_url'] as String? ?? '',
        description: json['description'] as String? ?? '',
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      );

  final String id;
  final String name;
  final String address;
  final String district;
  final int minTables;
  final int maxTables;
  final double pricePerTable;
  final String imageUrl;
  final String description;
  final double distanceKm;
}

@immutable
class Vendor {
  const Vendor({
    required this.id,
    required this.category,
    required this.name,
    required this.price,
    required this.rating,
    required this.description,
    required this.imageUrl,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as String,
        category: json['category'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        rating: (json['rating'] as num).toDouble(),
        description: json['description'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
      );

  final String id;
  final String category;
  final String name;
  final double price;
  final double rating;
  final String description;
  final String imageUrl;
}

@immutable
class Guest {
  const Guest({
    required this.id,
    required this.name,
    required this.phone,
    this.tableNumber,
    required this.rsvpStatus,
    required this.side,
  });

  factory Guest.fromJson(Map<String, dynamic> json) => Guest(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String? ?? '',
        tableNumber: (json['table_number'] as num?)?.toInt(),
        rsvpStatus: json['rsvp_status'] as String? ?? 'pending',
        side: json['side'] as String? ?? 'bride',
      );

  final String id;
  final String name;
  final String phone;
  final int? tableNumber;
  final String rsvpStatus;
  final String side;
}

@immutable
class WeddingTask {
  const WeddingTask({
    required this.id,
    required this.title,
    this.dueDate,
    required this.completed,
    required this.category,
  });

  factory WeddingTask.fromJson(Map<String, dynamic> json) => WeddingTask(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: json['due_date'] as String?,
        completed: json['completed'] == 1 || json['completed'] == true,
        category: json['category'] as String? ?? 'general',
      );

  final String id;
  final String title;
  final String? dueDate;
  final bool completed;
  final String category;
}

String vendorCategoryLabel(String category) {
  switch (category) {
    case 'photo':
      return '摄影';
    case 'video':
      return '摄像';
    case 'makeup':
      return '化妆';
    case 'host':
      return '主持';
    default:
      return category;
  }
}

String rsvpLabel(String status) {
  switch (status) {
    case 'accepted':
      return '确认出席';
    case 'declined':
      return '无法出席';
    default:
      return '待回复';
  }
}

int daysUntilWedding(String? weddingDate) {
  if (weddingDate == null || weddingDate.isEmpty) return -1;
  final target = DateTime.parse(weddingDate);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(target.year, target.month, target.day);
  return day.difference(today).inDays;
}
