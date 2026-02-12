import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/storage_service.dart';
import 'weather_screen.dart';
import 'location_management_screen.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final StorageService _storageService = StorageService();
  final PageController _pageController = PageController();

  // Listemizin ilk elemanı GPS konumu için NULL olacak, diğerleri ise şehir isimleri olacak. Böylece PageView'da 0. sayfa GPS konumu, diğer sayfalar ise şehirler olacak.
  List<String?> _cities = [null];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    // servis zaten arka planda duplicate'leri siliyor bize temiz liste gelecek umarım
    final cleanCities = await _storageService.getCities();

    setState(() {
      // en başa NULL (GPS Konumu) koyuyorum gerisine temiz listeyi ekliyoruz
      _cities = [null, ...cleanCities];
    });
  }

  void _openListScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationManagementScreen()),
    );

    // listeden dönünce mutlaka verileri güncelle
    await _loadCities();

    if (result != null) {
      if (result == "GPS_LOCATION") {
        _pageController.jumpToPage(0);
      } else {
        final index = _cities.indexOf(result);
        if (index != -1) {
          _pageController.jumpToPage(index);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // BU SATIRI EKLEDİM: İçeriğin (PageView) alt barın arkasına geçmesine izin verir
      extendBody: true,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              // _cities[0] null olduğu için WeatherScreen kendi içinde GPS'i çalıştıracak
              return WeatherScreen(cityInput: _cities[index]);
            },
          ),

          // alt Bar
          // 2. KATMAN: ALT BAR (Alt Zemin ve Çizgi)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    //şeffaf zemin uaptım
                    color: Colors.black.withOpacity(0.1),
                    border: const Border(
                      top: BorderSide(
                        color: Colors.white24, // O grey çizgi rengi
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false, // üstten kısıtlamasın
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // harita ikonu
                          const SizedBox(width: 40),

                          if (_cities.length > 1)
                            SmoothPageIndicator(
                              controller: _pageController,
                              count: _cities.length,
                              effect: const WormEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: Colors.white,
                                dotColor: Colors.grey,
                                spacing: 8,
                              ),
                            ),

                          // liste Butonumm
                          IconButton(
                            icon: const Icon(
                              Icons.list,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _openListScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
