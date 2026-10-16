import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/receita.dart';

const String apiUrl = 'https://receitasapi-b-2025.vercel.app';

class ReceitaService {
  Future<List<Receita>> listar() async {
    final resposta = await http
        .get(Uri.parse('$apiUrl/receitas'))
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível carregar as receitas.');
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

    final lista = dados is List
        ? dados
        : dados is Map && dados['receitas'] is List
            ? dados['receitas'] as List
            : dados is Map && dados['data'] is List
                ? dados['data'] as List
                : null;

    if (lista == null) {
      throw Exception('Formato de resposta da API inválido.');
    }

    return lista.map((item) {
      return Receita.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  Future<Receita> buscar(dynamic id) async {
    final resposta = await http.get(
      Uri.parse('$apiUrl/receitas/${Uri.encodeComponent('$id')}'),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Não foi possível buscar a receita.');
    }

    final dados = jsonDecode(utf8.decode(resposta.bodyBytes));

    final mapa = dados is Map && dados['receita'] is Map
        ? dados['receita']
        : dados;

    return Receita.fromJson(
      Map<String, dynamic>.from(mapa as Map),
    );
  }

  Future<void> criar(Receita receita) async {
    final resposta = await http.post(
      Uri.parse('$apiUrl/receitas'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(receita.toJson()),
    );

    if (resposta.statusCode < 200 ||
        resposta.statusCode >= 300) {
      throw Exception('Erro ao cadastrar: ${resposta.body}');
    }
  }

  Future<void> atualizar(Receita receita) async {
    final resposta = await http.put(
      Uri.parse('$apiUrl/receitas/${receita.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(receita.toJson()),
    );

    if (resposta.statusCode < 200 ||
        resposta.statusCode >= 300) {
      throw Exception('Erro ao editar: ${resposta.body}');
    }
  }

  Future<void> excluir(dynamic id) async {
    final resposta = await http.delete(
      Uri.parse('$apiUrl/receitas/$id'),
    );

    if (resposta.statusCode < 200 ||
        resposta.statusCode >= 300) {
      throw Exception('Erro ao excluir: ${resposta.body}');
    }
  }
}
