import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stackit_frontend/config/theme.dart';
import 'package:stackit_frontend/presentation/providers/auth_provider.dart';
import 'package:stackit_frontend/presentation/widgets/common/bottom_navigation.dart';
import 'package:stackit_frontend/presentation/routes/app_routes.dart';
import 'package:stackit_frontend/presentation/screens/home/question_list_screen.dart';
import 'package:stackit_frontend/presentation/screens/search/search_screen.dart';
import 'package:stackit_frontend/presentation/screens/profile/profile_screen.dart';
import 'package:stackit_frontend/presentation/screens/notification/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NavigationItem _currentItem = NavigationItem.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  void _checkAuthentication() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _onItemSelected(NavigationItem item) {
    setState(() {
      _currentItem = item;
    });

    if (item == NavigationItem.askQuestion) {
      Navigator.pushNamed(context, AppRoutes.askQuestion);
    }
  }

  Widget _buildBody() {
    switch (_currentItem) {
      case NavigationItem.home:
        return const QuestionListScreen();
      case NavigationItem.search:
        return const SearchScreen();
      case NavigationItem.notifications:
        return const NotificationScreen();
      case NavigationItem.profile:
        return const ProfileScreen();
      default:
        return const QuestionListScreen();
    }
  }

  String _getAppBarTitle() {
    switch (_currentItem) {
      case NavigationItem.home:
        return 'StackIt';
      case NavigationItem.search:
        return 'Search';
      case NavigationItem.notifications:
        return 'Notifications';
      case NavigationItem.profile:
        return 'Profile';
      default:
        return 'StackIt';
    }
  }

  List<Widget>? _buildAppBarActions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return [
      if (_currentItem == NavigationItem.home)
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Open filter dialog
          },
        ),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 2,
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigation(
        currentItem: _currentItem,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
