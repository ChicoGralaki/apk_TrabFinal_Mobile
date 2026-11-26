import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/agenda_event_model.dart';
import '../../repositories/agenda_repository.dart';
import '../../theme/app_theme.dart';
import 'event_editor_page.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    super.key,
    required this.snapshot,
    required this.onSync,
  });
  final AgendaSnapshot snapshot;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final pending = snapshot.pendingCount;
    final icon = snapshot.isSyncing
        ? Icons.sync
        : snapshot.hasFailures
        ? Icons.sync_problem
        : pending > 0
        ? Icons.cloud_upload_outlined
        : Icons.cloud_done_outlined;
    final label = snapshot.isSyncing
        ? 'Sincronizando...'
        : snapshot.hasFailures
        ? 'Falha ao sincronizar'
        : pending > 0
        ? 'Aguardando sincronização · $pending'
        : 'Sincronizado';
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          children: [
            Icon(
              icon,
              color: snapshot.hasFailures
                  ? AppColors.error
                  : AppColors.primaryLight,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              tooltip: 'Tentar novamente',
              onPressed: onSync,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}

class AgendaEventCard extends StatelessWidget {
  const AgendaEventCard({
    super.key,
    required this.event,
    required this.repository,
    required this.onChanged,
  });
  final AgendaEvent event;
  final AgendaRepository repository;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imagePath != null && File(event.imagePath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(event.imagePath!),
                width: 66,
                height: 66,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.gold),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'EEE, d MMM · HH:mm',
                    'pt_BR',
                  ).format(event.eventAt),
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                if (event.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      event.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (event.latitude != null && event.longitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '📍 ${event.latitude!.toStringAsFixed(4)}, ${event.longitude!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    event.isSynced ? 'Na nuvem' : 'Pendente neste dispositivo',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EventEditorPage(
                      repository: repository,
                      existing: event,
                    ),
                  ),
                );
                onChanged();
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir evento?'),
                    content: const Text(
                      'Esta ação será sincronizada com a nuvem quando houver conexão.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await repository.delete(event);
                  onChanged();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<void> openEventEditor(
  BuildContext context,
  AgendaRepository repository, {
  DateTime? date,
  AgendaEvent? event,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EventEditorPage(
        repository: repository,
        initialDate: date,
        existing: event,
      ),
    ),
  );
}
