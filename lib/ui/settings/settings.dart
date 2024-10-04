import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/discovery/Discovery.dart';
import 'package:music_app/ui/widget/showToast.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const SettingTabPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SettingTabPage extends StatefulWidget {
  const SettingTabPage({super.key});

  @override
  State<SettingTabPage> createState() => _SettingTabPageState();
}

class _SettingTabPageState extends State<SettingTabPage> {
  bool isDarkMode = false;
  String selectedLanguage = 'English';

  // Biến để kiểm tra xem người dùng đã đăng nhập hay chưa
  User? currentUser = FirebaseAuth.instance.currentUser;

  // Hàm chuyển đổi chế độ tối
  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  // Hàm thay đổi ngôn ngữ
  void changeLanguage(String? language) {
    setState(() {
      selectedLanguage = language!;
    });
  }

  void changeLanguageToVietnamese() {
    setState(() {
      selectedLanguage = 'Vietnamese';
    });
  }

  // Hàm logout
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      currentUser = null; // Sau khi logout, reset trạng thái người dùng
    });
    showToast(message: "Successfully Logout!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            selectedLanguage == 'English' ? 'Settings' : 'Thiết lập',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                currentUser == null
                    ? Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: Text(selectedLanguage == 'English'
                                ? 'Login'
                                : 'Đăng nhập'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              );
                            },
                            child: Text(selectedLanguage == 'English'
                                ? 'Register'
                                : 'Đăng ký'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Text(
                            selectedLanguage == 'English'
                                ? "Hi, ${currentUser?.email}"
                                : "Chào,${currentUser?.email}",
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _logout, // Nút logout
                            child: Text(
                              selectedLanguage == 'English'
                                  ? 'Logout'
                                  : 'Đăng xuất',
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              selectedLanguage == 'English'
                  ? 'Application Theme'
                  : 'Chọn chế độ',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedLanguage == 'English' ? 'Dark mode' : 'Chọn nền tối',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: isDarkMode,
                  onChanged: toggleTheme,
                  activeColor: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              selectedLanguage == 'English'
                  ? 'Transfer Language Option'
                  : 'Chuyển đổi ngôn ngữ',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedLanguage,
              items: <String>['English', 'Vietnamese'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                changeLanguage(newValue);
                if (newValue == 'Vietnamese') {
                  changeLanguageToVietnamese();
                }
              },
              dropdownColor: isDarkMode ? Colors.black : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
