import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool loading = false;
  bool hidePassword = true;

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || !email.contains("@")) {
      showMessage("Enter a valid email address.");
      return false;
    }

    if (password.length < 6) {
      showMessage("Password must be at least 6 characters.");
      return false;
    }

    return true;
  }
  Future<void> saveUserProfile(User user) async {
  await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
    "uid": user.uid,
    "email": user.email,
    "displayName": user.displayName ?? "",
    "photoURL": user.photoURL ?? "",
    "createdAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<void> submit() async {
  if (!validateInputs()) return;

  setState(() => loading = true);

  try {
    UserCredential credential;

    if (isLogin) {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } else {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    }

    final user = credential.user;
    if (user != null) {
      await saveUserProfile(user);
    }
  } on FirebaseAuthException catch (e) {
    showMessage(firebaseError(e.code));
  } finally {
    if (mounted) setState(() => loading = false);
  }
}
Future<void> signInWithGoogle() async {
  setState(() => loading = true);

  try {
    UserCredential credential;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      credential = await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            "804162267714-bopev80m478ejvo026mg4bpao0occ6on.apps.googleusercontent.com",
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;

      final firebaseCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      credential = await FirebaseAuth.instance.signInWithCredential(
        firebaseCredential,
      );
    }

    final user = credential.user;
    if (user != null) {
      await saveUserProfile(user);
    }
  } on FirebaseAuthException catch (e) {
    showMessage(firebaseError(e.code));
  } on GoogleSignInException catch (e) {
    debugPrint("Google Sign-In Error: $e");
    showMessage("Google sign-in failed: ${e.toString()}");
  } catch (e) {
    debugPrint("Google Error: $e");
    showMessage(e.toString());
  } finally {
    if (mounted) setState(() => loading = false);
  }
}
Future<void> forgotPassword() async {
  final email = emailController.text.trim();

  if (email.isEmpty || !email.contains("@")) {
    showMessage("Enter your registered email first.");
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    showMessage(
      "Password reset link sent to $email. Check your inbox/spam folder.",
    );
  } on FirebaseAuthException catch (e) {
    showMessage(firebaseError(e.code));
  } catch (e) {
    showMessage("Failed to send reset email. Try again.");
  }
}
  String firebaseError(String code) {
  switch (code) {
    case "invalid-email":
      return "Invalid email address.";
    case "user-not-found":
      return "No account found with this email.";
    case "wrong-password":
      return "Wrong password.";
    case "email-already-in-use":
      return "This email is already registered.";
    case "weak-password":
      return "Use a stronger password.";
    case "network-request-failed":
      return "Network error. Check your internet.";
    case "popup-closed-by-user":
      return "Google sign-in was cancelled.";
    default:
      return "Something went wrong. Try again.";
  }
}
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 850;

    return Scaffold(
      body: AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  sin(animationController.value * 2 * pi) * 0.4,
                  cos(animationController.value * 2 * pi) * 0.4,
                ),
                radius: 1.3,
                colors: const [
                  Color(0xFF103B49),
                  Color(0xFF07111F),
                  Color(0xFF02040A),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: 90, left: 40, child: glowCircle(150)),
                Positioned(bottom: 120, right: 30, child: glowCircle(210)),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: isWide
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              heroPanel(),
                              const SizedBox(width: 36),
                              loginCard(),
                            ],
                          )
                        : loginCard(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget heroPanel() {
    return const SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield, size: 90, color: Colors.cyanAccent),
          SizedBox(height: 18),
          Text(
            "AI Powered\nFraud Protection",
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Detect scam messages, risky links, fraud numbers and protect your digital identity.",
            style: TextStyle(fontSize: 17, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget loginCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: sin(animationController.value * 2 * pi) * 0.08,
            child: Container(
              height: 105,
              width: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.55),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.security, size: 62, color: Colors.black),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            "CYBER SHIELD",
            style: TextStyle(
              fontSize: 31,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLogin
                ? "Secure access to your protection dashboard"
                : "Create your secure protection account",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: inputDecoration("Email Address", Icons.email_outlined),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: inputDecoration("Password", Icons.lock_outline)
                .copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: forgotPassword,
              child: const Text("Forgot password?"),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: loading ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      isLogin ? "LOGIN SECURELY" : "CREATE ACCOUNT",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: loading ? null : signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 34),
              label: const Text(
                "CONTINUE WITH GOOGLE",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.cyanAccent.withValues(alpha: 0.45),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              setState(() => isLogin = !isLogin);
            },
            child: Text(
              isLogin
                  ? "New here? Create account"
                  : "Already protected? Login",
            ),
          ),
        ],
      ),
    );
  }

  Widget glowCircle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyanAccent.withValues(alpha: 0.08),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.18),
            blurRadius: 70,
            spreadRadius: 25,
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.28),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.cyanAccent.withValues(alpha: 0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.4),
      ),
    );
  }
}