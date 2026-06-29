import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/observation_provider.dart';
import '../providers/constellation_provider.dart';
import '../models/observation.dart';
import '../models/constellation.dart';
import '../services/bortle_service.dart';
import '../widgets/unlock_celebration.dart';

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

  final List<String> _weatherOptions = [
    '晴れ', '薄曇り', '曇り', '快晴',
  ];

  @override
  void initState() {
    super.initState();
    _bortle = widget.initialBortle;
    _locationController.text = '（現在地取得中...）';
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
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
          ? '場所未設定'
          : _locationController.text,
      bortleScale: _bortle,
      weather: _weather,
      notes: _notesController.text,
      photoUrls: [],
    );

    await ref.read(observationListProvider.notifier).addObservation(obs);
    await ref.read(unlockedIdsProvider.notifier).unlock(widget.constellationId);

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
        const SnackBar(
          content: Text('観測記録を保存しました！'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final constellationAsync =
        ref.watch(constellationByIdProvider(widget.constellationId));
    final bortleInfo = BortleService.instance.getBortleInfo(_bortle);

    return Scaffold(
      appBar: AppBar(
        title: const Text('観測記録を追加'),
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
                : const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        title: Text(c.nameJa,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        subtitle: Text(c.nameEn),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Bortle scale (City Light Challenge)
            _SectionLabel('シティ・ライト・チャレンジ（光害スケール）'),
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
                          'Bortle $_bortle: ${bortleInfo.label}',
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
                      bortleInfo.description,
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
                        Text('1\n暗い',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                        Text('5\n郊外',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelSmall),
                        Text('9\n都市',
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
                                '都市部でのレア観測！高難易度クリアで称号「シティハンター」に近づく',
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
            _SectionLabel('観測場所'),
            const SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: '例: 東京都新宿区、長野県諏訪市',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Weather
            _SectionLabel('天気'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _weatherOptions.map((w) {
                return ChoiceChip(
                  label: Text(w),
                  selected: _weather == w,
                  onSelected: (_) => setState(() => _weather = w),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Notes
            _SectionLabel('メモ'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '今夜の観測の感想や気づいたことを書こう...',
                border: OutlineInputBorder(),
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
                label: const Text(
                  '記録を保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

