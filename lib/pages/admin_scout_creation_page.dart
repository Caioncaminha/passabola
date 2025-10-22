import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/constants.dart';
import 'login_page.dart';

class AdminScoutCreationImprovedPage extends StatefulWidget {
  const AdminScoutCreationImprovedPage({super.key});

  @override
  State<AdminScoutCreationImprovedPage> createState() =>
      _AdminScoutCreationImprovedPageState();
}

class _AdminScoutCreationImprovedPageState
    extends State<AdminScoutCreationImprovedPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createScoutAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      // Salvar dados do admin atual
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String? currentUserEmail = currentUser?.email;

      if (currentUserEmail == null) {
        throw Exception('Usuário admin não encontrado');
      }

      // 1) Criar usuário de autenticação
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? newUser = credential.user;

      if (newUser != null) {
        // 2) Atualizar displayName
        await newUser.updateDisplayName(name);

        // 3) Criar documento do usuário no Firestore com role de olheiro
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(newUser.uid)
            .set({
              'uid': newUser.uid,
              'name': name,
              'email': email,
              'role': 'olheiro',
              'createdAt': FieldValue.serverTimestamp(),
              'isRegistered': true,
              'createdBy': 'admin',
              'createdByEmail': currentUserEmail,
            });

        // 4) Fazer logout da conta criada
        await FirebaseAuth.instance.signOut();

        // 5) Mostrar diálogo de confirmação
        if (!mounted) return;

        await _showSuccessDialog(context, email, password);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao criar conta';
      if (e.code == 'email-already-in-use') {
        message = 'Email já está em uso';
      } else if (e.code == 'invalid-email') {
        message = 'Email inválido';
      } else if (e.code == 'weak-password') {
        message = 'Senha fraca (mínimo 6 caracteres)';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha inesperada: $e'),
          backgroundColor: Colors.red,
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

  Future<void> _showSuccessDialog(
    BuildContext context,
    String email,
    String password,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conta Criada com Sucesso!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('A conta de olheiro foi criada com sucesso.'),
              const SizedBox(height: 16),
              const Text('Credenciais da nova conta:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text('Email: $email'), Text('Senha: $password')],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Você será redirecionado para a tela de login. Use suas credenciais de admin para fazer login novamente.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin();
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToLogin() {
    // Limpar formulário
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    // Navegar de volta para login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta de Olheiro'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Criar Nova Conta de Olheiro',
                style: KTextStyle.largeTitleText,
              ),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                'Crie uma nova conta com acesso à dashboard de jogadoras.',
                style: KTextStyle.bodyText.copyWith(
                  color: KConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de nome
              TextFormField(
                controller: _nameController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Nome Completo',
                  hintText: 'Ex: João Silva',
                  prefixIcon: Icons.person,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter pelo menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Email',
                  hintText: 'Ex: joao@exemplo.com',
                  prefixIcon: Icons.email,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email é obrigatório';
                  }
                  if (!value.contains('@')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha é obrigatória';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de confirmação de senha
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Confirmar Senha',
                  hintText: 'Digite a senha novamente',
                  prefixIcon: Icons.lock_outline,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirmação de senha é obrigatória';
                  }
                  if (value != _passwordController.text) {
                    return 'Senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Aviso importante
              Container(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: KConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        'Após criar a conta, você será redirecionado para fazer login novamente.',
                        style: KTextStyle.smallText.copyWith(
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Informação sobre permissões
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
                      Icons.info_outline,
                      color: KConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: KConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        'Esta conta terá acesso à dashboard de jogadoras com estatísticas detalhadas.',
                        style: KTextStyle.smallText.copyWith(
                          color: KConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
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
                      onPressed: _isLoading ? null : _createScoutAccount,
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
                          : const Text('Criar Conta'),
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
}
