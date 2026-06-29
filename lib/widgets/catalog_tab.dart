import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/constellation_provider.dart';
import '../models/constellation.dart';

class CatalogTab extends ConsumerStatefulWidget {
  const CatalogTab({super.key});

  @override
  ConsumerState<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends ConsumerState<CatalogTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(catalogFilterProvider);
    final sort = ref.watch(catalogSortProvider);
    final constellationsAsync = ref.watch(filteredConstellationsProvider);
    final unlockedIds = ref.watch(unlockedIdsProvider);
    final favoriteIds = ref.watch(favoriteIdsProvider);

    return Column(
      children: [
        // Search bar + sort button
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '星座を検索...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(catalogSearchProvider.notifier).state =
                                  '';
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  onChanged: (v) =>
                      ref.read(catalogSearchProvider.notifier).state = v,
                ),
              ),
              const SizedBox(width: 8),
              _FilterButton(),
              const SizedBox(width: 4),
              _SortButton(currentSort: sort),
            ],
          ),
        ),

        // Category filter (with favorites)
        _CategoryFilter(selectedFilter: filter, favoriteCount: favoriteIds.length),

        // Progress bar
        constellationsAsync.when(
          data: (all) => _ProgressHeader(
            unlocked: unlockedIds.length,
            total: 88,
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Grid
        Expanded(
          child: constellationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
            data: (constellations) => constellations.isEmpty
                ? const _EmptySearchResult()
                : _ConstellationGrid(
                    constellations: constellations,
                    unlockedIds: unlockedIds,
                    favoriteIds: favoriteIds,
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends ConsumerWidget {
  const _FilterButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minDiff = ref.watch(catalogMinDifficultyProvider);
    final maxDiff = ref.watch(catalogMaxDifficultyProvider);
    final visibility = ref.watch(catalogVisibilityProvider);
    final unlockedFilter = ref.watch(catalogUnlockedFilterProvider);

    final hasAdvancedFilter =
        minDiff > 1 || maxDiff < 5 || visibility != 'all' || unlockedFilter != 'all';

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasAdvancedFilter
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
      child: IconButton(
        icon: Badge(
          isLabelVisible: hasAdvancedFilter,
          child: const Icon(Icons.tune),
        ),
        iconSize: 20,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            builder: (_) => _FilterModal(),
          );
        },
        tooltip: 'フィルタ',
      ),
    );
  }
}

class _FilterModal extends ConsumerWidget {
  const _FilterModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minDiff = ref.watch(catalogMinDifficultyProvider);
    final maxDiff = ref.watch(catalogMaxDifficultyProvider);
    final visibility = ref.watch(catalogVisibilityProvider);
    final unlockedFilter = ref.watch(catalogUnlockedFilterProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '詳細フィルタ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // 難易度フィルタ
          Text(
            '難易度（★）',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(minDiff.toDouble(), maxDiff.toDouble()),
            min: 1,
            max: 5,
            divisions: 4,
            labels: RangeLabels('★$minDiff', '★$maxDiff'),
            onChanged: (v) {
              ref.read(catalogMinDifficultyProvider.notifier).state = v.start.toInt();
              ref.read(catalogMaxDifficultyProvider.notifier).state = v.end.toInt();
            },
          ),
          const SizedBox(height: 16),

          // 可視性フィルタ
          Text(
            '可視性',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('全て'),
                selected: visibility == 'all',
                onSelected: (_) =>
                    ref.read(catalogVisibilityProvider.notifier).state = 'all',
              ),
              FilterChip(
                label: const Text('今月の見頃'),
                selected: visibility == 'current',
                onSelected: (_) =>
                    ref.read(catalogVisibilityProvider.notifier).state = 'current',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 解放状況フィルタ
          Text(
            '解放状況',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('全て'),
                selected: unlockedFilter == 'all',
                onSelected: (_) =>
                    ref.read(catalogUnlockedFilterProvider.notifier).state = 'all',
              ),
              FilterChip(
                label: const Text('解放済み'),
                selected: unlockedFilter == 'unlocked',
                onSelected: (_) => ref
                    .read(catalogUnlockedFilterProvider.notifier)
                    .state = 'unlocked',
              ),
              FilterChip(
                label: const Text('未解放'),
                selected: unlockedFilter == 'locked',
                onSelected: (_) =>
                    ref.read(catalogUnlockedFilterProvider.notifier).state = 'locked',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // リセットボタン
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ref.read(catalogMinDifficultyProvider.notifier).state = 1;
                ref.read(catalogMaxDifficultyProvider.notifier).state = 5;
                ref.read(catalogVisibilityProvider.notifier).state = 'all';
                ref.read(catalogUnlockedFilterProvider.notifier).state = 'all';
              },
              child: const Text('フィルタをリセット'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortButton extends ConsumerWidget {
  final String currentSort;
  const _SortButton({required this.currentSort});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      ('name', '登録順', Icons.sort),
      ('difficulty', '易しい順', Icons.star_outline),
      ('difficulty_desc', '難しい順', Icons.star),
    ];

    return PopupMenuButton<String>(
      initialValue: currentSort,
      onSelected: (v) => ref.read(catalogSortProvider.notifier).state = v,
      icon: Badge(
        isLabelVisible: currentSort != 'name',
        child: const Icon(Icons.sort),
      ),
      tooltip: 'ソート',
      itemBuilder: (_) => options
          .map(
            (o) => PopupMenuItem(
              value: o.$1,
              child: Row(
                children: [
                  Icon(
                    o.$3,
                    size: 18,
                    color: currentSort == o.$1
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    o.$2,
                    style: TextStyle(
                      fontWeight: currentSort == o.$1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: currentSort == o.$1
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  final String selectedFilter;
  final int favoriteCount;
  const _CategoryFilter({
    required this.selectedFilter,
    required this.favoriteCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      ('all', '全て', null),
      (ConstellationCategory.zodiac, '黄道12', null),
      (ConstellationCategory.northern, '北天', null),
      (ConstellationCategory.southern, '南天', null),
      ('favorites', '♥ お気に入り', favoriteCount > 0 ? favoriteCount : null),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: categories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: c.$3 != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.$2),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${c.$3}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(c.$2),
              selected: selectedFilter == c.$1,
              onSelected: (_) =>
                  ref.read(catalogFilterProvider.notifier).state = c.$1,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;
  const _ProgressHeader({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = unlocked / total;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text(
            '取得数: $unlocked/$total',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ConstellationGrid extends StatelessWidget {
  final List<Constellation> constellations;
  final Set<String> unlockedIds;
  final Set<String> favoriteIds;

  const _ConstellationGrid({
    required this.constellations,
    required this.unlockedIds,
    required this.favoriteIds,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: constellations.length,
      itemBuilder: (context, index) {
        final c = constellations[index];
        return _ConstellationCard(
          constellation: c,
          isUnlocked: unlockedIds.contains(c.id),
          isFavorite: favoriteIds.contains(c.id),
        );
      },
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '見つかりませんでした',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

class _ConstellationCard extends ConsumerStatefulWidget {
  final Constellation constellation;
  final bool isUnlocked;
  final bool isFavorite;

  const _ConstellationCard({
    required this.constellation,
    required this.isUnlocked,
    required this.isFavorite,
  });

  @override
  ConsumerState<_ConstellationCard> createState() => _ConstellationCardState();
}

class _ConstellationCardState extends ConsumerState<_ConstellationCard>
    with TickerProviderStateMixin {
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  late AnimationController _tapCtrl;
  late Animation<double> _tapScale;

  @override
  void initState() {
    super.initState();

    // ハートバースト: お気に入り追加時に弾む
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.8), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.8, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 35),
    ]).animate(_heartCtrl);

    // カードタップフィードバック
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _tapCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_ConstellationCard old) {
    super.didUpdateWidget(old);
    if (!old.isFavorite && widget.isFavorite) {
      _heartCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _tapCtrl.forward(),
      onTapUp: (_) => _tapCtrl.reverse(),
      onTapCancel: () => _tapCtrl.reverse(),
      onTap: () => context.push('/constellation/${widget.constellation.id}'),
      child: AnimatedBuilder(
        animation: _tapScale,
        builder: (_, child) => Transform.scale(
          scale: _tapScale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isUnlocked
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isUnlocked
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isUnlocked)
                      Text(widget.constellation.emoji,
                          style: const TextStyle(fontSize: 32))
                    else
                      Icon(
                        Icons.lock,
                        size: 28,
                        color: colorScheme.onSurface.withAlpha(100),
                      ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        widget.constellation.nameJa,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: widget.isUnlocked
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface.withAlpha(130),
                              fontWeight:
                                  widget.isUnlocked ? FontWeight.bold : null,
                            ),
                      ),
                    ),
                    if (widget.isUnlocked) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (i) => Icon(
                            i < widget.constellation.baseDifficulty
                                ? Icons.star
                                : Icons.star_border,
                            size: 10,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ハートボタン（解放済みのみ）
              if (widget.isUnlocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      ref
                          .read(favoriteIdsProvider.notifier)
                          .toggle(widget.constellation.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: AnimatedBuilder(
                        animation: _heartScale,
                        builder: (_, __) => Transform.scale(
                          scale: _heartScale.value,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey(widget.isFavorite),
                              size: 16,
                              color: widget.isFavorite
                                  ? Colors.pink.shade400
                                  : colorScheme.onPrimaryContainer
                                      .withAlpha(100),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
