import 'package:flutter/material.dart';

import '../domain/entities/gift_card.dart';

class GiftCardCatalog {
  GiftCardCatalog._();

  static const List<GiftCard> local = [
    GiftCard(
      id: 'libyana',
      brand: 'Libyana',
      tagline: 'Mobile recharge',
      icon: Icons.signal_cellular_alt,
      color: Color(0xFF00843D),
      denominations: [5, 10, 20, 50, 100],
    ),
    GiftCard(
      id: 'al_madar',
      brand: 'Al Madar',
      tagline: 'Mobile recharge',
      icon: Icons.signal_cellular_4_bar,
      color: Color(0xFFE30613),
      denominations: [5, 10, 20, 50, 100],
    ),
    GiftCard(
      id: 'ltt',
      brand: 'Libyan Spider',
      tagline: 'LTT internet & ADSL',
      icon: Icons.wifi,
      color: Color(0xFF002F6C),
      denominations: [10, 25, 50, 100],
    ),
    GiftCard(
      id: 'hatif_libya',
      brand: 'Hatif Libya',
      tagline: 'Landline recharge',
      icon: Icons.phone_in_talk_outlined,
      color: Color(0xFF7A1F2B),
      denominations: [10, 25, 50],
    ),
    GiftCard(
      id: 'giga',
      brand: 'Giga',
      tagline: 'Fibre internet',
      icon: Icons.router_outlined,
      color: Color(0xFF5B2A86),
      denominations: [25, 50, 100],
    ),
  ];

  static const List<GiftCard> international = [
    GiftCard(
      id: 'itunes',
      brand: 'iTunes',
      tagline: 'Music, movies & apps',
      icon: Icons.music_note,
      color: Color(0xFF000000),
      denominations: [10, 25, 50, 100],
    ),
    GiftCard(
      id: 'google_play',
      brand: 'Google Play',
      tagline: 'Apps, games & media',
      icon: Icons.play_arrow,
      color: Color(0xFF34A853),
      denominations: [10, 25, 50, 100],
    ),
    GiftCard(
      id: 'amazon',
      brand: 'Amazon',
      tagline: 'Shop everything',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFFFF9900),
      denominations: [25, 50, 100, 250],
    ),
    GiftCard(
      id: 'steam',
      brand: 'Steam',
      tagline: 'PC gaming wallet',
      icon: Icons.videogame_asset_outlined,
      color: Color(0xFF1B2838),
      denominations: [20, 50, 100],
    ),
    GiftCard(
      id: 'playstation',
      brand: 'PlayStation',
      tagline: 'PSN store credit',
      icon: Icons.sports_esports_outlined,
      color: Color(0xFF003791),
      denominations: [20, 50, 100],
    ),
    GiftCard(
      id: 'xbox',
      brand: 'Xbox',
      tagline: 'Microsoft store credit',
      icon: Icons.sports_esports,
      color: Color(0xFF107C10),
      denominations: [25, 50, 100],
    ),
    GiftCard(
      id: 'netflix',
      brand: 'Netflix',
      tagline: 'Stream subscription',
      icon: Icons.movie_outlined,
      color: Color(0xFFE50914),
      denominations: [30, 60],
    ),
    GiftCard(
      id: 'spotify',
      brand: 'Spotify',
      tagline: 'Premium music',
      icon: Icons.audiotrack,
      color: Color(0xFF1DB954),
      denominations: [10, 30, 60],
    ),
  ];
}
