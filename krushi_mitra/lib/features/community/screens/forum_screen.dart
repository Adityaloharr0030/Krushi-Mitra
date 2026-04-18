import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Farmer Community Forum'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Text('F\${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ramesh Kumar', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Pune, Maharashtra • 2 hrs ago', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Can anyone suggest a good drought-resistant variety of wheat for the upcoming Rabi season?'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(onPressed: (){}, icon: const Icon(Icons.thumb_up_alt_outlined), label: const Text('24 Likes')),
                      TextButton.icon(onPressed: (){}, icon: const Icon(Icons.comment_outlined), label: const Text('8 Comments')),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
    );
  }
}
