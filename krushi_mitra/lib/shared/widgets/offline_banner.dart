import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final DateTime lastUpdated;

  const OfflineBanner({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    final difference = DateTime.now().difference(lastUpdated);
    String timeAgo = '';
    
    if (difference.inHours > 0) {
      timeAgo = '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes} minutes ago';
    } else {
      timeAgo = 'just now';
    }

    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Offline Mode • Last updated: $timeAgo',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
