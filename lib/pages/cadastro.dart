import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers para capturar o texto dos campos
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _isSubmitting = false;

  /// Cria um usuário simples no Firestore.
  /// - 'usuarios' é a coleção genérica.
  /// - O documento é criado com ID automático.
  /// é necessário validar entradas e não armazenar senhas em texto plano.
  Future<void> _createUserInFirestore() async {
    setState(() => _isSubmitting = true);
    try {
      final Map<String, dynamic> payload = {
        'email': _emailController.text.trim(),
        'senha': _senhaController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Adiciona documento à coleção 'usuarios'. Se a coleção não existir,
      // o Firestore a criará automaticamente.
      await FirebaseFirestore.instance.collection('usuarios').add(payload);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar para Firestore: $err')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Validação mínima dos campos de entrada.
  /// Retorna true se os campos parecem válidos, false caso contrário.
  bool _validateInputs() {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um e-mail válido.'),
          duration: Duration(milliseconds: 300),
        ),
      );
      return false;
    }
    if (senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A senha deve ter pelo menos 6 caracteres.'),
          duration: Duration(milliseconds: 300),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF6B428A).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF6B428A).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF6B428A).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF6B428A).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF428A6B),
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Color(0xFF428A6B),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Campo de e-mail
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F3F3),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'EMAIL',
                        hintStyle: TextStyle(
                          color: Color(0xFF428A6B),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo de senha
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 5.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6F3F3),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: TextField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'SENHA',
                        hintStyle: TextStyle(
                          color: Color(0xFF428A6B),
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Botão entrar
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            // Validação mínima antes de enviar
                            if (!_validateInputs()) return;

                            // Envia para Firestore e navega
                            await _createUserInFirestore();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const MainPage(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF66BB6A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Enviando...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Cadastrar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
