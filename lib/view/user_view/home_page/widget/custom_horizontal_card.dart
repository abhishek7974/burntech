import 'package:flutter/material.dart';


class CustomCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function()? onClick;

  const CustomCard({
    Key? key,
    this.onClick,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Card(

        margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
        elevation: 1,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.1),
            //     blurRadius: 8,
            //     spreadRadius: 2,
            //   ),
            // ],
            // border: Border.all()
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.black,
              ),
              SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
