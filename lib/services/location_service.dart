import 'package:geolocator/geolocator.dart';

/// 位置情報取得の結果。成功時は座標、失敗時は理由を保持する。
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  final double latitude;
  final double longitude;
  const LocationSuccess({required this.latitude, required this.longitude});
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class LocationFailure extends LocationResult {
  final LocationFailureReason reason;
  const LocationFailure(this.reason);

  String get message => switch (reason) {
        LocationFailureReason.serviceDisabled =>
          '端末の位置情報サービスがオフになっています。設定から有効にしてください。',
        LocationFailureReason.permissionDenied => '位置情報の利用が許可されませんでした。',
        LocationFailureReason.permissionDeniedForever =>
          '位置情報の利用が拒否されています。端末設定からアプリの位置情報許可を有効にしてください。',
        LocationFailureReason.unknown => '位置情報の取得に失敗しました。',
      };
}

/// 端末のGPSから現在地を取得するサービス。
/// 星空マップ・光害マップで「現在地を使う」機能のために使用する。
class LocationService {
  const LocationService._();

  static Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationFailure(LocationFailureReason.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationFailure(LocationFailureReason.permissionDenied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationFailure(
            LocationFailureReason.permissionDeniedForever);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return LocationSuccess(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return const LocationFailure(LocationFailureReason.unknown);
    }
  }
}
