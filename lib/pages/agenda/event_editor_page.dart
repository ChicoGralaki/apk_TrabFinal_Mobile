import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/agenda_event_model.dart';
import '../../repositories/agenda_repository.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';

class EventEditorPage extends StatefulWidget {
  const EventEditorPage({
    super.key,
    required this.repository,
    this.initialDate,
    this.existing,
  });
  final AgendaRepository repository;
  final DateTime? initialDate;
  final AgendaEvent? existing;
  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = LocationService();
  late DateTime _eventAt;
  String? _imagePath;
  double? _latitude;
  double? _longitude;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final event = widget.existing;
    _title.text = event?.title ?? '';
    _description.text = event?.description ?? '';
    _eventAt = event?.eventAt ?? widget.initialDate ?? DateTime.now();
    _imagePath = event?.imagePath;
    _latitude = event?.latitude;
    _longitude = event?.longitude;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _eventAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventAt),
    );
    if (time != null) {
      setState(
        () => _eventAt = DateTime(
          day.year,
          day.month,
          day.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final path = await widget.repository.imageStore.pickAndStore(
        source: source,
      );
      if (path != null && mounted) setState(() => _imagePath = path);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível selecionar a imagem.');
      }
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final location = await _location.currentLocation();
      if (mounted) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
        });
      }
    } on LocationServiceException catch (error) {
      if (mounted) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.repository.save(
        title: _title.text,
        description: _description.text,
        eventAt: _eventAt,
        imagePath: _imagePath,
        latitude: _latitude,
        longitude: _longitude,
        existing: widget.existing,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'O evento foi salvo localmente. A sincronização tentará novamente quando a conexão estiver disponível.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.existing == null ? 'Novo evento' : 'Editar evento'),
    ),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Informe um título.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event, color: AppColors.primary),
                title: const Text('Data e hora'),
                subtitle: Text(
                  DateFormat(
                    'EEEE, d MMMM yyyy · HH:mm',
                    'pt_BR',
                  ).format(_eventAt),
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _busy ? null : _chooseDate,
              ),
            ),
            const SizedBox(height: 12),
            if (_imagePath != null && File(_imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(_imagePath!),
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(
                      _imagePath == null ? 'Escolher imagem' : 'Trocar imagem',
                    ),
                  ),
                ),
                if (_imagePath != null)
                  IconButton(
                    tooltip: 'Remover imagem',
                    onPressed: () => setState(() => _imagePath = null),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: _busy ? null : _getLocation,
              icon: const Icon(Icons.my_location),
              label: Text(
                _latitude == null
                    ? 'Anexar localização atual'
                    : 'Atualizar localização',
              ),
            ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude ${_latitude!.toStringAsFixed(6)} · Longitude ${_longitude!.toStringAsFixed(6)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '~${_location.distanceFromHogwartsKm(DeviceLocation(_latitude!, _longitude!)).toStringAsFixed(0)} km de Hogwarts (linha reta; referência: Castelo de Alnwick)',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _busy ? null : _save,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_busy ? 'Salvando...' : 'Salvar evento'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );
}
