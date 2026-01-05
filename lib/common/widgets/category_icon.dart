import 'package:flutter/material.dart';
import 'package:kasidie_city_whisper/domain/entities/place.dart';

class CategoryIcon extends StatelessWidget {
  final PlaceCategory category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    
    switch (category) {
      case PlaceCategory.museum:
        iconData = Icons.museum;
        break;
      case PlaceCategory.art:
        iconData = Icons.palette;
        break;
      case PlaceCategory.viewpoint:
        iconData = Icons.landscape;
        break;
      case PlaceCategory.water:
        iconData = Icons.water_drop;
        break;
      case PlaceCategory.toilet:
        iconData = Icons.wc;
        break;
      case PlaceCategory.bike:
        iconData = Icons.pedal_bike;
        break;
    }

    return Icon(iconData, size: size);
  }
}
