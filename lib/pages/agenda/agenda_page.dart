import 'package:flutter/material.dart';

import '../../repositories/agenda_repository.dart';
import '../../theme/app_theme.dart';
import 'agenda_widgets.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({
    super.key,
    required this.repository,
    required this.snapshot,
  });
  final AgendaRepository repository;
  final AgendaSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Agenda Mágica'),
      actions: [
        IconButton(
          tooltip: 'Adicionar evento',
          onPressed: () => openEventEditor(context, repository),
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const Text(
          'Seus eventos ficam neste dispositivo primeiro e são enviados quando a nuvem confirmar.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        SyncStatusCard(
          snapshot: snapshot,
          onSync: () => repository.synchronize(),
        ),
        const SizedBox(height: 18),
        if (snapshot.events.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(26),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 38,
                    color: AppColors.gold,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sua agenda está vazia',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Adicione um evento para começar.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          )
        else
          ...snapshot.events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AgendaEventCard(
                event: event,
                repository: repository,
                onChanged: () => repository.refresh(),
              ),
            ),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => openEventEditor(context, repository),
      icon: const Icon(Icons.add),
      label: const Text('Novo evento'),
    ),
  );
}
