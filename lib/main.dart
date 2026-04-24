import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app/word_puzzle_app.dart';
import 'widgets/end_interstitial_ad.dart';
import 'services/daily_progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordPuzzleApp());
  unawaited(MobileAds.instance.initialize());
  unawaited(Future<void>.delayed(const Duration(milliseconds: 500), EndInterstitialAd.preload));
  unawaited(DailyProgressService.instance.initialize());
}
