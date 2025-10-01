import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/article_service.dart';

class ArticleCreatePage extends StatefulWidget {
  const ArticleCreatePage({super.key});

  @override
  State<ArticleCreatePage> createState() => _ArticleCreatePageState();
}

class _ArticleCreatePageState extends State<ArticleCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _isLoading = false;
  bool _isPublished = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Artigo'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _onSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: KConstants.textLightColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
              // Título
              TextFormField(
                controller: _titleController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Título do Artigo',
                  hintText: 'Digite o título do artigo',
                  prefixIcon: Icons.title,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Título é obrigatório'
                    : null,
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // URL da imagem
              TextFormField(
                controller: _imageUrlController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'URL da Imagem (opcional)',
                  hintText: 'https://exemplo.com/imagem.jpg',
                  prefixIcon: Icons.image,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Tags
              TextFormField(
                controller: _tagsController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Tags (opcional)',
                  hintText:
                      'futebol, notícias, esporte (separadas por vírgula)',
                  prefixIcon: Icons.tag,
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Status de publicação
              Container(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: KConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: KConstants.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: KConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: KConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        'Status de Publicação',
                        style: KTextStyle.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() {
                          _isPublished = value;
                        });
                      },
                      activeColor: KConstants.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                _isPublished
                    ? 'Artigo será publicado imediatamente'
                    : 'Artigo será salvo como rascunho',
                style: KTextStyle.smallText.copyWith(
                  color: _isPublished
                      ? KConstants.successColor
                      : KConstants.warningColor,
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Conteúdo
              TextFormField(
                controller: _contentController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Conteúdo do Artigo',
                  hintText: 'Digite o conteúdo do artigo aqui...',
                ),
                maxLines: 12,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Conteúdo é obrigatório'
                    : null,
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: KConstants.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KConstants.primaryColor,
                        foregroundColor: KConstants.textLightColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: KConstants.spacingMedium,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: KConstants.textLightColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isPublished ? 'Publicar' : 'Salvar Rascunho'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Processar tags
      final tagsText = _tagsController.text.trim();
      final tags = tagsText.isEmpty
          ? <String>[]
          : tagsText
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();

      // Criar artigo
      await ArticleService.createArticle(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        tags: tags,
        isPublished: _isPublished,
      );

      if (!mounted) return;

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPublished
                ? 'Artigo publicado com sucesso!'
                : 'Rascunho salvo com sucesso!',
          ),
          backgroundColor: KConstants.successColor,
        ),
      );

      // Voltar para a tela anterior
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar artigo: $e'),
          backgroundColor: KConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
