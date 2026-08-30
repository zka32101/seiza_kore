enum FeedbackCategory { bug, request, other }

extension FeedbackCategoryLabel on FeedbackCategory {
  String get label {
    switch (this) {
      case FeedbackCategory.bug:
        return '不具合報告';
      case FeedbackCategory.request:
        return '改善要望';
      case FeedbackCategory.other:
        return 'その他';
    }
  }

  String get emoji {
    switch (this) {
      case FeedbackCategory.bug:
        return '🐛';
      case FeedbackCategory.request:
        return '💡';
      case FeedbackCategory.other:
        return '💬';
    }
  }
}

class FeedbackItem {
  final String id;
  final FeedbackCategory category;
  final String title;
  final String detail;
  final DateTime createdAt;

  const FeedbackItem({
    required this.id,
    required this.category,
    required this.title,
    required this.detail,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as String,
      category: FeedbackCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FeedbackCategory.other,
      ),
      title: json['title'] as String,
      detail: json['detail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'title': title,
    'detail': detail,
    'createdAt': createdAt.toIso8601String(),
  };
}
