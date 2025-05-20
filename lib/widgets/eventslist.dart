import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_g21/views/eventdetail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../controllers/location_controller.dart';
import '../core/colors.dart';
import '../models/event.dart';
import '../models/location.dart' as app_models;
import '../data/database/firestore_service.dart';

class EventsList extends StatefulWidget {
  final Stream<List<Event>> Function() eventsStreamProvider;
  final String userId;
  final String section;
  const EventsList({Key? key, required this.eventsStreamProvider, required this.userId, required this.section}) : super(key: key);


  @override
  _EventsListState createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  int _visibleCount = 5;
  int _lastEventsCount = 0;
  final ScrollController _scrollController = ScrollController();
  bool _hasLoggedInteraction = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll()  {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
        _visibleCount < _lastEventsCount) {
      setState(() {
        _visibleCount += 5;
      });
    }
    if( !_hasLoggedInteraction){
      logInteraction();
      _hasLoggedInteraction=true;
    }

  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: StreamBuilder<List<Event>>(
        stream: widget.eventsStreamProvider(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("error at charging the events"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No events"));
          }

          List<Event> events = snapshot.data!;
          _lastEventsCount = events.length;
          int itemCount = (_visibleCount < events.length) ? _visibleCount + 1 : events.length + 1;

          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == itemCount - 1) {
                return SizedBox(
                  width: 200,
                  child: Center(
                    child: _visibleCount >= events.length
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "There are no more events",
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    )
                        : const CircularProgressIndicator(),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: _buildEventCard(events[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
    onTap: () {
      logEventDetailClick(widget.userId, event.name);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(
            eventId: event.id,
            userId: widget.userId, 
          ),
        ),
);
}, child: SizedBox(
      width: 257,
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
              if (event.image.isNotEmpty && Uri.tryParse(event.image)?.hasAbsolutePath == true)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: event.image,
                    width: 220,
                    height: 106,
                    fit: BoxFit.cover,
                    cacheManager: CacheManager(
                      Config(
                        'customCacheKey',
                        stalePeriod: const Duration(days: 7),
                        maxNrOfCacheObjects: 100,
                      ),
                    ),
                    placeholder: (context, url) => Container(
                        width: 220,
                        height: 106,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (context, url, error) => Container(
                      width: 220,
                      height: 106,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.secondaryText),
                        const SizedBox(width: 5),
                        Text(
                          "${event.start_date.day}/${event.start_date.month}/${event.start_date.year}",
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
                          child: FutureBuilder<app_models.Location?>(
                            future: LocationController().getLocationById(event.location_id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Text(
                                  "Loading location...",
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return const Text(
                                  "Unknown location",
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                );
                              }
                              return Text(
                                snapshot.data!.address,
                                style: const TextStyle(fontSize: 10, color: AppColors.secondaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
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
    ),
    );
  }

  void logEventDetailClick(String userId, String eventName) {
    FirebaseFirestore.instance.collection('eventdetail_clicks').add({
      'user_id': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'name': eventName,
    });
  }

  Future<void> logInteraction() async {
    await FirebaseFirestore.instance.collection('home_interactions').add({
      'timestamp': FieldValue.serverTimestamp(),
      'userId': widget.userId,
      'interactionType': widget.section,
    });
  }

}