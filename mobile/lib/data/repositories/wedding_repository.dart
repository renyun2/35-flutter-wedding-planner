import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_client.dart';
import '../models/models.dart';

class WeddingRepository {
  WeddingRepository(this._dio);
  final Dio _dio;

  Future<({String token, WeddingUser user, Wedding? wedding})> login(
    String phone,
    String password,
  ) async {
    final res = await _dio.post('/api/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    final token = res.data['token'] as String;
    final user = WeddingUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map));
    final wedding = user.hasWedding ? await _fetchWeddingFromMe(token: token) : null;
    return (
      token: token,
      user: user,
      wedding: wedding,
    );
  }

  Future<({String token, WeddingUser user})> register(
    String phone,
    String password,
    String name,
  ) async {
    final res = await _dio.post('/api/auth/register', data: {
      'phone': phone,
      'password': password,
      'name': name,
    });
    return (
      token: res.data['token'] as String,
      user: WeddingUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map)),
    );
  }

  Future<({WeddingUser user, Wedding? wedding})> me() async {
    final res = await _dio.get('/api/auth/me');
    final weddingJson = res.data['wedding'];
    return (
      user: WeddingUser.fromJson(Map<String, dynamic>.from(res.data['user'] as Map)),
      wedding: weddingJson != null
          ? Wedding.fromJson(Map<String, dynamic>.from(weddingJson as Map))
          : null,
    );
  }

  Future<Wedding?> _fetchWeddingFromMe({String? token}) async {
    final res = await _dio.get(
      '/api/auth/me',
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    final weddingJson = res.data['wedding'];
    if (weddingJson == null) return null;
    return Wedding.fromJson(Map<String, dynamic>.from(weddingJson as Map));
  }

  Future<void> logout() async {
    await _dio.post('/api/auth/logout');
  }

  Future<({Wedding wedding, String bindCode})> createWedding({
    required String brideName,
    required String groomName,
    double? totalBudget,
  }) async {
    final res = await _dio.post('/api/wedding/create', data: {
      'brideName': brideName,
      'groomName': groomName,
      if (totalBudget != null) 'totalBudget': totalBudget,
    });
    return (
      wedding: Wedding.fromJson(Map<String, dynamic>.from(res.data['wedding'] as Map)),
      bindCode: res.data['bind_code'] as String,
    );
  }

  Future<Wedding> bindWedding(String bindCode) async {
    await _dio.post('/api/auth/bind', data: {'bindCode': bindCode});
    final me = await this.me();
    return me.wedding!;
  }

  Future<({Wedding wedding, double depositDeducted})> setWeddingDate(String date) async {
    final res = await _dio.put('/api/wedding/date', data: {'weddingDate': date});
    return (
      wedding: Wedding.fromJson(Map<String, dynamic>.from(res.data['wedding'] as Map)),
      depositDeducted: (res.data['deposit_deducted'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<Map<String, dynamic>> getHomeSummary() async {
    final res = await _dio.get('/api/wedding/summary');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<({List<BudgetItem> items, BudgetSummary summary})> getBudgetItems() async {
    final res = await _dio.get('/api/budget/items');
    return (
      items: (res.data['items'] as List)
          .map((e) => BudgetItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      summary: BudgetSummary.fromJson(Map<String, dynamic>.from(res.data['summary'] as Map)),
    );
  }

  Future<BudgetSummary> getBudgetSummary() async {
    final res = await _dio.get('/api/budget/summary');
    return BudgetSummary.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<BudgetItem> addBudgetItem({
    required String category,
    required String title,
    required double amount,
    double? paidAmount,
    String? status,
  }) async {
    final res = await _dio.post('/api/budget/items', data: {
      'category': category,
      'title': title,
      'amount': amount,
      if (paidAmount != null) 'paidAmount': paidAmount,
      if (status != null) 'status': status,
    });
    return BudgetItem.fromJson(Map<String, dynamic>.from(res.data['item'] as Map));
  }

  Future<List<Venue>> getVenues({int? minTables, double? maxPrice, String? district}) async {
    final res = await _dio.get('/api/venues', queryParameters: {
      if (minTables != null) 'minTables': minTables,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (district != null) 'district': district,
    });
    return (res.data['venues'] as List)
        .map((e) => Venue.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Venue> getVenue(String id) async {
    final res = await _dio.get('/api/venues/$id');
    return Venue.fromJson(Map<String, dynamic>.from(res.data['venue'] as Map));
  }

  Future<void> createVenueInquiry({
    required String venueId,
    required int tables,
    String? message,
  }) async {
    await _dio.post('/api/venue-inquiries', data: {
      'venueId': venueId,
      'tables': tables,
      if (message != null) 'message': message,
    });
  }

  Future<List<Vendor>> getVendors({String? category}) async {
    final res = await _dio.get('/api/vendors', queryParameters: {
      if (category != null) 'category': category,
    });
    return (res.data['vendors'] as List)
        .map((e) => Vendor.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Map<String, dynamic>> getVendorDetail(String id) async {
    final res = await _dio.get('/api/vendors/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getBookings() async {
    final res = await _dio.get('/api/bookings');
    return (res.data['bookings'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> createBooking({
    required String vendorId,
    required String bookingDate,
    String? note,
  }) async {
    await _dio.post('/api/bookings', data: {
      'vendorId': vendorId,
      'bookingDate': bookingDate,
      if (note != null) 'note': note,
    });
  }

  Future<List<Guest>> getGuests() async {
    final res = await _dio.get('/api/guests');
    return (res.data['guests'] as List)
        .map((e) => Guest.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Guest> addGuest({
    required String name,
    String? phone,
    int? tableNumber,
    String? rsvpStatus,
    String? side,
  }) async {
    final res = await _dio.post('/api/guests', data: {
      'name': name,
      if (phone != null) 'phone': phone,
      if (tableNumber != null) 'tableNumber': tableNumber,
      if (rsvpStatus != null) 'rsvpStatus': rsvpStatus,
      if (side != null) 'side': side,
    });
    return Guest.fromJson(Map<String, dynamic>.from(res.data['guest'] as Map));
  }

  Future<Map<String, dynamic>> getSeating() async {
    final res = await _dio.get('/api/seating');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> updateSeating(List<Map<String, dynamic>> layout) async {
    await _dio.put('/api/seating', data: {'layout': layout});
  }

  Future<List<WeddingTask>> getTasks() async {
    final res = await _dio.get('/api/tasks');
    return (res.data['tasks'] as List)
        .map((e) => WeddingTask.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> toggleTask(String id, bool completed) async {
    await _dio.put('/api/tasks/$id', data: {'completed': completed});
  }

  Future<List<Map<String, dynamic>>> getTimeline() async {
    final res = await _dio.get('/api/timeline');
    return (res.data['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> getInspirations() async {
    final res = await _dio.get('/api/inspirations');
    return (res.data['inspirations'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getContracts() async {
    final res = await _dio.get('/api/contracts');
    return (res.data['contracts'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final res = await _dio.get('/api/notifications');
    return (res.data['notifications'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    await _dio.put('/api/notifications/$id/read');
  }
}

final weddingRepositoryProvider = Provider<WeddingRepository>((ref) {
  return WeddingRepository(ref.watch(dioProvider));
});
