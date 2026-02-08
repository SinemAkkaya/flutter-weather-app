import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forecast_model.dart';
import 'dart:math';

class DailyForecastWidget extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const DailyForecastWidget({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Verileri Günlere Grupla
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

    // önce döngüyle tüm günleri gezsin haftalık en fazlaları bulayım
    for (var dayKey in days) {
      var dayData = dailyGroups[dayKey]!;
      double dayMin = dayData.map((e) => e.temperature).reduce(min);
      double dayMax = dayData.map((e) => e.temperature).reduce(max);

      if (dayMin < weekMin) weekMin = dayMin;
      if (dayMax > weekMax) weekMax = dayMax;
    }

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.white54, size: 16),
              SizedBox(width: 8),
              Text(
                "5-GÜNLÜK TAHMİN",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            itemBuilder: (context, index) {
              String dayKey = days[index];
              List<ForecastModel> dayData = dailyGroups[dayKey]!;

              // O günün Min/Max değerleri
              double dayMin = dayData.map((e) => e.temperature).reduce(min);
              double dayMax = dayData.map((e) => e.temperature).reduce(max);

              ForecastModel representative = dayData[dayData.length ~/ 2];
              final dayName = DateFormat(
                'E',
              ).format(DateTime.parse(representative.date));
              final iconUrl =
                  "https://openweathermap.org/img/wn/${representative.icon}@2x.png";

              // --- MATEMATİKSEL HESAPLAMA ---
              // Çubuğun nerede başlayacağını ve ne kadar uzun olacağını hesaplıyor
              // totalRange: bu haftalık toplam sıcaklık farkı (Örn: hafta en az 10, en çok 20 ise range 10'dur)
              double totalRange = weekMax - weekMin;
              if (totalRange == 0)
                totalRange = 1; // sıfıra bölünme hatasını önlemek için (örneğin tüm hafta aynı sıcaklıksa)

              // normalizeMin: Çubuğun sol boşluğu 0 - 1 arası
              double normalizeMin = (dayMin - weekMin) / totalRange;
              // normalizeMax: Çubuğun genişliği 0-1 arası
              double normalizeWidth = (dayMax - dayMin) / totalRange;

              //Eğer(width 0 ise) en azından bir nokta kadar görünsün 
              if (normalizeWidth < 0.1) normalizeWidth = 0.1;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    // GÜN
                    SizedBox(
                      width: 50,
                      child: Text(
                        dayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // İKON
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.network(
                        iconUrl,
                        errorBuilder: (_, __, _) =>
                            const Icon(Icons.cloud, color: Colors.white),
                      ),
                    ),

                    // MIN DERECE
                    SizedBox(
                      width: 35,
                      child: Text(
                        "${dayMin.round()}°",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // --- Bar ---
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white10, // Arka plan (gri olan kısım)
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // stack kullanarak barı gri yolun içine yerleştiriyorum
                        child: Stack(
                          children: [
                            // align ile barı doğru yere kaydırıyoruz
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor:
                                    1.0, // tüm genişliği kullanacağım ama margin ile kısacağım çünkü yazılarımın üstüne çıkıp duruyor
                                child: Container(
                                  // Margin ile soldan ve sağdan iterek barı doğru yere sıkıştırıyorum
                                  margin: EdgeInsets.only(
                                    left: 100 * normalizeMin, //soldan hizalamaayarı
                                    right:
                                        100 *
                                        (1.0 -
                                            (normalizeMin +
                                                normalizeWidth)), //sağdan içeri iterek hizaladım
                                  ),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    // renk geçişleri (Mavi-Yeşil-Turuncu)
                                    gradient: LinearGradient(
                                      colors: _getGradientColors(dayMin),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // MAX DERECE
                    SizedBox(
                      width: 35,
                      child: Text(
                        "${dayMax.round()}°",
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
    );
  }

  // sıcaklığa göre renk değiştiren ekstra havalı fonksiyon 
  List<Color> _getGradientColors(double temp) {
    if (temp < 0) {
      return [Colors.blue, Colors.lightBlueAccent]; // çok soğuk
    } else if (temp < 15) {
      return [Colors.cyan, Colors.greenAccent]; // serin
    } else if (temp < 25) {
      return [Colors.green, Colors.orange]; // ılık
    } else {
      return [Colors.orange, Colors.red]; // sıcak
    }
  }
}
