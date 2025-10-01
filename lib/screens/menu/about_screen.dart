import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // We'll add this package for links

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  // Helper to launch a URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // App Icon/Logo (Optional)
              Image.asset('assets/icon/launcher_icon.png', width: 80, height: 80), // You need to add this asset
              const SizedBox(height: 16),

              // App Name
              Text(
                _packageInfo.appName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // App Version
              Text(
                'Version ${_packageInfo.version} (${_packageInfo.buildNumber})',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // App Description
              const Text(
                'Official management system for the Momota Community Center. Streamline bookings, track finances, and manage operations on the go.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),

              // Developer Info
              Text(
                'Developed By',
                style: TextStyle(color: Colors.grey.shade700, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tipu Sultan', // <-- YOUR NAME/COMPANY HERE
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Contact/Website Link
              OutlinedButton.icon(
                icon: const Icon(Icons.public),
                label: const Text('Visit Our Website'),
                onPressed: () => _launchURL('https://umairit.com'), // <-- YOUR WEBSITE HERE
              ),
              
              const Spacer(),

              // Copyright Info
              Text(
                '© ${DateTime.now().year} Momota Community Center. All Rights Reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}