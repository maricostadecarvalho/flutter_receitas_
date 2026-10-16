import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';
import '../widgets/receita_imagem.dart';
import 'form_receita_screen.dart';
import 'detalhes_receita_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode tema;
  final VoidCallback onAlternarTema;

  const HomeScreen({
    super.key,
    required this.tema,
    required this.onAlternarTema,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = ReceitaService();
  List<Receita> receitas = [];
  bool carregando = true;
  String? erro;
  int pagina = 0;

  @override
  void initState() {
    super.initState();
    carregarReceitas();
  }

  Future<void> carregarReceitas() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resultado = await service.listar();

      if (!mounted) return;

      setState(() {
        receitas = resultado;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erro = e.toString();
        carregando = false;
      });
    }
  }

  Future<void> abrirFormulario({Receita? receita}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormReceitaScreen(receita: receita),
      ),
    );

    if (resultado == true) carregarReceitas();
  }

  Future<void> abrirDetalhes(Receita receita) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalhesReceitaScreen(receita: receita),
      ),
    );

    if (resultado == true) carregarReceitas();
  }

  Future<void> confirmarExclusao(Receita receita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text('Deseja excluir "${receita.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await service.excluir(receita.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita excluída com sucesso!'),
        ),
      );

      carregarReceitas();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pagina == 0 ? 'Receitas' : 'Nova Receita'),
        actions: [
          IconButton(
            tooltip: 'Alternar tema',
            onPressed: widget.onAlternarTema,
            icon: Icon(
              widget.tema == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          IconButton(
            tooltip: 'Atualizar receitas',
            onPressed: carregarReceitas,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: pagina == 0
          ? construirLista()
          : FormReceitaScreen(
              key: const ValueKey('novo-formulario'),
              aoSalvar: () {
                carregarReceitas();
                setState(() => pagina = 0);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pagina,
        onTap: (index) {
          setState(() => pagina = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Nova',
          ),
        ],
      ),
    );
  }

  Widget construirLista() {
    if (carregando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 54),
              const SizedBox(height: 12),
              const Text(
                'Não foi possível carregar as receitas.',
              ),
              const SizedBox(height: 8),
              Text(erro!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: carregarReceitas,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (receitas.isEmpty) {
      return const Center(
        child: Text('Nenhuma receita cadastrada ainda.'),
      );
    }

    return RefreshIndicator(
      onRefresh: carregarReceitas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: receitas.length,
        itemBuilder: (context, index) {
          final receita = receitas[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: ReceitaImagem(
                url: receita.img,
                tamanho: 65,
              ),
              title: Text(
                receita.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${receita.tipo} • R\$ '
                '${receita.custoAproximado.toStringAsFixed(2)}',
              ),
              trailing: IconButton(
                tooltip: 'Excluir',
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
                onPressed: () => confirmarExclusao(receita),
              ),
              onTap: () => abrirDetalhes(receita),
            ),
          );
        },
      ),
    );
  }
}
