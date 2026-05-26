import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _mostrarSenha = false;

  final Color corRosaForte = const Color(0xFFE57373);
  final Color corRosaSuave = const Color(0xFFFFB3B3);

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cadastro_fundo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Nova Conta",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 40),

                    _campoEstilizado(
                      controller: _nomeController,
                      label: "Usuário",
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.isEmpty) ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 15),

                    _campoEstilizado(
                      controller: _senhaController,
                      label: "Senha",
                      icon: Icons.lock_outline,
                      obscureText: !_mostrarSenha,
                      suffixIcon: IconButton(
                        icon: Icon(_mostrarSenha ? Icons.visibility : Icons.visibility_off, color: corRosaSuave),
                        onPressed: () => setState(() => _mostrarSenha = !_mostrarSenha),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return "Mínimo 6 caracteres";
                        if (!value.contains(RegExp(r'[0-9]'))) return "Adicione um número";
                        if (!value.contains(RegExp(r'[A-Z]'))) return "Adicione uma letra maiúscula";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    _campoEstilizado(
                      controller: _confirmarController,
                      label: "Confirmar Senha",
                      icon: Icons.check_circle_outline,
                      obscureText: true,
                      validator: (v) => v != _senhaController.text ? "As senhas não coincidem" : null,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corRosaForte,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Chamada assíncrona do ViewModel corrigida
                          await context.read<AppViewModel>().cadastrarUsuario(
                            _nomeController.text,
                            _senhaController.text,
                          );
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cadastro realizado com sucesso!")),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("CADASTRAR", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Já tenho conta? Entrar", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoEstilizado({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    // CORREÇÃO: O estilo visual de fundo foi movido para o próprio InputDecoration,
    // permitindo que o texto de erro seja renderizado abaixo do campo sem quebras de layout.
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: corRosaSuave),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Mantém as bordas arredondadas e limpas do seu design
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(
          color: Colors.white, // Deixa o texto de erro branco para contrastar com o fundo rosa da página
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}