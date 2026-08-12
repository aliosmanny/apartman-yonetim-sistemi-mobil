class Announcement {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final bool isImportant;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isImportant = false,
  });
}

// Mock Data
final List<Announcement> mockAnnouncements = [
  Announcement(
    id: '1',
    title: 'Su Kesintisi Hakkında Önemli Duyuru',
    content: 'Değerli sakinlerimiz, ana su hattındaki arıza nedeniyle yarın (15 Ağustos) 09:00 - 15:00 saatleri arasında su kesintisi yaşanacaktır. Lütfen tedbirinizi alınız.',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isImportant: true,
  ),
  Announcement(
    id: '2',
    title: 'Aylık Aidat Ödemeleri',
    content: 'Ağustos ayı aidat ödemelerinizin son günü yaklaşmaktadır. Lütfen gecikme zammı işlememesi için ay sonuna kadar ödemelerinizi tamamlayınız.',
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  Announcement(
    id: '3',
    title: 'Asansör Bakımı Tamamlandı',
    content: 'B Blok asansörlerinin periyodik bakımı tamamlanmış olup güvenle kullanabilirsiniz.',
    date: DateTime.now().subtract(const Duration(days: 10)),
  ),
];
