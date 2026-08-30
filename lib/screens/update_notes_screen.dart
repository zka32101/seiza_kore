import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/update_notes_data.dart';
import '../providers/update_notes_provider.dart';

class UpdateNotesScreen extends ConsumerStatefulWidget {
  const UpdateNotesScreen({super.key});

  @override
  ConsumerState<UpdateNotesScreen> createState() => _UpdateNotesScreenState();
}

class _UpdateNotesScreenState extends ConsumerState<UpdateNotesScreen> {
  @override
  void initState() {
    super.initState();
    // 開いたら「未読の更新」を既読にする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hasUnseenUpdateProvider.notifier).markSeen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更新履歴'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: updateNotes.length,
        itemBuilder: (context, index) {
          final note = updateNotes[index];
          final isLatest = index == 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'v${note.version}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (isLatest) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '最新',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        note.date,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...note.highlights.map(
                    (h) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(h, style: const TextStyle(height: 1.4)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
