import 'dart:convert'; // Gelen veriyi (JSON) çözmek için lazım olan kütüphane
import 'package:http/http.dart' as http; // İnternetle konuşmak için lazım
import 'package:geolocator/geolocator.dart'; // GPS paketi
import '../models/weather_model.dart'; // Dün hazırladığım veri kalıbı

class WeatherService {
  final String apiKey = 'e1fc4b463fd8b528f099a3c2f5307a1a';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // --- FONKSİYON 1: Şehir İsmine Göre Getiren fonksiyonum ---
  // 1. Future: gelcekte bir fonksiyon gelecek diyor
  // 2. async:bu fonksiyonun içine beklemeli işler var diyor
  Future<WeatherModel> getWeather(String cityName) async {
    final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric');

    // 3. await:
    // Kod burada durup internetten cevap gelmesini bekliyor.
    // Eğer 'await' yazmazsam kod cevap gelmesini beklemeden alt satıra geçerve null hatası alırım
    final response = await http.get(url);

    if (response.statusCode == 200) {
      //200 işlem başarılıdemek
      // gelen json'u dart ın anlayabileceği yapıya dönüştürüyorum
      final Map<String, dynamic> data = jsonDecode(response.body);

      // veriyi model nesnesine çeviriyorum
      return WeatherModel.fromJson(data);
    } else {
      //bir sorun varsa (mesela şehir bulunamadıysa), hata vermeli
      throw Exception('Veri gelmedi! Hata kodu: ${response.statusCode}');
    }
  }

  // --- Fonksiyon 2: GPS konumuna göre getiren fonksiyonum ---
  Future<WeatherModel> getWeatherByLocation() async {
    // 1. İzin Kontrolü
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni verilmedi.');
      }
    }

    // 2. Konumu Bul
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3. urlOluştur
    final url = Uri.parse(
      '$baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return WeatherModel.fromJson(data);
    } else {
      throw Exception('Hata kodu: ${response.statusCode}');
    }
  }
}
