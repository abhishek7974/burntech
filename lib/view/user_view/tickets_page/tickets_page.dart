import 'package:burntech/core/firebase_constant/firebase_constants.dart';
import 'package:burntech/core/theme/theme_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {

  int eventTicketQuantity = 0;
  int vehicleTicketQuantity = 0;

  double eventTicketPrice = 475.0;
  double vehicleTicketPrice = 140.0;

  double get totalCost =>
      (eventTicketQuantity * eventTicketPrice) +
          (vehicleTicketQuantity * vehicleTicketPrice);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: const Text(
          'Burning Man Tickets',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Event Tickets'),
            _buildTicketCard(
              title: 'Event Ticket',
              price: eventTicketPrice,
              quantity: eventTicketQuantity,
              onIncrement: () => setState(() => eventTicketQuantity++),
              onDecrement: () =>
                  setState(() => eventTicketQuantity = eventTicketQuantity > 0 ? eventTicketQuantity - 1 : 0),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Vehicle Pass'),
            _buildTicketCard(
              title: 'Vehicle Pass',
              price: vehicleTicketPrice,
              quantity: vehicleTicketQuantity,
              onIncrement: () => setState(() => vehicleTicketQuantity++),
              onDecrement: () =>
                  setState(() => vehicleTicketQuantity = vehicleTicketQuantity > 0 ? vehicleTicketQuantity - 1 : 0),
            ),
            const Spacer(),
            const Divider(thickness: 2),
            _buildTotalCostRow(),
            const SizedBox(height: 16),
            _buildPurchaseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildTicketCard({
    required String title,
    required double price,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${price.toStringAsFixed(2)} each',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 0 ? onDecrement : null,
                  icon: const Icon(Icons.remove),
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCostRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total:',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${totalCost.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: totalCost > 0
          ? () => _showPurchaseDialog(context)
          : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Buy Tickets',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          'You are about to purchase:\n'
              '$eventTicketQuantity x Event Tickets\n'
              '$vehicleTicketQuantity x Vehicle Passes\n\n'
              'Total: \$${totalCost.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async{
              // Save data to Firebase with UID
              await FirebaseFirestore.instance.collection('tickets').add({
                'uid': FirebaseConstants.auth.currentUser?.uid,
                'eventTickets': eventTicketQuantity,
                'vehiclePasses': vehicleTicketQuantity,
                'totalCost': totalCost,
                'purchaseDate': DateTime.now(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase Successful!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
