import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

import '../models/forecast_model.dart';

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

  //yeni ekledim tahmin verisi için
  late Future<List<ForecastModel>> _forecastFuture;

  //yeni ekledim arama çubuğu koymak için
  final TextEditingController _controller = TextEditingController();

  bool _isSearching = false;

  void _searchCity() async {
    final cityName = _controller.text;
    if (cityName.isNotEmpty) {
      setState(() {
        _weatherFuture = _weatherService.getWeather(cityName);
        _forecastFuture = _weatherService.getForecast(cityName);

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
    _forecastFuture = Future.value(
      [],
    ); //başlangıçta boş liste hata almamak için
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
        // listeyi ekleyince ekran boyunu aştı kaydırma özelliği eklenmesi gerek
        child: SingleChildScrollView(
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
                            const Icon(
                              Icons.air,
                              color: Colors.white,
                              size: 30,
                            ),
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

                    // --- 5 günlük tahmin ---
                    const SizedBox(height: 40), //araya biraz boşluk
                    const Text(
                      "5-Day Forecast",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // İkinci FutureBuilder
                    FutureBuilder<List<ForecastModel>>(
                      future: _forecastFuture,
                      builder: (context, snapshotForecast) {
                        if (snapshotForecast.hasData) {
                          final forecastList = snapshotForecast.data!;

                          // eğer liste boş sa hiçbir şey gösterme
                          if (forecastList.isEmpty) return const SizedBox();

                          // listeyi göstermek için Container içine ListView koyuyorum
                          return Container(
                            height: 400, // listenin kaplayacağı yükseklik
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.builder(
                              physics:
                                  const NeverScrollableScrollPhysics(), // kaydırmayı kapatıyorum çünkü dışarıda zaten kaydırma var
                              shrinkWrap: true,
                              itemCount: forecastList.length,
                              itemBuilder: (context, index) {
                                final item = forecastList[index];

                                // tarihi düzeltme kısmı raw data yerine gelecek
                                final date = DateTime.parse(item.dayName);
                                final List<String> weekDays = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun",
                                ];
                                final String dayName =
                                    weekDays[date.weekday - 1];

                                return Card(
                                  color: Colors.white.withOpacity(
                                    0.1,
                                  ), // hafif şeffaf kart
                                  child: ListTile(
                                    leading: Image.network(
                                      item.iconUrl,
                                      width: 50,
                                    ),
                                    title: Text(
                                      dayName, // item.dayName yerine dayName değişkenini koydum
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            18, // Biraz büyüttüm daha şık dursun diye
                                        fontWeight:
                                            FontWeight.bold, // Kalınlaştırdım
                                      ),
                                    ),
                                    trailing: Text(
                                      "${item.temperature.round()}°",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const SizedBox(); // veri yoksa gösterme
                      },
                    ),

                    // --- 5 günlük tahmin bitti ---
                  ],
                );
              }

              //hiçbiri yoksa boş döndürsün
              return const Text("Veri yok");
            },
          ),
        ),
      ),
    );
  }
}
