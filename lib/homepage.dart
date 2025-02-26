import 'package:flutter/material.dart';
import 'package:project_1/main.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Water usage"),
          Text("data"),
          Container(
            width: 200,
            height: 200,
            child: Text("yes"),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(20)),
          ),
          Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSPYM7NjdAcbofVcyHQY5kgst8MBegdugCqFA&s")
        ],
      ),
    );
  }
}
