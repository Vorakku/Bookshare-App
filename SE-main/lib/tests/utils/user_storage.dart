import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

const storage = FlutterSecureStorage();

Future<void> saveUser(User user, String token) async {
  try {
    await storage.write(key: 'user_id', value: user.id);
    await storage.write(key: 'user_name', value: user.username);
    await storage.write(key: 'user_email', value: user.email);
    await storage.write(key: 'auth_token', value: token);
  } on Exception catch (e) {
    print('Error in saveUser: $e');
  }
}

Future<User?> getUser() async {
  try {
    String? id = await storage.read(key: 'user_id');
    String? username = await storage.read(key: 'user_name') ?? '';
    String? email = await storage.read(key: 'user_email');
    String? token = await storage.read(key: 'auth_token');

    if (id != null && email != null && token != null) {
      return User(id: id, username: username, email: email, token: token);
    } else {
      print('One or more user details are null');
    }
  } catch (e) {
    print('Error in getUser:  $e');
  }

  return null;
}  
// name != null &&

    // print('Creating User Object with id: $id, username: $username, email: $email');
  // print(
  //   'Saving User Object with id: ${user.id}, username: ${user.username}, email: ${user.email}, token: $token');
    // print('Retrieved user: $id, $name, $email'); // Debugging statement
  // Debugging statements

  // print('Retrieved user id: $id');
  // print('Retrieved user name: $username');
  // print('Retrieved user email: $email');
  // print('Retrieved token: $token');
  // await storage.deleteAll();
  // await storage.write(key: 'user_id', value: '123');
  // await storage.write(key: 'user_name', value: 'JohnDoe');
  // await storage.write(key: 'user_email', value: 'john@example.com');