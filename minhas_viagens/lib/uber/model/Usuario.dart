class Usuario{
  late String _idUsuario;
  late String _nome;
  late String _email;
  late String _senha;
  late String _tipoUsuario;

  late double _latitude;
  late double _longitude;

  double get latitude => _latitude;

  set latitude(double value) {
    _latitude = value;
  }

  Usuario();

  String verificaTipoUsuario(bool tipoUsuario){
    return tipoUsuario ? "motorista" : "passageiro";
  }

  Map<String, dynamic> toMap(){
    return {
      "idUsuario" : _idUsuario,
      "nome" : _nome,
      "email" : _email,
      "tipoUsuario" : _tipoUsuario,
      "latitude" : _latitude,
      "longitude" : _longitude,
    };
  }

  String get tipoUsuario => _tipoUsuario;

  set tipoUsuario(String value) {
    _tipoUsuario = value;
  }

  String get senha => _senha;

  set senha(String value) {
    _senha = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  double get longitude => _longitude;

  set longitude(double value) {
    _longitude = value;
  }
}