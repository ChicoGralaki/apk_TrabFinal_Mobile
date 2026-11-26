import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../app_shell.dart';
import '../home_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) return const _FirebaseSetupPage();
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) return const _FirebaseSetupPage();
        final user = snapshot.data;
        return user == null
            ? const LoginPage()
            : AppShell(key: ValueKey(user.uid), user: user);
      },
    );
  }
}

class _FirebaseSetupPage extends StatelessWidget {
  const _FirebaseSetupPage();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 42,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Conclua a configuração do Firebase',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'O app Android deve ser registrado no projeto Firebase apk-auth-joaofgralaki com o applicationId com.hogwarts.explorer.hogwarts_explorer. Em seguida, gere lib/services/firebase_options.dart com FlutterFire CLI. Veja SETUP_FIREBASE.md.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'A autenticação e a agenda em nuvem ficam indisponíveis até essa configuração ser feita.',
                      style: TextStyle(color: AppColors.muted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomePage(showLogin: true),
                        ),
                      ),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Continuar explorando'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
