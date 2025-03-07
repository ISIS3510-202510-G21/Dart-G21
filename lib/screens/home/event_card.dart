import 'package:flutter/material.dart';
import '../../core/colors.dart';

class EventCard extends StatelessWidget {
  final Map<String, String> event;

  const EventCard({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 247,
      height: 124,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(11),
        elevation: 5,
        color: AppColors.primary,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child:Image.network(
                  event["image"] ?? "",
                  width: 210,
                  height: 110,
                  fit: BoxFit.cover,
                )
              ),


              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event["name"] ?? "No name",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 5),
                        Text(
                          event["date"] ?? "Unknown date",
                          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event["location"] ?? "Unknown Location",
                            style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
