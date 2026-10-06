import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../providers/co_observation_provider.dart';
import '../models/observation.dart';
import '../models/constellation.dart';
import '../services/bortle_service.dart';
import '../services/photo_import_service.dart';
import '../widgets/unlock_celebration.dart';
import '../l10n/generated/app_localizations.dart';

class AddObservationScreen extends ConsumerStatefulWidget {
  final String constellationId;
  final int initialBortle;

  const AddObservationScreen({
    super.key,
    required this.constellationId,
    this.initialBortle = 5,
  });

  @override
  ConsumerState<AddObservationScreen> createState() =>
      _AddObservationScreenState();
}

class _AddObservationScreenState
    extends ConsumerState<AddObservationScreen> {
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  int _bortle = 5;
  String _weather = '晴れ';
  bool _isSaving = false;
  bool _locationInitialized = false;
  bool _isImportingPhotos = false;
  final List<String> _photoPaths = [];

  final List<String> _weatherOptions = weatherOptions;

  String _weatherLabel(String value, String languageCode) =>
      languageCode == 'en' ? (weatherLabelsEn[value] ?? value) : value;

  @override
  void initState() {
    super.initState();
    _bortle = widget.initialBortle;
    startCoObserving(ref, widget.constellationId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_locationInitialized) {
      _locationInitialized = true;
      _locationController.text = AppLocalizations.of(context)!.addObsFetchingLocation;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    stopCoObserving(ref);
    super.dispose();
  }

  Future<void> _importPhotos() async {
    setState(() => _isImportingPhotos = true);
    try {
      final paths = await PhotoImportService.instance.pickAndImportPhotos();
      if (mounted && paths.isNotEmpty) {
        setState(() => _photoPaths.addAll(paths));
      }
    } finally {
      if (mounted) setState(() => _isImportingPhotos = false);
    }
  }

  void _removePhoto(int index) {
    setState(() => _photoPaths.removeAt(index));
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);

    final isNewUnlock =
        !ref.read(unlockedIdsProvider).contains(widget.constellationId);
    final constellation =
        ref.read(constellationByIdProvider(widget.constellationId)).value;

    final obs = Observation(
      id: 'obs_${DateTime.now().millisecondsSinceEpoch}',
      constellationId: widget.constellationId,
      timestamp: DateTime.now(),
      locationName: _locationController.text.isEmpty
          ? l10n.addObsNoLocationSet
          : _locationController.text,
      bortleScale: _bortle,
      weather: _weather,
      notes: _notesController.text,
      photoUrls: _photoPaths,
    );

    await ref.read(observationListProvider.notifier).addObservation(obs);
    await ref.read(unlockedIdsProvider.notifier).unlock(widget.constellationId);
    await stopCoObserving(ref);

    if (!mounted) return;

    if (isNewUnlock && constellation != null) {
      await showUnlockCelebration(
        context,
        constellation: constellation,
        onViewDetail: () {
          if (mounted) context.push('/constellation/${constellation.id}');
        },
      );
    }

    if (!mounted) return;
    context.pop();

    if (!isNewUnlock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addObsSavedSnackbar),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final constellationAsync =
        ref.watch(constellationByIdProvider(widget.constellationId));
    final bortleInfo = BortleService.instance.getBortleInfo(_bortle);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addObsTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonSave, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Constellation header
            constellationAsync.when(
              data: (c) => c != null
                  ? Card(
                      child: ListTile(
                        leading: Text(c.emoji,
                            style: const TextStyle(fontSize: 32)),
                        title: Text(lang == 'en' ? c.nameEn : c.nameJa,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        subtitle: Text(lang == 'en' ? c.nameJa : c.nameEn),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Bortle scale (City Light Challenge)
            _SectionLabel(l10n.addObsBortleSectionTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.addObsBortleLabel(_bortle, bortleInfo.localizedLabel(lang)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '★' * bortleInfo.difficultyStars +
                              '☆' * (3 - bortleInfo.difficultyStars),
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bortleInfo.localizedDescription(lang),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    Slider(
                      value: _bortle.toDouble(),
                      min: 1,
                      max: 9,
                      divisions: 8,
                      label: 'Bortle $_bortle',
                      onChanged: (v) {
                        setState(() => _bortle = v.round());
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.addObsScaleDark,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                        Text(l10n.addObsScaleSuburb,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                        Text(l10n.addObsScaleCity,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    if (_bortle >= 7) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.addObsCityRareBadge,
                                style: TextStyle(
                                  color: Colors.amber.shade800,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Location
            _SectionLabel(l10n.addObsLocationSectionTitle),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: l10n.addObsLocationHint,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Weather
            _SectionLabel(l10n.addObsWeatherSectionTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _weatherOptions.map((w) {
                return ChoiceChip(
                  label: Text(_weatherLabel(w, lang)),
                  selected: _weather == w,
                  onSelected: (_) => setState(() => _weather = w),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Photos (望遠鏡等で撮影した写真のインポート)
            _SectionLabel(l10n.addObsPhotosSectionTitle),
            const SizedBox(height: 4),
            Text(
              l10n.addObsPhotosHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < _photoPaths.length; i++)
                  _PhotoThumbnail(
                    path: _photoPaths[i],
                    onRemove: () => _removePhoto(i),
                  ),
                _AddPhotoButton(
                  isLoading: _isImportingPhotos,
                  onTap: _isImportingPhotos ? null : _importPhotos,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes
            _SectionLabel(l10n.addObsNotesSectionTitle),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.addObsNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(
                  l10n.addObsSaveRecord,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;

  const _PhotoThumbnail({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(path),
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _AddPhotoButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.add_a_photo, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

