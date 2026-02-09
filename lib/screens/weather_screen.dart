import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';

class WeatherScreen extends StatefulWidget {
  final String? cityInput;

  const WeatherScreen({super.key, this.cityInput});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  Future<WeatherModel>? _weatherFuture;
  Future<List<ForecastModel>>? _forecastFuture;

  @override
  void initState() {
    super.initState();
    _initWeather();
  }

  void _initWeather() {
    if (widget.cityInput != null) {
      _weatherFuture = _weatherService.getWeather(widget.cityInput!);
      _forecastFuture = _weatherService.getForecast(widget.cityInput!);
    } else {
      _weatherFuture = _weatherService.getWeatherByLocation();
      _forecastFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: FutureBuilder<WeatherModel>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Hata: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) return const SizedBox();

          final weather = snapshot.data!;

          if (widget.cityInput == null &&
              (_forecastFuture == null ||
                  snapshot.connectionState == ConnectionState.done)) {
            _forecastFuture = _weatherService.getForecast(weather.cityName);
          }

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/night_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _initWeather();
                });
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 60, bottom: 40),
                child: Column(
                  children: [
                    // --- 1. ŞEHİR ADI ---
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 10, color: Colors.black45),
                        ],
                      ),
                    ),

                    // --- 2. SICAKLIK ---
                    Text(
                      "${weather.temperature.round()}°",
                      style: const TextStyle(
                        fontSize: 90,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),

                    // --- 3. DURUM ---
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ---Yenilendi ---
                    // eski Row yerine bu GridView geldi. !!
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.count(
                        shrinkWrap: true, // scrollda sorun olmasın diye
                        physics:
                            const NeverScrollableScrollPhysics(), // sayfayla beraber kayması için
                        crossAxisCount: 2, // yan yana 2 kutu
                        crossAxisSpacing: 15, // yatay boşluk
                        mainAxisSpacing: 15, // dikey boşluk
                        childAspectRatio: 1.6, // kutuların şekli
                        children: [
                          // 1. nem
                          _buildDetailCard(
                            "Humidity",
                            "%${weather.humidity}",
                            Icons.water_drop,
                            Colors.blueAccent,
                          ),
                          // 2. rüzgar
                          _buildDetailCard(
                            "Wind",
                            "${weather.windSpeed} km/h",
                            Icons.air,
                            Colors.grey,
                          ),
                          // 3. hissedilen
                          _buildDetailCard(
                            "Feels Like",
                            "${weather.feelsLike.round()}°",
                            Icons.thermostat,
                            Colors.orangeAccent,
                          ),
                          // 4. basınç
                          _buildDetailCard(
                            "Pressure",
                            "${weather.pressure} hPa",
                            Icons.speed,
                            Colors.lightBlue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // saatlik tahmin
                    FutureBuilder<List<ForecastModel>>(
                      future: _forecastFuture,
                      builder: (context, forecastSnapshot) {
                        if (forecastSnapshot.hasData &&
                            forecastSnapshot.data!.isNotEmpty) {
                          return HourlyForecastWidget(
                            forecasts: forecastSnapshot.data!,
                          );
                        }
                        return const SizedBox(height: 120);
                      },
                    ),

                    const SizedBox(height: 20),

                    // günlük tahmin
                    FutureBuilder<List<ForecastModel>>(
                      future: _forecastFuture,
                      builder: (context, forecastSnapshot) {
                        if (forecastSnapshot.hasData &&
                            forecastSnapshot.data!.isNotEmpty) {
                          return DailyForecastWidget(
                            forecasts: forecastSnapshot.data!,
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- kartları çizen yardımcı fonksiyon---

  Widget _buildDetailCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withOpacity(0.8), // koyu renk
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10), //çerçeve
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //bsşlık veikon
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // değer
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
