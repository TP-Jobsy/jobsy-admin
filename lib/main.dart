import 'package:flutter/material.dart';
import 'package:jobsy_admin/pages/login_page.dart';
import 'package:jobsy_admin/pages/portfolio_detail_page.dart';
import 'package:jobsy_admin/pages/portfolio_page.dart';
import 'package:jobsy_admin/pages/project_detail_page.dart';
import 'package:jobsy_admin/pages/projects_page.dart';
import 'package:jobsy_admin/pages/user_detail_page.dart';
import 'package:jobsy_admin/pages/users_screen.dart';
import 'package:jobsy_admin/provider/auth_provider.dart';
import 'package:jobsy_admin/util/palette.dart';
import 'package:jobsy_admin/util/routes.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AdminAuthProvider(baseUrl: Routes.apiBase);
  await authProvider.ensureLoaded();

  runApp(
    ChangeNotifierProvider.value(value: authProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    if (!auth.isLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Jobsy Admin',
      theme: ThemeData(
        scaffoldBackgroundColor: Palette.white,
        colorScheme: const ColorScheme.light(
          background: Palette.white,
          primary: Palette.black,
        ),
        useMaterial3: true,
      ),
      initialRoute: auth.isLoggedIn ? Routes.users : Routes.login,
      routes: {
        Routes.login: (_) => AdminLoginPage(),
        Routes.users: (_) => UsersPage(),
        Routes.projects: (_) => ProjectsPage(),
        Routes.portfolio: (_) => PortfoliosPage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.userDetail:
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder:
                  (_) =>
                      UserDetailPage(userId: args['id']!, role: args['role']!),
            );
          case Routes.projectDetail:
            final projectId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => ProjectDetailPage(projectId: projectId),
            );

          case Routes.portfolioDetail:
            final portfolioId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => PortfolioDetailPage(portfolioId: portfolioId),
            );
        }
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Страница не найдена')),
              ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
