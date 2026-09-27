import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Phase 1: Auth screens
    GoRoute(
      path: '/splash',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Splash'))),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => Scaffold(body: Center(child: Text('Login'))),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Signup'))),
    ),

    // Phase 2: Profile
    GoRoute(
      path: '/profile',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Profile'))),
    ),

    // Phase 3: Discovery
    GoRoute(
      path: '/discover',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Discover'))),
    ),

    // Phase 4: Requests
    GoRoute(
      path: '/requests',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Requests'))),
    ),

    // Phase 5: Chat
    GoRoute(
      path: '/chat',
      builder: (context, state) => Scaffold(body: Center(child: Text('Chat'))),
    ),
    GoRoute(
      path: '/chat/:userId',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Conversation'))),
    ),

    // Phase 6 & 7: Leaderboard
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Leaderboard'))),
    ),

    // Placeholder for other phases
    GoRoute(
      path: '/credits',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Credits'))),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) =>
          Scaffold(body: Center(child: Text('Settings'))),
    ),
  ],
);
