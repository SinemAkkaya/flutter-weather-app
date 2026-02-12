import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Dotenv paketini ekledim
import 'screens/weather_home.dart'; // Ana ekranı çağırdım

void main() async {
  // Flutter başlatılmadan önce gerekli bağlamaları yaptım
  WidgetsFlutterBinding.ensureInitialized();

  // Ayarları (.env) yüklemeye çalıştım
  // Dosya yoksa bile uygulama beyaz ekranda kalmasın diye try-catch bloğu ekledim
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      ".env dosyası bulunamadı ama uygulama açılmaya devam edecek: $e",
    );
  }

  // Uygulamayı başlattım
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Debug yazısını kaldırdım
      title: 'Weather App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Arka planı siyah yaptım
        primaryColor: Colors.white,
      ),
      // Uygulama açılınca direkt ana ekrana yönlendirdim
      home: const WeatherHome(),
    );
  }
}
