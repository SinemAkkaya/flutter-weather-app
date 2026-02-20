import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';

import 'dart:ui';

class WeatherScreen extends StatefulWidget {
  final String? cityInput;

  const WeatherScreen({super.key, this.cityInput});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();

  // scroll kontrolcüsü
  late ScrollController _scrollController;
  bool _showTitle = false; // başlık başta gizli

  Future<WeatherModel>? _weatherFuture;
  Future<List<ForecastModel>>? _forecastFuture;

  @override
  void initState() {
    super.initState();
    _initWeather();

    // Scroll dinleyicisini başlatıyorum
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      // Eğer 200 pikselden fazla aşağı kaydırıldıysa başlığı göster dedim çünkü en baştan gösteriyordu
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });
  }

  // sayfa kapanırken scroll kontrolcüsünü temizlemeliyim
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    // Status bar'ı şeffaf yapıp yazıları beyaz yaptım böylece arka planla bütünleşiyor ve okunabilir oluyor

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent, // Alt bar şeffaf
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // içeriğin alt barın arkasına geçmesini sağlar
      body: FutureBuilder<WeatherModel>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Yüklenirken siyah ekran ve loading
            return Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
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

          // --- ANA YAPI ---
          return Stack(
            children: [
              // 1. ARKA PLAN (Sabit duracak)
              Positioned.fill(
                child: Image.asset(
                  _getBackgroundImage(weather.iconCode),
                  fit: BoxFit.cover,
                ),
              ),

              // 2. SCROLL EDİLEBİLİR İÇERİK (CustomScrollView)
              // Küçülen başlık için bunu kullanmam şart yoksa bu küçülen başlığı elde edemedim
              CustomScrollView(
                controller: _scrollController, // Kontrolcüyü buraya bağladım
                physics: const BouncingScrollPhysics(), // apple tipi bir efekt
                slivers: [
                  // --- KÜÇÜLEN BAŞLIK (SLIVER APP BAR) ---
                  SliverAppBar(
                    expandedHeight: 350, // Açıkken kaplayacağı alan 350
                    pinned: true, // Yukarı yapışsın diye true dedim
                    backgroundColor:
                        Colors.transparent, // arka plan şeffaf olsun
                    elevation: 0,
                    stretch: true,

                    // Başlık (Sadece küçülünce görünen kısım - AnimatedOpacity ekledim)
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showTitle
                          ? 1.0
                          : 0.0, // _showTitle true ise görünür, false ise görünmez
                      child: Text(
                        weather.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    centerTitle: true,

                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: const EdgeInsets.only(bottom: 16),
                      // Buradaki title'ı yukarıdaki AnimatedOpacity içine taşıdım ve burayı sildim

                      // Arka plan büyütülünce görünecek olan içerik
                      background: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 60), // Status bar boşluğu
                          // Şehir Adı (Büyük)
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 5, color: Colors.black26),
                              ],
                            ),
                          ),

                          // Derece daha büyük ve ince
                          Text(
                            "${weather.temperature.round()}°",
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w200, // Thin
                              color: Colors.white,
                            ),
                          ),

                          // Durum (Partly Cloudy vb.)
                          Text(
                            weather.description, // API'den gelen açıklama
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // H:.. L:.. (Yüksek / Düşük)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                // gerçek en yüksek sıcaklık
                                "H:${weather.maxTemp.round()}° ",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                //gerçek en düşük sıcaklık
                                "L:${weather.minTemp.round()}°",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- SliverToBoxAdapter---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // summary box ve divider kaldırdım tasarıma benzemesi için

                          // --- SAATLİK TAHMİN (Hourly) ---
                          FutureBuilder<List<ForecastModel>>(
                            future: _forecastFuture,
                            builder: (context, forecastSnapshot) {
                              if (forecastSnapshot.hasData &&
                                  forecastSnapshot.data!.isNotEmpty) {
                                // açıklama artık burada parametre olarak geçiyor çünkü ayrı ayrı dursun istemiyorum
                                //buradaki açıklamada da artık gerçek maxTemp'i kullanıyorum
                                return HourlyForecastWidget(
                                  forecasts: forecastSnapshot.data!,
                                  description:
                                      "Today: ${weather.description}. The high will be ${weather.maxTemp.round()}°.",
                                );
                              }
                              return const SizedBox(height: 120);
                            },
                          ),

                          const SizedBox(height: 20),

                          // --- 5 GÜNLÜK TAHMİN (Daily) ---
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

                          // Bento Box figmada yoktu kaldırdım
                          // DERS NOTU: 5 günlük tahmin listesinin en altındaki günün (Salı),
                          // weather_home'daki blurlu alt navigasyon barının altında kalmaması için
                          // buradaki boşluğu 120 piksele çıkardım.
                          const SizedBox(height: 120), // En alta boşluk
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // arka plan fonksiyonum aynen duruyor
  String _getBackgroundImage(String? iconCode) {
    if (iconCode == null) return 'assets/images/night_bg.png';
    bool isNight = iconCode.endsWith('n');
    if (isNight) return 'assets/images/night_bg.png';
    if (iconCode.contains('01')) return 'assets/images/sunny.png';
    if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04') ||
        iconCode.contains('50'))
      return 'assets/images/cloudy.png';
    if (iconCode.contains('09') ||
        iconCode.contains('10') ||
        iconCode.contains('11'))
      return 'assets/images/rainy.png';
    if (iconCode.contains('13')) return 'assets/images/snowy.png';
    return 'assets/images/sunny.png';
  }
}
