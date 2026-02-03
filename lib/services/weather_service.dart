import 'dart:convert'; // Gelen veriyi (JSON) çözmek için lazım olan kütüphane
import 'package:http/http.dart' as http; // İnternetle konuşmak için lazım (Postacı)
import '../models/weather_model.dart'; // Dün hazırladığım veri kalıbı (Model)

class WeatherService {
  final String apiKey = 'e1fc4b463fd8b528f099a3c2f5307a1a';
  
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> getWeather(String cityName) async { // Şehir Adını Al (cityName)
    
    final url = Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {// 200 "İşlem Başarılı" demektir.
      
      // gelen json'u dart ın anlayabileceği yapıya dönüştürüyorum
      final Map<String, dynamic> data = jsonDecode(response.body);

      // veriyi model nesnesine çeviriyorum
      return WeatherModel.fromJson(data);
    } else {
      //bir sorun varsa (mesela şehir bulunamadıysa), hata vermeli
      throw Exception('Veri gelmedi! Hata kodu: ${response.statusCode}');
    }
  }
}