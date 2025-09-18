import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../constants/user_types.dart';
import 'user_type_selection_screen.dart';
import 'home_screen.dart';
import 'professor_home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is signed in, determine their type and route accordingly
          return FutureBuilder<UserType?>(
            future: AuthService().getUserType(snapshot.data!.uid),
            builder: (context, userTypeSnapshot) {
              if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (userTypeSnapshot.hasData) {
                if (userTypeSnapshot.data == UserType.professor) {
                  return ProfessorHomeScreen(
                    professorName: snapshot.data!.displayName ?? "Professor",
                  );
                } else {
                  return const HomeScreen();
                }
              }

              // If no user type found, sign out and go to selection
              AuthService().signOut();
              return const UserTypeSelectionScreen();
            },
          );
        }

        // User is not signed in
        return const UserTypeSelectionScreen();
      },
    );
  }
}
