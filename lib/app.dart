import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_provider.dart';
import 'services/profile_provider.dart';
import 'services/discovery_provider.dart';
import 'services/request_provider.dart';
import 'services/chat_provider.dart';
import 'services/rating_provider.dart';
import 'services/leaderboard_provider.dart';
import 'services/theme_provider.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/profile/create_profile_screen.dart';
import 'presentation/profile/profile_view_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadSavedTheme(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'SkillSwap',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: child,
                    ),
                  );
                },
              );
            },
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Decides which screen to show: login, profile setup, or profile view.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _loadedForUid;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileState = context.watch<ProfileProvider>();

    if (!auth.isLoggedIn) {
      _loadedForUid = null;
      return const LoginScreen();
    }

    if (_loadedForUid != auth.user!.uid) {
      _loadedForUid = auth.user!.uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileProvider>().loadProfile(auth.user!.uid);
      });
    }

    if (!profileState.hasChecked || profileState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return profileState.hasProfile
        ? const ProfileViewScreen()
        : const CreateProfileScreen();
  }
}
