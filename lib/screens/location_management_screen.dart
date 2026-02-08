import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart'; // Bu import eksikti o yüzden hata veriyordu, ekledim düzeldi!
import '../widgets/location_card.dart';

class LocationManagementScreen extends StatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  State<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
//servislerimi burada başlattım
//hem veritabanı hem hava durumu servisine ihtiyacım var
  final StorageService _storageService = StorageService();
  final WeatherService _weatherService = WeatherService();

  List<String> _savedCities = [];
  final TextEditingController _searchController = TextEditingController();
  // Arama yapıyor muyum kontrolü buna göre başlık değişecek
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadCities(); // ekran açılır açılmaz hafızadaki şehirleri getir
  }

  Future<void> _loadCities() async {
    final cities = await _storageService.getCities();
    setState(() {
      // 7 tane Ankara yazması sorununu burada çözdüm.
      // .toSet() yaparak kopyaları temizledim artık her şehirden sadece 1 tane var ve sonra tekrar listeye çevirdim çünkü set sıralı değil ama ben sıralı liste istiyorum
      _savedCities = cities.toSet().toList();
    });
  }

  Future<void> _addCity(String city) async {
    try {
      // rastgele şeyler yazılmasın diye önce API'ye soruyorum böy le bir şehir var mı diye
      await _weatherService.getWeather(city); 
      
      // eğer yazılan şehir geçerliyse VE listede zaten yoksa ekle (Çift kayıt olmasın)
      //başta sadece geçerliyse diye baktım aynı şehri 10 kere ekleyebiliyordum o yüzden ikinci şartı da ekledim
      if (city.isNotEmpty && !_savedCities.contains(city)) {
        await _storageService.addCity(city);
        _searchController.clear(); // yazıyı temizledik
        setState(() {
          _isSearching = false; // aramayı kapattık
        });
        await _loadCities(); // Listeyi güncelle ki yeni şehir hemen görünsün yoksa ekledikten sonra sayfayı yenilemek gerekiyor ve bu kötü bir kullanıcı deneyimi olur 
      }
    } catch (e) {
      // şehir bulunamazsa kullanıcıya alttan uyarı veriyorum 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("We couldn’t find this city. Please check the spelling and try again.")),
        );
      }
    }
  }

  Future<void> _removeCity(String city) async {
    // hem hafızadan siliyorum hem de ekranı güncelliyorum
    await _storageService.removeCity(city);
    await _loadCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, //koyu tema
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Geri dön
        ),
        //arama modundaysam TextField değilsem Başlık görünüyor
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Şehir ara...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                autofocus: true, // Klavye otomatik açılsın
                onSubmitted: (value) => _addCity(value), // enter'a basınca ekle
              )
            : const Text(
                "Weather",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            //duruma göre büyüteç veya çarpı ikonu
            icon: Icon(
                _isSearching ? Icons.cancel : Icons.search_rounded,
                color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false; //iptal et
                  _searchController.clear();
                } else {
                  _isSearching = true; // aramayı aç
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          
          // Artık burası canlı çalışıyor my location kısmında GPS verisi direkt kartın içinde gösterili yor
          FutureBuilder<WeatherModel>(
            future: _weatherService.getWeatherByLocation(), // konum verisini aldım
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white)));
              }

              if (snapshot.hasError) {
                // bunu yapmak faydalı bir şeymiş eğer konum izni verilmezse veya GPS çalışmazsa uygulamanın çökmesi yerine kullanıcıya düzgün bir mesaj göstermek için ekledim
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text("Konum bulunamadı",
                      style: TextStyle(color: Colors.white)),
                );
              }

              // veri geldiyse kartı gösteren kısım
              final weather = snapshot.data!;
              final temp = weather.temperature.round().toString();

              return LocationCard(
                cityName: "My Location", // bşlık sabit
                temperature: temp,
                condition: weather.cityName, // altına gerçek ilçe/şehir ismi yazıyor
                highLow: "H:$temp° L:$temp°", 
                onTap: () {
                  Navigator.pop(context, "GPS_LOCATION"); // ana sayfaya Ben GPS'i seçtim diye haber gitsin
                },
                // My Location silinmese daha iyi olur sanırım o yüzden boş fonksiyon verdim
                onDelete: () {}, 
              );
            },
          ),

          // kaydedilmiş şehirler listesi
          if (_savedCities.isEmpty)
             const SizedBox() // liste boşsa yer kaplamasın
          else
            // eklediğim şehirleri listeliyorum her biri için tekrar API'ye gidip güncel dereceyi çekiyorum.
            ..._savedCities.map((cityName) {
              return FutureBuilder<WeatherModel>(
                future: _weatherService.getWeather(cityName),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final weather = snapshot.data!;
                  final temp = weather.temperature.round().toString();

                  return LocationCard(
                    cityName: weather.cityName,
                    temperature: temp,
                    condition: weather.description.toUpperCase(),
                    highLow: "H:$temp° L:$temp°",
                    onTap: () {
                      Navigator.pop(context, cityName); // seçilen şehri ana sayfaya yolla
                    },
                    onDelete: () => _removeCity(cityName), // kaydırınca sil
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }
}