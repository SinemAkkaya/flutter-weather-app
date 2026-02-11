import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import 'dart:ui'; // ImageFilter için ekledim

class HourlyForecastWidget extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const HourlyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // --- tek büyük container ---
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blur
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withOpacity(0.4), // şeffaflık arttı
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ), // ince çerçeve
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white54, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "HOURLY FORECAST",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing:
                            0.5, //harf aralığını açmak görüntü için daha iyi
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12),

              // yatay liste
              SizedBox(
                height: 110, // yüksekliği biraz azalttım daha derli toplu olsun
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecasts.length > 12 ? 12 : forecasts.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (context, index) {
                    final forecast = forecasts[index];

                    // tarihi saate çevir
                    final timeText = DateFormat(
                      'HH:mm',
                    ).format(DateTime.parse(forecast.date));
                    final temp = "${forecast.temperature.round()}°";

                    // ikon için OpenWeatherMap'ten resim geliyor
                    final iconUrl =
                        "https://openweathermap.org/img/wn/${forecast.icon}@2x.png";

                    // tek kartta tüm saat bilgisi ikon ve dereceyi göstermek için bir sütun kullanıyorum
                    return Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SAAT
                          Text(
                            index == 0 ? "Now" : timeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // İKON
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Image.network(
                              iconUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.cloud,
                                    color: Colors.white54,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // DERECE
                          Text(
                            temp,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
