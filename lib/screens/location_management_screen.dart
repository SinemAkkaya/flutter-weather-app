import 'package:flutter/material.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
        _searchController.clear();
        setState(() {
          _isSearching = false;
        });
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Şehir ara...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                autofocus: true,
                onSubmitted: (value) => _addCity(value),
              )
            : const Text(
                "Weather",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.cancel : Icons.search_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // --- 1. MY LOCATION KARTI ---
          FutureBuilder<WeatherModel>(
            future: _weatherService.getWeatherByLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white),
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
              return LocationCard(
                weather: weather, //tüm veri gitsin diye
                isCurrentLocation: true, // başlık "My Location" olsun
                onTap: () {
                  Navigator.pop(context, "GPS_LOCATION");
                },
              );
            },
          ),

          // --- 2. KAYITLI ŞEHİRLER LİSTESİ ---
          if (_savedCities.isEmpty)
            const SizedBox()
          else
            ..._savedCities.map((cityName) {
              return FutureBuilder<WeatherModel>(
                future: _weatherService.getWeather(cityName),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final weather = snapshot.data!;

                  // dismissible

                  return Dismissible(
                    key: Key(cityName),
                    direction: DismissDirection.endToStart, // kayfırma yönü
                    onDismissed: (_) => _removeCity(cityName), // silme işlemi
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red, // Arkadaki kırmızı renk
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: LocationCard(
                      weather: weather, // tüm veri gitsin diye
                      isCurrentLocation: false, // başlık şehir adı olsun
                      onTap: () {
                        Navigator.pop(context, cityName);
                      },
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }
}
