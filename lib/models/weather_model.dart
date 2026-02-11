class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final double windSpeed;
  final int humidity;
  //yeni ekldim
  final double feelsLike;
  final int pressure;

  //gerçek en yüksek ve en düşük sıcaklıkları ekledim
  final double minTemp;
  final double maxTemp;

  //Constructor: bu alanlar zorunludur (required), Swift'teki gibi boş (nil) olamazlar. (optional ın tersi )
  //gelen veriyi direkt değişkene koy demek için this. kullanıyorum
  WeatherModel({
    required this.cityName, //this.cityName = cityName demeden kısaca yazabilirim
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
    // yeni eklediğim kısımlar da zorunlu
    required this.feelsLike,
    required this.pressure,
    // artık bunlar da zorunlu
    required this.minTemp,
    required this.maxTemp,
  });

  // Factory Constructor: JSON verisini alıp Model nesnesine çeviren yapı ( swift'teki 'Decoder' burada manuel yapılıyor.)
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    // dynamic herhangi bir tip olabilir demek (any gibi)
    return WeatherModel(
      cityName: json['name'],

      //API'den gelen sıcaklık eğer tam sayı (int) olmazsa diye önce 'num' olarak alıp 'double'a çevirmeliyim
      temperature: (json['main']['temp'] as num)
          .toDouble(), // swiftte noktayla yapılırdı dartta etiketle
      description: json['weather'][0]['description'],
      iconCode: json['weather'][0]['icon'],
      windSpeed: (json['wind']['speed'] as num)
          .toDouble(), //num.toDouble() ile double'a çevirdik
      humidity:
          json['main']['humidity']
              as int, //nem zaten hep tam sayıdır .toDouble yapmama gerek yok

      feelsLike: (json['main']['feels_like'] as num)
          .toDouble(), // hissedilen de buçuklu olabilir
      pressure: json['main']['pressure'] as int, // basınç genelde tam sayıdır
      //JSON'dan min ve max sıcaklıkları çekiyorum
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
    );
  }

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }
}
