import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repositories/agenda_repository.dart';
import 'agenda/agenda_page.dart';
import 'calendar/calendar_page.dart';
import 'home_page.dart';
import 'profile/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.user});
  final User user;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final _repository = AgendaRepository();
  StreamSubscription<AgendaSnapshot>? _subscription;
  AgendaSnapshot _snapshot = const AgendaSnapshot([], 0, false, false);
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _repository.changes.listen((value) {
      if (mounted) setState(() => _snapshot = value);
    });
    unawaited(_repository.connect(widget.user.uid));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_repository.synchronize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    unawaited(_repository.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(
        index: _tab,
        children: [
          const HomePage(),
          AgendaPage(repository: _repository, snapshot: _snapshot),
          CalendarPage(repository: _repository, snapshot: _snapshot),
          ProfilePage(user: widget.user, snapshot: _snapshot, onSync: _sync),
        ],
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: 'Explorar',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_outlined),
          selectedIcon: Icon(Icons.event_note),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Calendário',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ),
  );

  Future<void> _sync() async {
    final result = await _repository.synchronize();
    if (!mounted) return;
    final text = result.failed > 0
        ? 'Algumas alterações continuam pendentes. Confira a conexão e tente novamente.'
        : result.synced > 0
        ? '${result.synced} alteração(ões) sincronizada(s).'
        : _snapshot.pendingCount > 0
        ? 'Sem confirmação do Firestore. As alterações continuam pendentes.'
        : 'Tudo atualizado.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
