import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/repositories/business_repository.dart';
import 'data/services/mock_business_service.dart';
import 'router.dart';
import 'ui/core/session_view_model.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/features/home/view_models/home_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(
    MultiProvider(
      providers: [
        Provider<MockBusinessService>(create: (_) => MockBusinessService()),
        Provider<BusinessRepository>(
          create: (c) => MockBusinessRepository(service: c.read<MockBusinessService>()),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (c) => HomeViewModel(repository: c.read<BusinessRepository>()),
        ),
        ChangeNotifierProvider<SessionViewModel>(create: (_) => SessionViewModel()),
      ],
      child: const MarketApp(),
    ),
  );
}

class MarketApp extends StatefulWidget {
  const MarketApp({super.key});

  @override
  State<MarketApp> createState() => _MarketAppState();
}

class _MarketAppState extends State<MarketApp> {
  late final GoRouter _router = buildRouter(
    homeViewModel: context.read<HomeViewModel>(),
    session: context.read<SessionViewModel>(),
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MARKet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
