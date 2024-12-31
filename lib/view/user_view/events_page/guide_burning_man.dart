import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class GuideBurningMan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Burning Man Guide'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome to Burning Man!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Get ready for an unforgettable experience. This guide will help you prepare for your first adventure at Burning Man.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Survival Checklist Section
            Text(
              'Survival Checklist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            BulletList(items: [
              'Water (at least 1.5 gallons per person per day)',
              'Food and snacks',
              'Tent or shelter',
              'Dust goggles and face mask',
              'Sunscreen and lip balm',
              'Bike and lock',
              'Lighting for night visibility',
            ]),
            SizedBox(height: 20),

            // Guidelines Section
            Text(
              'Guidelines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Burning Man operates on radical self-reliance, participation, and a gift economy. Follow these principles for a fulfilling experience.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // FAQs Section
            Text(
              'FAQs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            FAQItem(
              question: 'What is Burning Man?',
              answer:
              'Burning Man is an annual event in the Nevada desert that celebrates art, self-expression, and community.',
            ),
            FAQItem(
              question: 'What should I pack?',
              answer:
              'Bring essentials for desert survival, including water, food, a tent, goggles, and sunscreen.',
            ),

            SizedBox(height: 30),

            // Navigation Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to another page or show more details
                },
                child: Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widgets for Bullet List
class BulletList extends StatelessWidget {
  final List<String> items;

  BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                item,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      )
          .toList(),
    );
  }
}

// Custom Widget for FAQ
class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(answer, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
