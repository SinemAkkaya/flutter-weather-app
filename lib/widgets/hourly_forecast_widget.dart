import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import 'dart:ui'; // ImageFilter için ekledim

class HourlyForecastWidget extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const HourlyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "HOURLY FORECAST",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5, //harf aralığını açmak görüntü için daha iyi
            ),
          ),
        ),

        // yatay liste
        SizedBox(
          height: 110, // yüksekliği biraz azalttım daha derli toplu olsun
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: forecasts.length > 12 ? 12 : forecasts.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

              // ---artık şeffaf kartlar ---
              return Container(
                width: 70,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Blur
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E).withOpacity(
                          0.3,
                        ), // şeffaflık arttı
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ), // ince çerçeve
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SAAT
                          Text(
                            timeText,
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
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}