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

  @override
  void initState() {
    super.initState();
    // ekran ilk açıldığında (viewDidLoad gibi) ankara'nın verisini iste
    _weatherFuture = _weatherService.getWeather('Ankara');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //apple stili koyu arka plan
      backgroundColor: Colors.black,
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

              // şimdilik basit tasarım
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    weather.getIconUrl(), 
                    width: 100,      
                    height: 100,     
                  ),
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
                            "Nem",
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
                            "Rüzgar",
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
