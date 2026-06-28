/// A launch shortlist of European cities with notable Arab diaspora communities
/// and venues that host MENA artists. Bilingual labels for the city picker.
class CityOption {
  const CityOption(this.id, this.name, this.nameAr, this.country);
  final String id;
  final String name;
  final String nameAr;
  final String country;

  String displayName(String languageCode) => languageCode == 'ar' ? nameAr : name;
}

const List<CityOption> kEuropeanCities = [
  CityOption('berlin', 'Berlin', 'برلين', 'DE'),
  CityOption('frankfurt', 'Frankfurt', 'فرانكفورت', 'DE'),
  CityOption('munich', 'Munich', 'ميونخ', 'DE'),
  CityOption('cologne', 'Cologne', 'كولونيا', 'DE'),
  CityOption('paris', 'Paris', 'باريس', 'FR'),
  CityOption('london', 'London', 'لندن', 'GB'),
  CityOption('manchester', 'Manchester', 'مانشستر', 'GB'),
  CityOption('amsterdam', 'Amsterdam', 'أمستردام', 'NL'),
  CityOption('brussels', 'Brussels', 'بروكسل', 'BE'),
  CityOption('stockholm', 'Stockholm', 'ستوكهولم', 'SE'),
  CityOption('vienna', 'Vienna', 'فيينا', 'AT'),
  CityOption('madrid', 'Madrid', 'مدريد', 'ES'),
  CityOption('milan', 'Milan', 'ميلانو', 'IT'),
  CityOption('copenhagen', 'Copenhagen', 'كوبنهاغن', 'DK'),
];
