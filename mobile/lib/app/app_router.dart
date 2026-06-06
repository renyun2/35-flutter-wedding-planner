import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/bookings/presentation/booking_create_page.dart';
import '../../features/bookings/presentation/bookings_page.dart';
import '../../features/budget/presentation/budget_add_page.dart';
import '../../features/budget/presentation/budget_items_page.dart';
import '../../features/budget/presentation/budget_page.dart';
import '../../features/contracts/presentation/contracts_page.dart';
import '../../features/guests/presentation/guest_create_page.dart';
import '../../features/guests/presentation/guests_page.dart';
import '../../features/guests/presentation/seating_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/inspirations/presentation/inspirations_page.dart';
import '../../features/messages/presentation/messages_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/tasks/presentation/tasks_page.dart';
import '../../features/timeline/presentation/timeline_page.dart';
import '../../features/vendors/presentation/vendor_detail_page.dart';
import '../../features/vendors/presentation/vendors_page.dart';
import '../../features/venues/presentation/venue_detail_page.dart';
import '../../features/venues/presentation/venue_inquiry_page.dart';
import '../../features/venues/presentation/venues_page.dart';
import '../../features/wedding/presentation/wedding_create_page.dart';
import '../../features/wedding/presentation/wedding_date_page.dart';
import 'router_refresh.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = RouterRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final authed = auth != null;
      final loc = state.matchedLocation;
      const publicRoutes = ['/splash', '/login'];
      const weddingOptional = ['/wedding/create'];

      if (publicRoutes.contains(loc)) {
        if (authed && loc == '/login') {
          return auth.user.hasWedding ? '/home' : '/wedding/create';
        }
        return null;
      }

      if (!authed) return '/login';

      if (!auth.user.hasWedding && !weddingOptional.contains(loc)) {
        return '/wedding/create';
      }

      if (auth.user.hasWedding && loc == '/wedding/create') return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/wedding/create', builder: (_, __) => const WeddingCreatePage()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/budget', builder: (_, __) => const BudgetPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/vendors', builder: (_, __) => const VendorsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/guests', builder: (_, __) => const GuestsPage()),
          ]),
        ],
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/wedding/date', builder: (_, __) => const WeddingDatePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/budget/items', builder: (_, __) => const BudgetItemsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/budget/add', builder: (_, __) => const BudgetAddPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/venues', builder: (_, __) => const VenuesPage()),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/venue/:id',
        builder: (_, s) => VenueDetailPage(venueId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/venue/:id/inquiry',
        builder: (_, s) => VenueInquiryPage(venueId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/vendor/:id',
        builder: (_, s) => VendorDetailPage(vendorId: s.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/booking/create',
        builder: (_, s) => BookingCreatePage(vendorId: s.uri.queryParameters['vendorId']),
      ),
      GoRoute(parentNavigatorKey: _rootKey, path: '/bookings', builder: (_, __) => const BookingsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/guest/create', builder: (_, __) => const GuestCreatePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/seating', builder: (_, __) => const SeatingPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/tasks', builder: (_, __) => const TasksPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/timeline', builder: (_, __) => const TimelinePage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/inspirations', builder: (_, __) => const InspirationsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/contracts', builder: (_, __) => const ContractsPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/messages', builder: (_, __) => const MessagesPage()),
      GoRoute(parentNavigatorKey: _rootKey, path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});
