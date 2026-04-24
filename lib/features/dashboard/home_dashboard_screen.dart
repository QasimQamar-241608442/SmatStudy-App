import 'package:flutter/material.dart';
import 'home_view.dart'; // This will be your actual Home Dashboard content once we build it out 
import 'semesters_view.dart'; // This will be your actual Semesters View content once we build it out
import 'package:firebase_auth/firebase_auth.dart'; // We will use this to implement the logout functionality in the Profile View later
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // This variable remembers which tab is currently active (0 = Home)
  int _selectedIndex = 0;

  // These are temporary placeholders for the 5 main sections of your app
static final List<Widget> _widgetOptions = <Widget>[
    const HomeView(), 
    const SemestersView(), 
    const Center(child: Text('Planner View Will Go Here', style: TextStyle(fontSize: 20))),
    const Center(child: Text('AI Assistant Will Go Here', style: TextStyle(fontSize: 20))),
    // Temporary Profile Tab to test logging out
    Center(
      child: ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut();
        },
        child: const Text('Log Out'),
      ),
    ),
  ];
  // This function runs every time a user taps a bottom navigation icon
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // The body dynamically changes based on the selected tab
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // THIS BLOCK: is used for the + Floating Action Button on the Home Dashboard
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We will build the "Add Task" modal later
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
      // Your minimalist Black & White Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planner'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Forces all 5 icons to stay visible
        onTap: _onItemTapped,
      ),
    );
  }
}