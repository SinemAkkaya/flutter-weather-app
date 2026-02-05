import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  //servis çağırıyorum
  final WeatherService _weatherService = WeatherService();

  //veriyi tutacak değişken
  late Future<WeatherModel> _weatherFuture;

  //yeni ekledim arama çubuğu koymak için
  final TextEditingController _controller = TextEditingController();

  bool _isSearching = false;

  void _searchCity() async {
    final cityName = _controller.text;
    if (cityName.isNotEmpty) {
      setState(() {
        _weatherFuture = _weatherService.getWeather(cityName);
        _isSearching = false; // arama kapansın
      });
      _controller.clear(); // kutuyu temizle
    }
  }

  @override
  void initState() {
    super.initState();
    // gps fonksiyonunu çağırıyorum
    _weatherFuture = _weatherService.getWeatherByLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //apple stili koyu arka plan
      backgroundColor: Colors.black,

      // --- app bar arama butonu  ---
      appBar: AppBar(
        backgroundColor: Colors.transparent, // arkaplan şeffaf
        elevation: 0, // shadow yok
        // Eğer _isSearching TRUE ise -> TextField (Yazı alanı) göster
        // Eğer _isSearching FALSE ise -> Text (Başlık) göster
        title: _isSearching
            ? TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white), // Yazı rengi beyaz
                decoration: const InputDecoration(
                  hintText: "Enter City Name",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none, // Alt çizgiyi kaldırdım çirkindi
                ),
                autofocus: true, // Açıldığı gibi klavye gelsin
                onSubmitted: (value) {
                  _searchCity(); // Klavyeden git tuşuna basınca ara
                },
              )
            : const Text("Weather App"), // Arama yoksa başlık kalsın

        actions: [
          IconButton(
            // arama varsa 'X' kapat, yoksa büyüteç işareti ara demek
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  // eğer arama açıksa ve basıldıysa -> kkapat ve temizle
                  _isSearching = false;
                  _controller.clear();
                } else {
                  // eğer kapalıysa ve basıldıysa -> arama modunu aç
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),

      body: Center(
        // FutureBuilder: async yani beklemeli bir iş olacağı için bunu kullanmalıyım yoksa veri gelene kadar uygulama çökmüş gibi olur
        child: FutureBuilder<WeatherModel>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            //hala yükleniyor mu?
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: Colors.white);
            }

            //hata var mı?
            if (snapshot.hasError) {
              return Text(
                "Hata: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              );
            }

            //veri geldi mi?
            if (snapshot.hasData) {
              final weather = snapshot.data!;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(weather.iconUrl, width: 100, height: 100),

                  // şehir İsmi
                  Text(
                    weather.cityName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10), //boşluk bıraktık
                  // sıcaklık
                  Text(
                    "${weather.temperature.round()}°", // .round() ile küsüratı kaldırılıyor
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                    ),
                  ),

                  //durum acıklaması
                  Text(
                    weather.description.toUpperCase(),
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly, // spaceEvenly adından anlaşıldığı gibi eşit aralıklı olsun demek
                    children: [
                      // nem
                      Column(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Humidity",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "%${weather.humidity}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      // Rüzgar
                      Column(
                        children: [
                          const Icon(Icons.air, color: Colors.white, size: 30),
                          const SizedBox(height: 5),
                          const Text(
                            "Wind Speed",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${weather.windSpeed} km/h",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            }

            //hiçbiri yoksa boş döndürsün
            return const Text("Veri yok");
          },
        ),
      ),
    );
  }
}
