/// PNG'den SVG'ye çevirme yardımcısı
/// 
/// Kullanım:
/// 1. PNG resmi assets/images/ klasörüne koy
/// 2. Bu aracı kullanarak SVG'ye çevir
/// 3. SVG'yi assets/images/svg/ klasörüne koy
/// 
/// NOT: Gerçek çevirme için harici tool gerekiyor
/// Biz basit bir reminder/scaffolding oluşturuyoruz

class SvgConverter {
  /// PNG'yi SVG formatına çevir
  /// 
  /// Bu fonksiyon aslında harici bir tool gerektirir:
  /// - potrace (https://potrace.sourceforge.net/)
  /// - imagetracerjs
  /// - Adobe Illustrator
  /// 
  /// Biz sadece şablonu oluşturuyoruz
  static String createSvgTemplate({
    required String pngPath,
    required List<SvgArea> areas,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">');
    
    // Arka plan
    buffer.writeln('  <!-- Arka plan -->');
    buffer.writeln('  <rect width="400" height="400" fill="white"/>');
    
    // Siyah çizgiler (değiştirilmez)
    buffer.writeln('  <!-- Siyah çizgiler -->');
    buffer.writeln('  <g stroke="black" stroke-width="2" fill="none">');
    // Buraya真正的çizgiler eklenecek
    buffer.writeln('  </g>');
    
    // Boyanabilir alanlar
    buffer.writeln('  <!-- Boyanabilir alanlar -->');
    for (final area in areas) {
      buffer.writeln('  <path id="${area.id}" fill="${area.defaultColor}" data-name="${area.name}" d="${area.path}"/>');
    }
    
    buffer.writeln('</svg>');
    return buffer.toString();
  }
  
  /// SVG dosyasını parse et ve alanları bul
  static List<SvgArea> parseSvgAreas(String svgContent) {
    final areas = <SvgArea>[];
    
    // Basit regex ile path'leri bul
    final pathRegex = RegExp(r'<path[^>]*id="([^"]*)"[^>]*d="([^"]*)"[^>]*/>');
    final matches = pathRegex.allMatches(svgContent);
    
    for (final match in matches) {
      areas.add(SvgArea(
        id: match.group(1) ?? '',
        path: match.group(2) ?? '',
        name: match.group(1) ?? '',
        defaultColor: '#FFFFFF',
      ));
    }
    
    return areas;
  }
}

/// SVG boyama alanı
class SvgArea {
  final String id;
  final String path;
  final String name;
  final String defaultColor;
  
  const SvgArea({
    required this.id,
    required this.path,
    required this.name,
    this.defaultColor = '#FFFFFF',
  });
}
