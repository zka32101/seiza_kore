import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/timecapsule_provider.dart';
import '../providers/constellation_time_capsule_provider.dart';
import '../models/timecapsule_event.dart';
import '../models/constellation_time_capsule.dart';
import '../l10n/generated/app_localizations.dart';

class TimecapsuleScreen extends ConsumerWidget {
  const TimecapsuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
        title: Text(l10n.timecapsuleTitle),
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
                        l10n.timecapsuleHeaderExplanation,
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
              _SectionHeader(l10n.timecapsuleSectionActiveNow, color: Colors.green),
              const SizedBox(height: 8),
              ...activeEvents.map(
                (e) => _ActiveEventCard(event: e),
              ),
              const SizedBox(height: 24),
            ],

            // Upcoming events
            if (upcomingEvents.isNotEmpty) ...[
              _SectionHeader(l10n.timecapsuleSectionUpcoming, color: Colors.orange),
              const SizedBox(height: 8),
              ...upcomingEvents.map(
                (e) => _UpcomingEventCard(event: e),
              ),
              const SizedBox(height: 24),
            ],

            // Past events
            if (pastEvents.isNotEmpty) ...[
              _SectionHeader(l10n.timecapsuleSectionPast, color: Colors.grey),
              const SizedBox(height: 8),
              ...pastEvents.map(
                (e) => _PastEventCard(event: e),
              ),
            ],

            if (activeEvents.isEmpty &&
                upcomingEvents.isEmpty &&
                pastEvents.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Text(l10n.timecapsuleNoEventData),
                ),
              ),

            // My records
            if (myRecords.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(l10n.timecapsuleSectionMyRecords, color: Colors.blue),
              const SizedBox(height: 8),
              ...myRecords.reversed.map(
                (r) => _MyRecordCard(record: r, events: allEvents),
              ),
            ],

            // Constellation Time Capsules
            const SizedBox(height: 32),
            _SectionHeader(l10n.timecapsuleSectionConstellationCapsule, color: Colors.purple),
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
                            Text(l10n.timecapsuleStatSaved, style: Theme.of(context).textTheme.labelSmall),
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
                            Text(l10n.timecapsuleStatUnlocked, style: Theme.of(context).textTheme.labelSmall),
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
                            Text(l10n.timecapsuleStatWaiting, style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.timecapsuleCapsuleDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (activeCapsules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(l10n.timecapsuleSectionCapsuleActiveNow, color: Colors.green),
              const SizedBox(height: 8),
              ...activeCapsules.map((c) => _ConstellationCapsuleCard(capsule: c)),
            ],
            if (upcomingCapsules.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(l10n.timecapsuleSectionCapsuleWaiting, color: Colors.orange),
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
    final l10n = AppLocalizations.of(context)!;
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
                            child: Text(
                              l10n.timecapsuleBadgeActive,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.timecapsuleHoursLeft(hoursLeft),
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
                    label: Text(l10n.timecapsuleRecordButton),
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
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final daysLeft = event.daysUntilOpen;
    final dateStr = l10n.timecapsuleDateRange(
      DateFormat.MMMd(lang).format(event.openTime),
      DateFormat.MMMd(lang).format(event.closeTime),
    );

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
                        l10n.timecapsuleDaysUnit,
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
              l10n.timecapsuleUnlocksIn(
                daysLeft,
                DateFormat.MMMd(lang).format(event.openTime),
              ),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  double _progressToOpen(TimecapsuleEvent event) {
    const totalDays = 365;
    final daysLeft = event.daysUntilOpen;
    return ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0);
  }
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
    final l10n = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.timecapsuleRecordSaved(widget.event.name)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.timecapsuleMeteorCountLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                      label: l10n.timecapsuleMeteorCountValue(_meteorCount),
                      activeColor: Colors.green,
                      onChanged: (v) =>
                          setState(() => _meteorCount = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(
                      l10n.timecapsuleMeteorCountValue(_meteorCount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Text(
              l10n.timecapsuleNotesLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.timecapsuleNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
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
              : Text(l10n.timecapsuleSaveRecord),
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
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.timecapsuleMeteorCountRecord(record.meteorCount),
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
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat.yMMMMd(lang).format(event.openTime);

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
              SnackBar(content: Text(l10n.timecapsulePastRecordPremium)),
            );
          },
          child: Text(l10n.timecapsuleViewRecord),
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
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
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
                    l10n.timecapsuleSavedLabel(
                      DateFormat.yMd(lang).format(capsule.recordedAt),
                    ),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  Text(
                    l10n.timecapsuleReleaseLabel(capsule.getFormattedReleaseDate()),
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
