import 'package:flutter/material.dart';
import 'services/weather_service.dart'; // Servisi çağırmak için gerrekli

void main() async {
  // Uygulama başlamadan önce test yapalım
  WidgetsFlutterBinding.ensureInitialized();
  
  final service = WeatherService();
  
  try {
    print(" Hava durumu getiriliyor...");
    
    //fonksiyonu çağırıyorum
    final weather = await service.getWeather('Ankara'); 
    
    print("BAŞARILI!");
    print("Şehir: ${weather.cityName}");
    print("Sıcaklık: ${weather.temperature}°C");
    print("Durum: ${weather.description}");
    
  } catch (e) {
    print("HATA: $e");
  }
  
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: Center(child: Text("Weatherapp"))));
  }
}