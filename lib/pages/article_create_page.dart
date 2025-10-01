import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/article.dart';

class ArticleCreatePage extends StatefulWidget {
  const ArticleCreatePage({super.key});

  @override
  State<ArticleCreatePage> createState() => _ArticleCreatePageState();
}

class _ArticleCreatePageState extends State<ArticleCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova reportagem'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(
              'Salvar',
              style: KTextStyle.buttonText.copyWith(
                color: KConstants.textLightColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Título',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: KConstants.spacingMedium),
              TextFormField(
                controller: _subtitleController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Subtítulo',
                ),
              ),
              const SizedBox(height: KConstants.spacingMedium),
              TextFormField(
                controller: _imageUrlController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'URL da imagem (opcional)',
                ),
              ),
              const SizedBox(height: KConstants.spacingMedium),
              TextFormField(
                controller: _bodyController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Texto da reportagem',
                ),
                maxLines: 8,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o texto' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final Article article = Article(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      body: _bodyController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(article);
  }
}
