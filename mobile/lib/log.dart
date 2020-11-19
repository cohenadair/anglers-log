class Log {
  final String _className;

  const Log(this._className) : assert(_className != null);

  String get _prefix => "AL-$_className: ";

  void d(String msg) {
    print("D/$_prefix$msg");
  }

  void e(String msg) {
    print("E/$_prefix$msg");
  }

  void w(String msg) {
    print("W/$_prefix$msg");
  }
}
