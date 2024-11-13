import 'package:estetify/index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final UserService userService = UserService();
  final SupabaseClient supabase = Supabase.instance.client;

  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final authResponse = await userService.googleSignIn();
      final user = authResponse?.user;

      if (user != null) {
        final userExists = await userService.checkIfUserExists(user.email!);

        if (userExists) {
          context.go('/home');
        } else {
          context.go('/onboarding');
        }
      } else {
        throw Exception("Usuário não encontrado.");
      }
    } catch (e) {
      print("Erro ao logar com Google: $e");
      showErrorDialog(context, "Erro", "Ocorreu um problema. Tente novamente.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Estetify",
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 42,
            ),
          ),
        ),
        toolbarHeight: 130,
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(27),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const WelcomeText(),
            const SizedBox(height: 50),
            _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : GoogleSignInButton(onPressed: _handleGoogleSignIn),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
