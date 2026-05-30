class AppMode {
  static final AppMode _instance = AppMode._();
  factory AppMode() => _instance;
  AppMode._();

  bool _isOffline = false;

  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;

  void setOffline() => _isOffline = true;
  void setOnline() => _isOffline = false;
  void reset() => _isOffline = false;
}