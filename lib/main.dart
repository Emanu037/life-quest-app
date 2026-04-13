import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/app_viewmodel.dart';
import 'views/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppViewModel(),
      child: MaterialApp(
        title: 'LifeQuest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          useMaterial3: true,
        ),
        home: const LoginPage(),
      ),
    ),
  );
}