import 'dart:convert'; // Gelen veriyi (JSON) çözmek için lazım olan kütüphane
import 'package:http/http.dart' as http; // İnternetle konuşmak için lazım
import 'package:geolocator/geolocator.dart'; // GPS paketi
import '../models/weather_model.dart';
import '../models/forecast_model.dart'; // Hava durumu modelimi içe akrardım
import 'package:flutter_dotenv/flutter_dotenv.dart'; // .env dosyasını kullanmak için

class WeatherService {
  final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  final String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // --- FONKSİYON 1: Şehir İsmine Göre Getiren fonksiyonum ---
  // 1. Future: gelcekte bir fonksiyon gelecek diyor
  // 2. async:bu fonksiyonun içine beklemeli işler var diyor
  Future<WeatherModel> getWeather(String cityName) async {
    // YENİ: '/weather' kelimesini buraya ekledim
    final url = Uri.parse(
      '$baseUrl/weather?q=$cityName&appid=$apiKey&units=metric',
    );

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
    //buraya da '/weather' kelimesini ekledim
    final url = Uri.parse(
      '$baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
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
    // artık burası düzgün çalışıyor '/forecast' ekleyince sorun olmuyor
    final url = Uri.parse(
      '$baseUrl/forecast?q=$cityName&appid=$apiKey&units=metric',
    ); // BaseUrl kullandım

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> listData = data['list'];

      //filtreyi kaldırdım çünkü 3 saatlik tahminleri göstermek istiyorum
      return listData.map((item) => ForecastModel.fromJson(item)).toList();
    } else {
      throw Exception('Tahmin verisi gelmedi: ${response.statusCode}');
    }
  }
}
