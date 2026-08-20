class PropertyUnit {
  final String id;
  final String blockName;
  final String flatNumber;
  final String? residentName;
  final String? residentPhone;
  final bool isOccupied;
  final String type; // Örn: '3+1', '2+1', 'Dükkan'

  const PropertyUnit({
    required this.id,
    required this.blockName,
    required this.flatNumber,
    this.residentName,
    this.residentPhone,
    required this.isOccupied,
    required this.type,
  });
}

// Mock Data
final List<PropertyUnit> mockProperties = [
  const PropertyUnit(
    id: '1',
    blockName: 'A Blok',
    flatNumber: '1',
    residentName: 'Ahmet Yılmaz',
    residentPhone: '0532 111 2233',
    isOccupied: true,
    type: '3+1',
  ),
  const PropertyUnit(
    id: '2',
    blockName: 'A Blok',
    flatNumber: '2',
    residentName: 'Ayşe Demir',
    residentPhone: '0555 444 5566',
    isOccupied: true,
    type: '2+1',
  ),
  const PropertyUnit(
    id: '3',
    blockName: 'A Blok',
    flatNumber: '3',
    isOccupied: false,
    type: '3+1',
  ),
  const PropertyUnit(
    id: '4',
    blockName: 'B Blok',
    flatNumber: '14',
    residentName: 'Ali Osman',
    residentPhone: '0533 999 8877',
    isOccupied: true,
    type: '4+1 D',
  ),
  const PropertyUnit(
    id: '5',
    blockName: 'C Blok',
    flatNumber: 'Dükkan 1',
    residentName: 'Market A.Ş.',
    residentPhone: '0212 333 4455',
    isOccupied: true,
    type: 'Ticari',
  ),
];
