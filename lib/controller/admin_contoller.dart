

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AdminController extends ChangeNotifier {
  int totalTicketsSold = 0;
  double totalEarnings = 0.0;
  int todayTicketsSold = 0;
  double todayEarnings = 0.0;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  Future<void> fetchSalesData() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      isLoading = true;
      notifyListeners();


      final salesSnapshot = await FirebaseFirestore.instance.collection('tickets').get();

      int ticketsSold = 0;
      double earnings = 0.0;
      int todayTickets = 0;
      double todayEarn = 0.0;
      final List<Map<String, dynamic>> userList = [];

      for (var doc in salesSnapshot.docs) {
        final data = doc.data();
        final timestamp = (data['purchaseDate'] as Timestamp).toDate();
        final tickets = (data['eventTickets'] as int) + (data['vehiclePasses'] as int);
        final cost = data['totalCost'] as double;

        ticketsSold += tickets;
        earnings += cost;

        if (timestamp.isAfter(todayStart) && timestamp.isBefore(todayEnd)) {
          todayTickets += tickets;
          todayEarn += cost;
        }

        userList.add({
          'uid': data['uid'],
          'tickets': tickets,
          'cost': cost,
          'timestamp': DateFormat("yyyy-MM-dd hh:mm:ss").format(timestamp),
          'eventTicket': data['eventTickets'],
          'vehiclePasses': data['vehiclePasses'],
        });
      }

      totalTicketsSold = ticketsSold;
      totalEarnings = earnings;
      todayTicketsSold = todayTickets;
      todayEarnings = todayEarn;
      users = userList;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Error fetching sales data: $e');
    }
  }
}

final adminNotifier = ChangeNotifierProvider<AdminController>((ref) {
  return AdminController();
});