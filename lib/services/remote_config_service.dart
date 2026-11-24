import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService extends ChangeNotifier {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  // Local reactive overrides for judge testing
  int _onDeviceMaxChars = 1200;
  bool _enableGeminiNano = true;
  String _cloudModelName = 'gemini-2.5-flash';
  String _onDeviceModelName = 'gemini-nano-4-embedded';
  double _costPer1kTokensUsd = 0.00015;

  int get onDeviceMaxChars => _onDeviceMaxChars;
  bool get enableGeminiNano => _enableGeminiNano;
  String get cloudModelName => _cloudModelName;
  String get onDeviceModelName => _onDeviceModelName;
  double get costPer1kTokensUsd => _costPer1kTokensUsd;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: const Duration(minutes: 1),
      ));

      await _remoteConfig!.setDefaults({
        'on_device_max_chars': 1200,
        'enable_gemini_nano': true,
        'cloud_model_name': 'gemini-2.5-flash',
        'on_device_model_name': 'gemini-nano-4-embedded',
        'cost_per_1k_tokens': 0.00015,
      });

      try {
        await _remoteConfig!.fetchAndActivate();
      } catch (e) {
        debugPrint('[RemoteConfig] Fetch fallback (using defaults/cache): $e');
      }

      _onDeviceMaxChars = _remoteConfig!.getInt('on_device_max_chars');
      if (_onDeviceMaxChars == 0) _onDeviceMaxChars = 1200;
      _enableGeminiNano = _remoteConfig!.getBool('enable_gemini_nano');
      _cloudModelName = _remoteConfig!.getString('cloud_model_name');
      if (_cloudModelName.isEmpty) _cloudModelName = 'gemini-2.5-flash';
      _onDeviceModelName = _remoteConfig!.getString('on_device_model_name');
      if (_onDeviceModelName.isEmpty) _onDeviceModelName = 'gemini-nano-4-embedded';
      _costPer1kTokensUsd = _remoteConfig!.getDouble('cost_per_1k_tokens');
      if (_costPer1kTokensUsd == 0) _costPer1kTokensUsd = 0.00015;

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[RemoteConfig] Running in offline/resilient local mode: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  void updateThresholdForTesting(int newThreshold) {
    _onDeviceMaxChars = newThreshold;
    notifyListeners();
  }

  void toggleGeminiNanoForTesting(bool enabled) {
    _enableGeminiNano = enabled;
    notifyListeners();
  }

  void resetToDefaults() {
    _onDeviceMaxChars = 1200;
    _enableGeminiNano = true;
    _cloudModelName = 'gemini-2.5-flash';
    _onDeviceModelName = 'gemini-nano-4-embedded';
    _costPer1kTokensUsd = 0.00015;
    notifyListeners();
  }
}
