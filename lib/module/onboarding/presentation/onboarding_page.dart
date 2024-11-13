import 'package:estetify/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool _passwordEmpty = false;
  bool _confirmPasswordEmpty = false;
  bool _usernameEmpty = false;

  final UserService userService = UserService();

  String? fullName;

  @override
  void initState() {
    super.initState();

    // Captura o nome completo do usuário após o login com Google
    final user = supabase.auth.currentUser;
    if (user != null) {
      fullName = user.userMetadata?['full_name'];
      _usernameController.text =
          fullName ?? ''; // Preenche o username com o nome
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8E2DE2),
                  Color(0xFFDA4453),
                  Color(0xFFF37335),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Scrollable content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 27).add(
                EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    "Complete seu cadastro",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildUsernameField(),
                  const SizedBox(height: 20),
                  _buildPasswordFields(),
                  const SizedBox(height: 20),
                  _buildCompleteRegistrationButton(),
                  const SizedBox(height: 20),
                  _buildCancelButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de username
  Widget _buildUsernameField() {
    return CupertinoTextField(
      controller: _usernameController,
      placeholder: "Escolha um nome de usuário",
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: _usernameEmpty ? Colors.red : Colors.transparent,
        ),
      ),
    );
  }

  /// Campos de senha e confirmação de senha
  Widget _buildPasswordFields() {
    return Column(
      children: [
        CupertinoTextField(
          style: const TextStyle(color: Colors.white),
          placeholderStyle: const TextStyle(color: Colors.white70),
          cursorColor: Colors.white,
          controller: _passwordController,
          placeholder: "Digite sua senha",
          obscureText: true,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _passwordEmpty ? Colors.redAccent : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CupertinoTextField(
          style: const TextStyle(color: Colors.white),
          placeholderStyle: const TextStyle(color: Colors.white70),
          cursorColor: Colors.white,
          controller: _confirmPasswordController,
          placeholder: "Confirme sua senha",
          obscureText: true,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: _confirmPasswordEmpty ? Colors.red : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  /// Botão de completar cadastro
  Widget _buildCompleteRegistrationButton() {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.all(17),
        color: Colors.greenAccent,
        onPressed: _completeRegistration,
        child: const Text(
          "Finalizar cadastro",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Botão de cancelar
  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.all(17),
        onPressed: () {
          context.go("/login");
        },
        child: const Text(
          "Cancelar",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _completeRegistration() async {
    setState(() {
      _passwordEmpty = _passwordController.text.isEmpty;
      _confirmPasswordEmpty = _confirmPasswordController.text.isEmpty;
      _usernameEmpty = _usernameController.text.isEmpty;
    });

    if (_passwordEmpty || _confirmPasswordEmpty || _usernameEmpty) {
      showErrorDialog(context, 'Erro', 'Preencha todos os campos obrigatórios');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      showErrorDialog(context, 'Erro', 'As senhas não coincidem');
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      showErrorDialog(context, 'Erro', 'Falha na autenticação do Google');
      return;
    }

    // Obtenha o email e nome completo do usuário
    final email = user.email;
    final fullName = user.userMetadata?['full_name'];

    if (email == null || fullName == null) {
      showErrorDialog(context, 'Erro', 'Erro ao obter informações do Google');
      return;
    }

    final userData = {
      'name': fullName,
      'username': _usernameController.text,
      'email': email, // O nome de usuário fornecido
      'password_hash': _passwordController.text,
    };

    final result = await userService.createUser(userData);

    if (result.containsKey('error')) {
      showErrorDialog(context, 'Erro', result['error']);
    } else {
      // Aqui é onde você redireciona para a página inicial após o cadastro
      context.go('/home');
    }
  }
}
