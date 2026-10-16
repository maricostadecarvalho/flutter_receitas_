import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';
import '../widgets/receita_imagem.dart';
import 'form_receita_screen.dart';

class DetalhesReceitaScreen extends StatefulWidget {
  final Receita receita;

  const DetalhesReceitaScreen({
    super.key,
    required this.receita,
  });

  @override
  State<DetalhesReceitaScreen> createState() =>
      _DetalhesReceitaScreenState();
}

class _DetalhesReceitaScreenState
    extends State<DetalhesReceitaScreen> {
  late Receita receita;

  @override
  void initState() {
    super.initState();
    receita = widget.receita;
    carregarDetalhes();
  }

  Future<void> carregarDetalhes() async {
    if (receita.id == null) return;

    try {
      final atualizada =
          await ReceitaService().buscar(receita.id);

      if (mounted) {
        setState(() => receita = atualizada);
      }
    } catch (_) {
      // Mantém os dados recebidos pela lista.
    }
  }

  Future<void> editar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormReceitaScreen(
          receita: receita,
        ),
      ),
    );

    if (resultado == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: 'Editar receita',
            onPressed: editar,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            receita.nome,
            style: Theme.of(context)
                .textTheme.headlineMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ReceitaImagem(
              url: receita.img,
              tamanho: 240,
            ),
          ),
          const SizedBox(height: 18),
          Chip(
            avatar: const Icon(Icons.category_outlined),
            label: Text(receita.tipo),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Custo aproximado'),
              subtitle: Text(
                'R\$ ${receita.custoAproximado.toStringAsFixed(2)}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ingredientes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(receita.ingredientes),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Modo de preparo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(receita.modoFazer),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: editar,
            icon: const Icon(Icons.edit),
            label: const Text('Editar receita'),
          ),
        ],
      ),
    );
  }
}
