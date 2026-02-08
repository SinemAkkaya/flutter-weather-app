import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final String cityName;
  final String temperature;
  final String condition;
  final String highLow; // en yüksek-En düşük
  final VoidCallback onTap; // ttıklanınca ne olsun?
  final VoidCallback onDelete; // silinince ne olsun?

  const LocationCard({
    super.key,
    required this.cityName,
    required this.temperature,
    required this.condition,
    required this.highLow,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(cityName),
      direction: DismissDirection.endToStart, // sdece sağdan sola kaydır
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          height: 120, // kartın yüksekliği
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // gradient kart tasarımı
            gradient: const LinearGradient(
              colors: [Color(0xFF2E335A), Color(0xFF1C1B33)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20), // köşeleri yuvarla
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // yazılar başta sığmadı ama şimdi expanded kullanarak sol tarafın "kalan tüm boşluğu" almasını sağladım.
              // böylece sağdaki dereceyi asla sıkıştırmaz.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cityName,
                      maxLines: 1, // en fazla 1 satır olsun
                      overflow: TextOverflow
                          .ellipsis, // Sığmazsa ... koy az önce sığmamıştı
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      condition, // hava durumu
                      maxLines:
                          1, // uzun hava durumu açıklaması da 1 satır olsun
                      overflow: TextOverflow.ellipsis, // sığmazsa yine ... olsun
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14, // yazıyı hafif küçülttüm sığması için
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // iki sütun birbirine yapışmasın diye araya boşluk koydum
              const SizedBox(width: 10),

              // derece ve min/max
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$temperature°",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    highLow,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
