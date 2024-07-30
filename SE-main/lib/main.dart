import 'package:bookshare/tests/screens/booklistscreen.dart';
import 'package:bookshare/tests/screens/otheruserprofile.dart';
import 'package:bookshare/tests/screens/splashscreen.dart';
import 'package:bookshare/tests/screens/userprofile.dart';

import 'package:app_links/app_links.dart';
import 'package:bookshare/tests/utils/deep_link_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bookshare/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:bookshare/tests/screens/Authentication/login.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

/* const kWindowsScheme = 'sample'; */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Deep Linking Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: DeepLinkHandler(),
//       routes: {
//         '/detailsScreen': (context) => DetailsScreen(),
//       },
//     );
//   }
// }

// class DetailsScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Details Screen'),
//       ),
//       body: Center(child: Text('This is the details screen!')),
//     );
//   }
// }


// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final _navigatorKey = GlobalKey<NavigatorState>();
//   late AppLinks _appLinks;
//   StreamSubscription<Uri>? _linkSubscription;

//   @override
//   void initState() {
//     initDeepLinks();
//     super.initState();
//   }

//     Future<void> initDeepLinks() async {
//     _appLinks = AppLinks();

//     // Handle links
//     _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
//       debugPrint('onAppLink: $uri');
//       openAppLink(uri);
//     });
//   }

//     void openAppLink(Uri uri) {
//     _navigatorKey.currentState?.pushNamed(uri.fragment);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return  MaterialApp(

//     );
//   }
// }



// 

// void main() async {

//   // final GoRouter _router = GoRouter(
//   //   routes: [
//   //     GoRoute(
//   //       path: '/',
//   //       builder: (context, state) => LoginTestPage(),
//   //       // LoginTestPage(),
//   //     ),
//   //     GoRoute(
//   //       path: '/user/:id',
//   //       builder: (context, state) {
//   //         final id = state.pathParameters['id']!;
//   //         return Otheruserprofile(userId: id);
//   //       },
//   //     ),
//   //   ],
//   //   errorBuilder: (context, state) => Scaffold(
//   //     body: Center(child: Text('Error: ${state.error}')),
//   //   ),
//   // );
//   final GoRouter _router = GoRouter(
//   initialLocation: '/',
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => LoginTestPage(),
//     ),
//     GoRoute(
//       path: '/user/:id',
//       builder: (context, state) {
//         final id = state.pathParameters['id']!;
//         return Otheruserprofile(userId: id);
//       },
//     ),
//   ],
//   errorBuilder: (context, state) {
//     print('Error: ${state.error}');
//     return Scaffold(
//       body: Center(child: Text('Error: ${state.error}')),
//     );
//   },
// );

//   runApp(MyApp(router: _router));
// }

// class MyApp extends StatefulWidget {
//   final GoRouter router;
//   MyApp({required this.router});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();
//     initUniLinks();
//   }

//   Future<void> initUniLinks() async {
//     _sub = uriLinkStream.listen((Uri? uri) {
//       if (uri != null) {
//         print('Received deep link: $uri');
//         widget.router.go(uri.path); // Navigate to the corresponding route
//       }
//     }, onError: (err) {
//       print('Error occurred while handling deep link: $err');
//     });
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routeInformationParser: widget.router.routeInformationParser,
//       routerDelegate: widget.router.routerDelegate,
//     );
//   }
// }

// void initDeepLink() async {
//   Uri? initialUri = await getInitialUri();

//   if (initialUri != null) {
//     handleDeepLink(initialUri);
//   }

//   uriLinkStream.listen((Uri? uri) {
//     if (uri != null) {
//       handleDeepLink(uri);
//     }
//   });
// }

// void handleDeepLink(Uri uri) {
//   // Handle the deep link logic, navigate to the booklist page
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => BooklistScreen()),
//   );
// }

// class TestLinkPage extends StatelessWidget {
//   const TestLinkPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text('Test Link Page'),
//       ),
//     );
//   }
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(routerConfig: router);
//   }
// }

// final router = GoRouter(initialLocation: '/', routes: [
//   GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) => Scaffold(
//             appBar: AppBar(
//               title: const Text('Home'),
//             ),
//             body: const Center(
//               child: Text('HomePage'),
//             ),
//           )),
//   GoRoute(
//       path: '/home',
//       builder: (BuildContext context, GoRouterState state) => Scaffold(
//               appBar: AppBar(
//             title: const Text('Test Link'),
//           )),
//       routes: [
//         GoRoute(
//             path: 'home2',
//             builder: (BuildContext context, GoRouterState state) => Scaffold(
//                     appBar: AppBar(
//                   title: const Text('Test Link 2'),
//                 )))
//       ])
// ]);