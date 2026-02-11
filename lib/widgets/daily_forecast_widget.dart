import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import 'dart:math';
import 'dart:ui'; // ImageFilter için

class DailyForecastWidget extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const DailyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Verileri Günlere Göre Grupla
    Map<String, List<ForecastModel>> dailyGroups = {};
    for (var forecast in forecasts) {
      String dateKey = forecast.date.split(' ')[0];
      if (!dailyGroups.containsKey(dateKey)) {
        dailyGroups[dateKey] = [];
      }
      dailyGroups[dateKey]!.add(forecast);
    }
    List<String> days = dailyGroups.keys.take(5).toList();

    // 2. ADIM: TÜM HAFTANIN En Düşük ve En Yüksek Derecesini Bul
    double weekMin = 100;
    double weekMax = -100;

    for (var dayKey in days) {
      var dayData = dailyGroups[dayKey]!;
      double dayMin = dayData.map((e) => e.temperature).reduce(min);
      double dayMax = dayData.map((e) => e.temperature).reduce(max);

      if (dayMin < weekMin) weekMin = dayMin;
      if (dayMax > weekMax) weekMax = dayMax;
    }

    // --- buzlu cam ekledim ---
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // buzlu cam yaptım
        child: Container(
          width: double.infinity, //genişliği arttırdım
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(
              0xFF1C1C1E,
            ).withOpacity(0.5), // Yarı şeffaf siyah
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ), // ince beyaz çerçeve
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.white54, size: 16),
                  SizedBox(width: 8),
                  Text(
                    "5-DAY FORECAST",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  String dayKey = days[index];
                  List<ForecastModel> dayData = dailyGroups[dayKey]!;

                  // O günün Min/Max değerleri
                  double dayMin = dayData.map((e) => e.temperature).reduce(min);
                  double dayMax = dayData.map((e) => e.temperature).reduce(max);

                  ForecastModel representative = dayData[dayData.length ~/ 2];
                  final dayName = DateFormat(
                    'EEE',
                  ).format(DateTime.parse(representative.date));
                  final iconUrl =
                      "https://openweathermap.org/img/wn/${representative.icon}@2x.png";

                  // --- MATEMATİKSEL HESAPLAMA ---
                  double totalRange = weekMax - weekMin;
                  if (totalRange == 0) totalRange = 1;

                  // 1. Normalize değerler (0.0 ile 1.0 arası)
                  double normalizeMin = (dayMin - weekMin) / totalRange;
                  double normalizeWidth = (dayMax - dayMin) / totalRange;

                  // 2. Bar çok küçük olmasın diye min genişlik veriyoruz
                  if (normalizeWidth < 0.1) normalizeWidth = 0.1;

                  // 3. taşmayı engellemek için
                  // Eğer başlangıç noktası + genişlik 1.0'ı geçerse (sağdan taşarsa) başlangıç noktasını sola çek demek
                  if (normalizeMin + normalizeWidth > 1.0) {
                    normalizeMin = 1.0 - normalizeWidth;
                  }

                  // 4. negatif kontrolü Ne olur ne olmaz hata almak istemiyorum)
                  if (normalizeMin < 0.0) normalizeMin = 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ), //araları açtım
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1. GÜN ADI
                        SizedBox(
                          width: 60,
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // 2. İKON
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, _) =>
                                const Icon(Icons.cloud, color: Colors.white54),
                          ),
                        ),

                        // 3. MIN DERECE
                        SizedBox(
                          width: 40,
                          child: Text(
                            "${dayMin.round()}°",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // --- Bar) ---
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double maxWidth = constraints.maxWidth;
                                return Stack(
                                  children: [
                                    // Arka plan çizgisi
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    // Renkli Derece Çubuğu
                                    Container(
                                      height: 6,
                                      // artık negatif margin hatası almayacağım
                                      margin: EdgeInsets.only(
                                        left: maxWidth * normalizeMin,
                                        right:
                                            maxWidth *
                                            (1.0 -
                                                (normalizeMin +
                                                    normalizeWidth)),
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _getGradientColors(dayMin),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        // 4. MAX DERECE
                        SizedBox(
                          width: 40,
                          child: Text(
                            "${dayMax.round()}°",
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- renkler yenilendi ---
  List<Color> _getGradientColors(double temp) {
    if (temp < 0) {
      return [const Color(0xFF4064F6), const Color(0xFF63A4FF)];
    } else if (temp < 10) {
      return [const Color(0xFF53A9FF), const Color(0xFF8AE8FF)];
    } else if (temp < 20) {
      return [const Color(0xFF75D9F0), const Color(0xFF96E673)];
    } else if (temp < 30) {
      return [const Color(0xFF96E673), const Color(0xFFFFC63F)];
    } else {
      return [const Color(0xFFFFC63F), const Color(0xFFFF5050)];
    }
  }
}
