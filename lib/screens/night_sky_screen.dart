import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/constellation_provider.dart';
import '../models/constellation.dart';
import '../services/moon_service.dart';
import '../services/sky_position_service.dart';
import '../widgets/night_sky_map.dart';

class _City {
  final String name;
  final double lat;
  final double lon;
  const _City(this.name, this.lat, this.lon);
}

const _cities = [
  _City('東京', 35.6812, 139.7671),
  _City('大阪', 34.6937, 135.5023),
  _City('名古屋', 35.1815, 136.9066),
  _City('福岡', 33.5904, 130.4017),
  _City('札幌', 43.0621, 141.3544),
  _City('仙台', 38.2682, 140.8694),
  _City('那覇', 26.2124, 127.6809),
];

/// 「この日の星空」画面: 日付・時刻・場所を選ぶと、その夜空に見える星座と
/// 月の位置・満ち欠けを円形の星図で再現する。
class NightSkyScreen extends ConsumerStatefulWidget {
  /// 初期表示する日時（省略時は現在時刻）。記念日リンクなどから利用。
  final DateTime? initialDateTime;

  const NightSkyScreen({super.key, this.initialDateTime});

  @override
  ConsumerState<NightSkyScreen> createState() => _NightSkyScreenState();
}

class _NightSkyScreenState extends ConsumerState<NightSkyScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _cityIndex = 0;
  Constellation? _tappedConstellation;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDateTime ?? DateTime.now();
    _selectedDate = DateTime(base.year, base.month, base.day);
    _selectedTime = TimeOfDay(hour: base.hour, minute: base.minute);
  }

  DateTime get _localDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  @override
  Widget build(BuildContext context) {
    final constellationsAsync = ref.watch(constellationListProvider);
    final city = _cities[_cityIndex];
    final localDt = _localDateTime;
    // JSTを想定した簡易UTC変換（日本の主要都市はすべてUTC+9）。
    // 端末側のタイムゾーンに依存させないよう、明示的にUTC DateTimeを作る。
    final naiveUtc = localDt.subtract(const Duration(hours: 9));
    final utc = DateTime.utc(
      naiveUtc.year,
      naiveUtc.month,
      naiveUtc.day,
      naiveUtc.hour,
      naiveUtc.minute,
    );

    final moonAge = MoonService.moonAge(utc);
    final moonEmoji = MoonService.moonPhaseEmoji(moonAge);
    final moonPhaseName = MoonService.moonPhaseName(moonAge);

    final sunPos = SkyPositionService.sunPosition(
      utc: utc,
      latitudeDeg: city.lat,
      longitudeDeg: city.lon,
    );
    final isDaytime = sunPos.altitude > -6; // 薄明を含めて「昼」とみなす

    return Scaffold(
      backgroundColor: const Color(0xFF050818),
      appBar: AppBar(
        title: const Text('この日の星空'),
        backgroundColor: const Color(0xFF0A0E28),
        foregroundColor: Colors.white,
      ),
      body: constellationsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => Center(
          child: Text('読み込みエラー: $e', style: const TextStyle(color: Colors.white70)),
        ),
        data: (all) {
          final moonPos = SkyPositionService.moonPosition(
            utc: utc,
            latitudeDeg: city.lat,
            longitudeDeg: city.lon,
          );

          final plotted = all.map((c) {
            final pos = SkyPositionService.equatorialToHorizontal(
              raHours: SkyPositionService.parseRightAscensionHours(c.rightAscension),
              decDeg: SkyPositionService.parseDeclinationDegrees(c.declination),
              utc: utc,
              latitudeDeg: city.lat,
              longitudeDeg: city.lon,
            );
            return PlottedConstellation(constellation: c, position: pos);
          }).toList();

          final visibleCount = plotted.where((p) => p.position.isVisible).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _ControlPanel(
                  date: _selectedDate,
                  time: _selectedTime,
                  cityIndex: _cityIndex,
                  onDateTap: _pickDate,
                  onTimeTap: _pickTime,
                  onCityChanged: (i) => setState(() => _cityIndex = i),
                ),
                const SizedBox(height: 16),
                NightSkyMap(
                  constellations: plotted,
                  moonPosition: moonPos,
                  sunPosition: sunPos,
                  moonEmoji: moonEmoji,
                  isDaytime: isDaytime,
                  onConstellationTap: (c) =>
                      setState(() => _tappedConstellation = c),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  moonPhaseName: moonPhaseName,
                  moonAge: moonAge,
                  moonEmoji: moonEmoji,
                  visibleCount: visibleCount,
                  isDaytime: isDaytime,
                ),
                if (_tappedConstellation != null) ...[
                  const SizedBox(height: 16),
                  _TappedConstellationCard(
                    constellation: _tappedConstellation!,
                    onOpenDetail: () => context
                        .push('/constellation/${_tappedConstellation!.id}'),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  '※ 星座の位置は簡易計算による近似です。実際の見え方とは多少異なる場合があります。',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }
}

class _ControlPanel extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final int cityIndex;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final ValueChanged<int> onCityChanged;

  const _ControlPanel({
    required this.date,
    required this.time,
    required this.cityIndex,
    required this.onDateTap,
    required this.onTimeTap,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy年M月d日').format(date);
    final timeStr = time.format(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ChipButton(
                  icon: Icons.calendar_today,
                  label: dateStr,
                  onTap: onDateTap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChipButton(
                  icon: Icons.access_time,
                  label: timeStr,
                  onTap: onTimeTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white54, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButton<int>(
                  value: cityIndex,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF141B3D),
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: [
                    for (var i = 0; i < _cities.length; i++)
                      DropdownMenuItem(value: i, child: Text(_cities[i].name)),
                  ],
                  onChanged: (v) {
                    if (v != null) onCityChanged(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String moonPhaseName;
  final double moonAge;
  final String moonEmoji;
  final int visibleCount;
  final bool isDaytime;

  const _InfoRow({
    required this.moonPhaseName,
    required this.moonAge,
    required this.moonEmoji,
    required this.visibleCount,
    required this.isDaytime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: moonEmoji,
            value: moonPhaseName,
            label: '月齢${moonAge.toStringAsFixed(1)}日',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            emoji: '✨',
            value: '$visibleCount個',
            label: '見えている星座',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            emoji: isDaytime ? '☀️' : '🌌',
            value: isDaytime ? '昼間' : '夜間',
            label: isDaytime ? '観測には不向き' : '観測チャンス',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatCard({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TappedConstellationCard extends StatelessWidget {
  final Constellation constellation;
  final VoidCallback onOpenDetail;

  const _TappedConstellationCard({
    required this.constellation,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpenDetail,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(constellation.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    constellation.nameJa,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    constellation.mythologyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
