import 'package:firebase_auth/firebase_auth.dart' as FirebaseUser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class UserController {
  Future<FirebaseUser.User?> loginWithGoogle() async {
    try {
      // Sign out from previous Google account
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final FirebaseUser.User? user = authResult.user;

      if (user != null) {
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser.User? currentUser = FirebaseAuth.instance.currentUser;
        assert(user.uid == currentUser!.uid);

        print('signInWithGoogle succeeded: $user');

        return user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
    return null;
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    print("User Signed Out");
  }
}
