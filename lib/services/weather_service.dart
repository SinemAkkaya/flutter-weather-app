import 'dart:convert'; // Gelen veriyi (JSON) çözmek için lazım olan kütüphane
import 'package:http/http.dart' as http; // İnternetle konuşmak için lazım
import 'package:geolocator/geolocator.dart'; // GPS paketi
import '../models/weather_model.dart';
import '../models/forecast_model.dart'; // Hava durumu modelimi içe akrardım
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env dosyasını kullanmak için

class WeatherService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
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

  // --- yeni fonksiyonum  ---
  Future<List<ForecastModel>> getForecast(String cityName) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // JSON'un içinde "list" diye bir dizi var onu ham haliyle al demek
      final List<dynamic> rawList = data['list'];

      //sadece saat 12de gelen veriyi seçiyorum bir sürü geldiği için, çünkü her 3 saatte bir veri geliyor
      final filteredList = rawList.where((item) {
        final dateText = item['dt_txt'] as String;
        return dateText.contains('12:00:00');
      }).toList();

      // artık elimde sadece 5 tane veri var
      return filteredList.map((item) => ForecastModel.fromJson(item)).toList();
    } else {
      throw Exception('Tahmin verisi gelmedi: ${response.statusCode}');
    }
  }
}
