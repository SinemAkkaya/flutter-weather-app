import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class LocationCard extends StatelessWidget {
  final WeatherModel weather;
  final bool
  isCurrentLocation; // "My Location" yazıp yazmayacağını anlamak için (şehir ismi altta olsun mu diye)
  final VoidCallback onTap; // tıklanınca detaya gitmek için

  const LocationCard({
    super.key,
    required this.weather,
    this.isCurrentLocation = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // kartların yüksekliği
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ), // karrtlar arasında boşluk
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // --- DİNAMİK ARKA PLAN RESMİ ---
          image: DecorationImage(
            image: AssetImage(_getBackgroundImage(weather.iconCode)),
            fit: BoxFit.cover,
            // resim çok parlakken yazılar okunmuyor diye bende hafif siyahlık koydum
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.25),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- SOL TARAFTAKİ BİLGİLER (Şehir, Saat, Durum) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Başlık (My Location veya Şehir Adı)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentLocation ? "My Location" : weather.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(blurRadius: 5, color: Colors.black45),
                          ],
                        ),
                      ),
                      // eğer My Location ise altında şehir adı yazsın figmada böyle
                      if (isCurrentLocation)
                        Text(
                          weather.cityName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  // Hava Durumu Açıklaması (alt kısım)
                  Text(
                    weather.description, // Parçalı bulutlu vs.
                    style: const TextStyle(
                      color: Colors.white, // Apple'da burası beyazdı
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // --- SAĞ TARAFTAKİ BİLGİLER (Derece, H: L:) ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sıcaklık
                  Text(
                    "${weather.temperature.round()}°",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48, // Büyük derece
                      fontWeight: FontWeight.w300, // İnce (Thin)
                      shadows: [Shadow(blurRadius: 5, color: Colors.black45)],
                    ),
                  ),

                  // En Yüksek / En Düşük
                  Text(
                    "H:${(weather.temperature + 5).round()}° L:${(weather.temperature - 5).round()}°",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- RESİM SEÇME FONKSİYONU (Aynısını koydum çünkü ana ekran gibi burda da resimler görünsün istiyorum) ---
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
