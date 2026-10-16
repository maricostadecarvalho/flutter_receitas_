import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';

class FormReceitaScreen extends StatefulWidget {
  final Receita? receita;
  final VoidCallback? aoSalvar;

  const FormReceitaScreen({super.key, this.receita, this.aoSalvar});

  @override
  State<FormReceitaScreen> createState() => _FormReceitaScreenState();
}

class _FormReceitaScreenState extends State<FormReceitaScreen> {
  final formKey = GlobalKey<FormState>();

  final nome = TextEditingController();
  final ingredientes = TextEditingController();
  final modoFazer = TextEditingController();
  final img = TextEditingController();
  final custo = TextEditingController();

  String tipo = 'DOCE';
  bool salvando = false;

  @override
  void initState() {
    super.initState();

    final receita = widget.receita;

    if (receita != null) {
      nome.text = receita.nome;
      ingredientes.text = receita.ingredientes;
      modoFazer.text = receita.modoFazer;
      img.text = receita.img;
      custo.text = receita.custoAproximado.toString();

      tipo = ['DOCE', 'SALGADA', 'BEBIDA'].contains(receita.tipo)
          ? receita.tipo
          : 'DOCE';
    }
  }

  @override
  void dispose() {
    nome.dispose();
    ingredientes.dispose();
    modoFazer.dispose();
    img.dispose();
    custo.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => salvando = true);

    final receita = Receita(
      id: widget.receita?.id,
      nome: nome.text.trim(),
      tipo: tipo,
      ingredientes: ingredientes.text.trim(),
      modoFazer: modoFazer.text.trim(),
      img: img.text.trim(),
      custoAproximado: double.parse(custo.text.trim().replaceAll(',', '.')),
    );

    try {
      final service = ReceitaService();

      if (widget.receita == null) {
        await service.criar(receita);
      } else {
        await service.atualizar(receita);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.receita == null
                ? 'Receita cadastrada!'
                : 'Receita atualizada!',
          ),
        ),
      );

      if (widget.aoSalvar != null) {
        widget.aoSalvar!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Não foi possível salvar: $e')));
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.aoSalvar == null
          ? AppBar(
              title: Text(
                widget.receita == null ? 'Nova Receita' : 'Editar Receita',
              ),
            )
          : null,
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            campo(nome, 'Nome da receita', obrigatorio: true),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'DOCE', child: Text('Doce')),
                DropdownMenuItem(value: 'SALGADA', child: Text('Salgada')),
                DropdownMenuItem(value: 'BEBIDA', child: Text('Bebida')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    tipo = value;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            campo(ingredientes, 'Ingredientes', obrigatorio: true, linhas: 4),
            const SizedBox(height: 14),
            campo(modoFazer, 'Modo de preparo', obrigatorio: true, linhas: 5),
            const SizedBox(height: 14),
            campo(img, 'URL da imagem'),
            const SizedBox(height: 14),
            campo(
              custo,
              'Custo aproximado (R\$)',
              obrigatorio: true,
              numerico: true,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: salvando ? null : salvar,
              icon: salvando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(salvando ? 'Salvando...' : 'Salvar receita'),
            ),
          ],
        ),
      ),
    );
  }

  Widget campo(
    TextEditingController controller,
    String rotulo, {
    bool obrigatorio = false,
    bool numerico = false,
    int linhas = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: linhas,
      keyboardType: numerico
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: rotulo),
      validator: (value) {
        if (obrigatorio && (value == null || value.trim().isEmpty)) {
          return 'Preencha este campo.';
        }

        if (numerico &&
            value != null &&
            value.trim().isNotEmpty &&
            double.tryParse(value.trim().replaceAll(',', '.')) == null) {
          return 'Digite um valor numérico válido.';
        }

        return null;
      },
    );
  }
}

