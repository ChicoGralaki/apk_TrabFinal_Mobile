import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/agenda_repository.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.user,
    required this.snapshot,
    required this.onSync,
  });
  final User user;
  final AgendaSnapshot snapshot;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
    children: [
      Text(
        'Meu perfil',
        style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 20),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.soft,
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : 'Bruxo(a)',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                user.email ?? '',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Card(
        child: ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Estado da sincronização'),
          subtitle: Text(
            snapshot.pendingCount == 0
                ? 'Tudo sincronizado'
                : '${snapshot.pendingCount} operação(ões) aguardando envio',
          ),
          trailing: IconButton(
            tooltip: 'Tentar sincronizar',
            onPressed: onSync,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () async {
          await AuthService().signOut();
        },
        icon: const Icon(Icons.logout),
        label: const Text('Encerrar sessão'),
      ),
    ],
  );
}
