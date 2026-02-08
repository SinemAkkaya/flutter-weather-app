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
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData) return const SizedBox();

          final weather = snapshot.data!;
          
          if (widget.cityInput == null && (_forecastFuture == null || snapshot.connectionState == ConnectionState.done)) {
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
              onRefresh: () async { setState(() { _initWeather(); }); },
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
                        shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
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

                    // --- nem ve rüzgar (bunu yanlışlıkla silmişitm)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // nem (Humidity)
                        Column(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blueAccent, size: 28),
                            const SizedBox(height: 5),
                            const Text("Humidity", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("%${weather.humidity}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 50), // araya boşluk
                        // rğzgar (Wind)
                        Column(
                          children: [
                            const Icon(Icons.air, color: Colors.white, size: 28),
                            const SizedBox(height: 5),
                            const Text("Wind", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("${weather.windSpeed} km/h", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),

                    // --- 5. SAATLİK TAHMİN ---
                    FutureBuilder<List<ForecastModel>>(
                      future: _forecastFuture,
                      builder: (context, forecastSnapshot) {
                         if (forecastSnapshot.hasData && forecastSnapshot.data!.isNotEmpty) {
                           return HourlyForecastWidget(forecasts: forecastSnapshot.data!);
                         }
                         return const SizedBox(height: 120);
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- 6. GÜNLÜK TAHMİN (O Çubuklu Liste) ---
                    FutureBuilder<List<ForecastModel>>(
                      future: _forecastFuture,
                      builder: (context, forecastSnapshot) {
                         if (forecastSnapshot.hasData && forecastSnapshot.data!.isNotEmpty) {
                           return DailyForecastWidget(forecasts: forecastSnapshot.data!);
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
}