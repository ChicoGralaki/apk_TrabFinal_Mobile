import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
  final FirebaseAuth _auth;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn({
    required String email,
    required String password,
  }) async =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() => _auth.signOut();

  static String readableError(FirebaseAuthException error) =>
      switch (error.code) {
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Já existe uma conta com este e-mail.',
        'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
        'invalid-email' => 'Informe um e-mail válido.',
        'network-request-failed' =>
          'Sem conexão. Verifique a internet e tente novamente.',
        'too-many-requests' =>
          'Muitas tentativas. Aguarde um pouco e tente novamente.',
        _ => 'Não foi possível concluir a autenticação. Tente novamente.',
      };
}
