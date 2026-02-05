class WeatherModel {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final double windSpeed;
  final int humidity;

  //Constructor: bu alanlar zorunludur (required), Swift'teki gibi boş (nil) olamazlar. (optional ın tersi )
  //gelen veriyi direkt değişkene koy demek için this. kullanıyorum
  WeatherModel({
    required this.cityName, //this.cityName = cityName demeden kısaca yazabilirim
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.windSpeed,
    required this.humidity,
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
    );
  }
 String get iconUrl {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }
}
 