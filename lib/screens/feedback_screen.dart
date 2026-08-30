import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/feedback_item.dart';
import '../providers/feedback_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  FeedbackCategory _category = FeedbackCategory.request;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final detail = _detailController.text.trim();
    if (title.isEmpty || detail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと内容を入力してください')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await ref.read(feedbackListProvider.notifier).submit(
          category: _category,
          title: title,
          detail: detail,
        );
    if (!mounted) return;

    _titleController.clear();
    _detailController.clear();
    setState(() {
      _isSubmitting = false;
      _category = FeedbackCategory.request;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('送信しました。ご協力ありがとうございます！'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(feedbackListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ご意見・不具合報告'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'アプリの改善に役立てます。気づいたことを気軽に送ってください。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 16),

          _SectionLabel('種類'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: FeedbackCategory.values.map((c) {
              return ChoiceChip(
                label: Text('${c.emoji} ${c.label}'),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          _SectionLabel('タイトル'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '例: AR観測画面がクラッシュする',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          _SectionLabel('詳細'),
          const SizedBox(height: 8),
          TextField(
            controller: _detailController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '状況や再現手順、要望の背景などを書いてください',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: const Text(
                '送信する',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          if (items.isNotEmpty) ...[
            const SizedBox(height: 32),
            _SectionLabel('これまでの送信 (${items.length}件)'),
            const SizedBox(height: 8),
            ...items.map((item) => _FeedbackTile(item: item)),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeedbackTile extends StatelessWidget {
  final FeedbackItem item;
  const _FeedbackTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(item.category.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          item.detail,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('M/d').format(item.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              '送信済み',
              style: TextStyle(fontSize: 10, color: Colors.green.shade600),
            ),
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
