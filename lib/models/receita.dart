class Receita {
  final dynamic id;
  final String nome;
  final String tipo;
  final String ingredientes;
  final String modoFazer;
  final String img;
  final double custoAproximado;

  const Receita({
    this.id,
    required this.nome,
    required this.tipo,
    required this.ingredientes,
    required this.modoFazer,
    required this.img,
    required this.custoAproximado,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      id: json['id'],
      nome: (json['nome'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'DOCE').toString(),
      ingredientes: (json['ingredientes'] ?? '').toString(),
      modoFazer: (json['modoFazer'] ?? '').toString(),
      img: (json['img'] ?? '').toString(),
      custoAproximado:
          double.tryParse('${json['custoAproximado'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      'ingredientes': ingredientes,
      'modoFazer': modoFazer,
      'img': img,
      'custoAproximado': custoAproximado,
    };
  }
}
