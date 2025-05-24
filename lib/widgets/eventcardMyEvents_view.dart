import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../core/colors.dart';
import '../models/event.dart';


class EventCard extends StatelessWidget {
  final Event event;
  final String profileId;
  final bool isConnected;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const EventCard({
    Key? key,
    required this.event,
    required this.profileId,
    required this.isConnected,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.blue.withOpacity(0.2),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: event.image,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 40),
                    cacheManager: CacheManager(
                      Config('customCacheKeyMyEvents', stalePeriod: Duration(days: 7)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_formatDate(event.start_date)} - ${_formatTime(event.start_date)}",
                        style: const TextStyle(color: AppColors.secondary),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Column(
                  
                  children: [
                    IconButton(icon: const Icon(Icons.flag_outlined), onPressed: () {}),
                    const SizedBox(height: 25),
                    isConnected ? IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: isConnected ? onDelete : null,
                    ):IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.icons),
                        onPressed: () async {},
                      ) ,
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) => "${_getWeekday(date.weekday)}, ${_getMonth(date.month)} ${date.day}";
  String _formatTime(DateTime date) => "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}";
  String _getWeekday(int day) => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day - 1];
  String _getMonth(int month) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][month - 1];
}
