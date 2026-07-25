import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/timecapsule_provider.dart';
import '../providers/constellation_time_capsule_provider.dart';
import '../models/timecapsule_event.dart';
import '../models/constellation_time_capsule.dart';

class TimecapsuleScreen extends ConsumerWidget {
  const TimecapsuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvents = ref.watch(activeEventsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final pastEvents = ref.watch(pastEventsProvider);
    final myRecords = ref.watch(timecapsuleRecordListProvider);
    final allEvents = ref.watch(timecapsuleEventsProvider);

    // Constellation Time Capsule data
    final activeCapsules = ref.watch(activeConstellationCapsuleProvider);
    final upcomingCapsules = ref.watch(upcomingConstellationCapsuleProvider);
    final capsuleStats = ref.watch(constellationCapsuleStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⏰ タイムカプセル天体'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header explanation
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '特定の天文イベント期間中のみ解放される特別なページです。見逃したら来年までお預け！',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active events
            if (activeEvents.isNotEmpty) ...[
              _SectionHeader('🔓 今すぐ観測できる！', color: Colors.green),
              const SizedBox(height: 8),
              ...activeEvents.map(
                (e) => _ActiveEventCard(event: e),
              ),
              const SizedBox(height: 24),
            ],

            // Upcoming events
            if (upcomingEvents.isNotEmpty) ...[
              _SectionHeader('📅 もうすぐ解放', color: Colors.orange),
              const SizedBox(height: 8),
              ...upcomingEvents.map(
                (e) => _UpcomingEventCard(event: e),
              ),
              const SizedBox(height: 24),
            ],

            // Past events
            if (pastEvents.isNotEmpty) ...[
              _SectionHeader('📁 過去のイベント', color: Colors.grey),
              const SizedBox(height: 8),
              ...pastEvents.map(
                (e) => _PastEventCard(event: e),
              ),
            ],

            if (activeEvents.isEmpty &&
                upcomingEvents.isEmpty &&
                pastEvents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: Text('イベントデータがありません'),
                ),
              ),

            // My records
            if (myRecords.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader('📖 自分の記録', color: Colors.blue),
              const SizedBox(height: 8),
              ...myRecords.reversed.map(
                (r) => _MyRecordCard(record: r, events: allEvents),
              ),
            ],

            // Constellation Time Capsules
            const SizedBox(height: 32),
            _SectionHeader('🌟 星座タイムカプセル', color: Colors.purple),
            const SizedBox(height: 8),
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${capsuleStats.total}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('保存中', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${capsuleStats.unlocked}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('解放済み', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${capsuleStats.upcoming}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('待機中', style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '観測した星座を未来に預けて、指定した日付に思い出と共に解放します。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (activeCapsules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader('🔓 今すぐ見られる', color: Colors.green),
              const SizedBox(height: 8),
              ...activeCapsules.map((c) => _ConstellationCapsuleCard(capsule: c)),
            ],
            if (upcomingCapsules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader('⏳ 待機中の星座', color: Colors.orange),
              const SizedBox(height: 8),
              ...upcomingCapsules.map((c) => _ConstellationCapsuleCard(capsule: c)),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
    );
  }
}

class _ActiveEventCard extends ConsumerWidget {
  final TimecapsuleEvent event;
  const _ActiveEventCard({required this.event});

  Future<void> _showRecordDialog(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RecordDialog(event: event),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursLeft = event.closeTime.difference(DateTime.now()).inHours;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.green, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(event.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '解放中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '残り$hoursLeft時間',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRecordDialog(context, ref),
                    icon: const Icon(Icons.edit_note),
                    label: const Text('観測を記録する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEventCard extends StatelessWidget {
  final TimecapsuleEvent event;
  const _UpcomingEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final daysLeft = event.daysUntilOpen;
    final dateStr =
        '${event.openTime.month}月${event.openTime.day}日〜${event.closeTime.month}月${event.closeTime.day}日';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      event.emoji,
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.grey.withAlpha(100),
                      ),
                    ),
                    Icon(
                      Icons.lock,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                // Countdown badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$daysLeft',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        '日後',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Progress bar for countdown
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progressToOpen(event),
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Colors.orange.shade400),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'あと$daysLeftLabel（${_formatDate(event.openTime)}）に解放されます',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String get daysLeftLabel {
    final d = event.daysUntilOpen;
    return '$d日';
  }

  double _progressToOpen(TimecapsuleEvent event) {
    const totalDays = 365;
    final daysLeft = event.daysUntilOpen;
    return ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0);
  }

  String _formatDate(DateTime dt) =>
      '${dt.month}/${dt.day}';
}

class _RecordDialog extends ConsumerStatefulWidget {
  final TimecapsuleEvent event;
  const _RecordDialog({required this.event});

  @override
  ConsumerState<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends ConsumerState<_RecordDialog> {
  final _notesController = TextEditingController();
  int _meteorCount = 10;
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final record = TimecapsuleRecord(
      id: 'tc_${DateTime.now().millisecondsSinceEpoch}',
      eventId: widget.event.id,
      observedAt: DateTime.now(),
      meteorCount: _meteorCount,
      notes: _notesController.text,
      photoUrls: const [],
    );
    await ref.read(timecapsuleRecordListProvider.notifier).addRecord(record);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.event.name}の観測を記録しました！'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMeteor = widget.event.type == TimecapsuleEventType.meteor;
    return AlertDialog(
      title: Row(
        children: [
          Text(widget.event.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.event.name,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMeteor) ...[
              const Text(
                '見た流れ星の数',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _meteorCount.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '$_meteorCount個',
                      activeColor: Colors.green,
                      onChanged: (v) =>
                          setState(() => _meteorCount = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '$_meteorCount個',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              '観測メモ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '今夜の特別な体験を記録しよう...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('記録する'),
        ),
      ],
    );
  }
}

class _MyRecordCard extends StatelessWidget {
  final TimecapsuleRecord record;
  final List<TimecapsuleEvent> events;
  const _MyRecordCard({required this.record, required this.events});

  @override
  Widget build(BuildContext context) {
    final event = events.where((e) => e.id == record.eventId).firstOrNull;
    final dateStr =
        '${record.observedAt.year}/${record.observedAt.month.toString().padLeft(2, '0')}/${record.observedAt.day.toString().padLeft(2, '0')} '
        '${record.observedAt.hour.toString().padLeft(2, '0')}:${record.observedAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              event?.emoji ?? '⭐',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event?.name ?? record.eventId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  if (record.meteorCount > 0)
                    Text(
                      '流れ星: ${record.meteorCount}個',
                      style: TextStyle(
                        color: Colors.amber.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (record.notes.isNotEmpty)
                    Text(
                      record.notes,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }
}

class _PastEventCard extends StatelessWidget {
  final TimecapsuleEvent event;
  const _PastEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${event.openTime.year}年${event.openTime.month}月${event.openTime.day}日';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey.shade100,
      child: ListTile(
        leading: Text(
          event.emoji,
          style: TextStyle(
            fontSize: 28,
            color: Colors.grey.withAlpha(150),
          ),
        ),
        title: Text(
          event.name,
          style: TextStyle(color: Colors.grey.shade700),
        ),
        subtitle: Text(
          dateStr,
          style: TextStyle(color: Colors.grey.shade500),
        ),
        trailing: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('過去の記録を表示（プレミアム機能）')),
            );
          },
          child: const Text('記録を見る'),
        ),
      ),
    );
  }
}

class _ConstellationCapsuleCard extends StatelessWidget {
  final ConstellationTimeCapsule capsule;
  const _ConstellationCapsuleCard({required this.capsule});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: capsule.isUnlocked ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              capsule.emoji,
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capsule.constellationName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '保存: ${DateFormat('y/M/d').format(capsule.recordedAt)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  Text(
                    '解放: ${capsule.getFormattedReleaseDate()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: capsule.isUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (capsule.message.isNotEmpty)
                    Text(
                      capsule.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  capsule.getReleaseStatus(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: capsule.isUnlocked ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Icon(
                  capsule.isUnlocked ? Icons.lock_open : Icons.lock_clock,
                  color: capsule.isUnlocked ? Colors.green : Colors.orange,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
