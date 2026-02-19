import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart';
import '../widgets/location_card.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  final StorageService _storageService = StorageService();
  final WeatherService _weatherService = WeatherService();

  List<String> _savedCities = [];
  // TextEditingController ve _isSearching sildim çünkü artık Apple tarzı SearchDelegate kullanıyorum

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final cities = await _storageService.getCities();
    setState(() {
      _savedCities = cities.toSet().toList();
    });
  }

  Future<void> _addCity(String city) async {
    try {
      await _weatherService.getWeather(city);
      if (city.isNotEmpty && !_savedCities.contains(city)) {
        await _storageService.addCity(city);
        await _loadCities();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "We couldn’t find this city. Please check the spelling and try again.",
            ),
          ),
        );
      }
    }
  }

  Future<void> _removeCity(String city) async {
    setState(() {
      _savedCities.remove(city);
    });
    await _storageService.removeCity(city);
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. AYAR: SİSTEM BARLARINI ŞEFFAF YAP ---
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent, // Alt bar şeffaf olsun
        systemNavigationBarIconBrightness: Brightness.light, // İkonlar beyaz
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar'ı kaldırdım yerine coulmn geldi
      body: SafeArea(
        bottom:
            false, // Alt tarafı SafeArea'dan çıkardım ki şeffaflık işe yarasın
        child: Column(
          children: [
            // --- 2. HEADER (Ortada Başlık, Sağda İkon) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              // Stack ile üst üste bindirip ortalıyorum
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // --- YENİ EKLENEN GERİ BUTONU BURDA---
                  Positioned(
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        // DERS NOTU: Navigator.pop(context) fonksiyonu, mevcut sayfayı
                        // navigasyon yığınından (stack) atar ve bir önceki sayfaya geri döner.
                        Navigator.pop(context);
                      },
                      child: Container(
                        color:
                            Colors.transparent, // Tıklama alanını büyütmek için
                        padding: const EdgeInsets.all(8.0),
                        child: const Icon(
                          Icons
                              .arrow_back_ios, //iosdakine benzeyen geri ok butonu
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Ortadaki Başlık
                  const Text(
                    "Weather",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Sağ üstteki üç nokta (En sağa yaslı)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        //ileride buraya ayarlar menüsü gelebilir
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Başlık çok uzun olursa çakışmasın diye boş yükseklik
                  const Row(children: [SizedBox(height: 32)]),
                ],
              ),
            ),
            // --- 3. SABİT ARAMA ÇUBUĞU (SEARCH BAR) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: GestureDetector(
                onTap: () async {
                  // Kutuya tıklayınca arama sayfası (Delegate) açılsın
                  final result = await showSearch(
                    context: context,
                    delegate: CitySearchDelegate(),
                  );
                  // Eğer bir şehir seçildiyse ekle
                  if (result != null && result.isNotEmpty) {
                    _addCity(result);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E), // Koyu gri (Figma tonu)
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "Search for a city or airport",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- LİSTE KISMI ---
            Expanded(
              child: ListView(
                // Alt bara yapışmasın diye padding verdim
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                children: [
                  // --- MY LOCATION KARTI ---
                  FutureBuilder<WeatherModel>(
                    future: _weatherService.getWeatherByLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Konum bulunamadı veya izin verilmedi.",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final weather = snapshot.data!;

                      // !! yeni karttt
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: LocationCard(
                          weather: weather, //tüm veri gitsin diye
                          isCurrentLocation: true, // başlık "My Location" olsun
                          onTap: () {
                            Navigator.pop(context, "GPS_LOCATION");
                          },
                        ),
                      );
                    },
                  ),

                  // --- KAYITLI ŞEHİRLER LİSTESİ ---
                  if (_savedCities.isNotEmpty)
                    ..._savedCities.map((cityName) {
                      return FutureBuilder<WeatherModel>(
                        future: _weatherService.getWeather(cityName),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final weather = snapshot.data!;

                          // dismissible
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Dismissible(
                              key: Key(cityName),
                              direction:
                                  DismissDirection.endToStart, // kaydırma yönü
                              onDismissed: (_) =>
                                  _removeCity(cityName), // silme işlemi
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red, // Arkadaki kırmızı renk
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: LocationCard(
                                weather: weather, // tüm veri gitsin diye
                                isCurrentLocation:
                                    false, // başlık şehir adı olsun
                                onTap: () {
                                  Navigator.pop(context, cityName);
                                },
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ARAMA İŞLEMİ İÇİN YARDIMCI SINIF (SearchDelegate) ---
class CitySearchDelegate extends SearchDelegate<String> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1C1C1E)),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Enter'a basınca (veya klavyeden arama ikonuna) yazılan şehri geri döndür
    Future.delayed(Duration.zero, () {
      close(context, query);
    });
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(color: Colors.black);
  }
}
