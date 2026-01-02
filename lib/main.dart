import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/providers/auth_provider.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/providers/category_provider.dart';
import 'package:todo_app/pages/login_page.dart';
import 'package:todo_app/pages/home_page.dart';
import 'package:todo_app/pages/add_task_page.dart';
import 'package:todo_app/pages/add_category_page.dart';
import 'package:todo_app/pages/edit_task_page.dart';
import 'package:todo_app/pages/sign_up_page.dart';
import 'package:todo_app/pages/splash_page.dart';
import 'package:todo_app/constants/constants.dart';
import 'package:todo_app/models/task_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({required this.prefs, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            firebaseAuth: firebase_auth.FirebaseAuth.instance,
            firebaseFirestore: FirebaseFirestore.instance,
            prefs: prefs,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseAuth: firebase_auth.FirebaseAuth.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseAuth: firebase_auth.FirebaseAuth.instance,
          ),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        theme: ThemeData(
          primaryColor: ColorConstants.themeColor,
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashPage(),
          '/login': (context) => const LoginPage(),
          '/sign_up': (context) => const SignUpPage(),
          '/home': (context) => const HomePage(),
          '/add_task': (context) => const AddTaskPage(),
          '/add_category': (context) => const AddCategoryPage(),
          '/edit_task': (context) => EditTaskPage(
            task: ModalRoute.of(context)!.settings.arguments as TaskModel,
          ),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
