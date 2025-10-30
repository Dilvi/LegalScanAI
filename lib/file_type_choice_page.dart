import 'package:flutter/material.dart';

class DocumentType {
  final String title;
  final String slug;
  DocumentType(this.title, this.slug);
}

class FileTypeChoicePage extends StatefulWidget {
  const FileTypeChoicePage({super.key});

  @override
  State<FileTypeChoicePage> createState() => _FileTypeChoicePageState();
}

class _FileTypeChoicePageState extends State<FileTypeChoicePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<DocumentType> _allTypes = [
    DocumentType("🤖 Определить автоматически", "auto_detect"),

    // 🏠 Недвижимость
    DocumentType("Договор купли-продажи квартиры", "apartment_sale"),
    DocumentType("Договор купли-продажи дома", "house_sale"),
    DocumentType("Договор дарения недвижимости", "real_estate_gift"),
    DocumentType("Договор аренды квартиры", "apartment_rent"),
    DocumentType("Договор аренды дома", "house_rent"),
    DocumentType("Договор найма жилого помещения", "residential_hire"),
    DocumentType("Договор залога недвижимости", "mortgage_pledge"),
    DocumentType("Договор мены недвижимости", "property_exchange"),

    // 🚗 Транспорт
    DocumentType("Договор купли-продажи автомобиля", "car_sale"),
    DocumentType("Договор дарения автомобиля", "car_gift"),
    DocumentType("Договор аренды транспортного средства", "car_rent"),
    DocumentType("Договор лизинга автомобиля", "car_leasing"),

    // 👪 Наследство и личные документы
    DocumentType("Завещание", "will"),
    DocumentType("Брачный договор", "marriage_contract"),
    DocumentType("Свидетельство о браке", "marriage_certificate"),
    DocumentType("Свидетельство о рождении", "birth_certificate"),
    DocumentType("Свидетельство о смерти", "death_certificate"),
    DocumentType("Доверенность", "power_of_attorney"),

    // 📄 Общегражданские договоры
    DocumentType("Договор подряда", "contract_work"),
    DocumentType("Договор оказания услуг", "service_contract"),
    DocumentType("Договор займа", "loan_agreement"),
    DocumentType("Договор поручительства", "guarantee_agreement"),
    DocumentType("Договор аренды нежилого помещения", "commercial_rent"),
    DocumentType("Договор ответственного хранения", "storage_contract"),
    DocumentType("Договор купли-продажи оборудования", "equipment_sale"),
    DocumentType("Договор аренды оборудования", "equipment_rent"),
    DocumentType("Договор безвозмездного пользования", "gratuitous_use"),
    DocumentType("Договор поставки", "supply_contract"),

    // 🏢 Бизнес и финансы
    DocumentType("Устав организации", "company_charter"),
    DocumentType("Договор с ИП", "entrepreneur_contract"),
    DocumentType("Договор с ООО", "company_contract"),
    DocumentType("Договор займа между юрлицами", "business_loan"),
    DocumentType("Договор подряда с ИП", "entrepreneur_work"),
    DocumentType("Договор поставки товаров", "goods_supply"),

    // ⚖️ Судебные и юридические
    DocumentType("Исковое заявление", "lawsuit"),
    DocumentType("Мировое соглашение", "settlement_agreement"),
    DocumentType("Нотариальное соглашение", "notary_agreement"),
    DocumentType("Решение суда", "court_decision"),
    DocumentType("Исполнительный лист", "writ_of_execution"),
    DocumentType("Судебный приказ", "court_order"),

    // 📑 Прочие
    DocumentType("Трудовой договор", "employment_contract"),
    DocumentType("Заявление об увольнении", "resignation_letter"),
    DocumentType("Должностная инструкция", "job_instruction"),
    DocumentType("Коммерческое предложение", "commercial_offer"),
    DocumentType("Акт выполненных работ", "act_completed"),
    DocumentType("Накладная", "invoice"),
    DocumentType("Счёт", "bill"),
    DocumentType("Договор франшизы", "franchise_agreement"),
    DocumentType("Договор купли-продажи доли", "share_sale"),
    DocumentType("Лицензионный договор", "license_agreement"),
  ];

  late List<DocumentType> _filteredTypes;

  @override
  void initState() {
    super.initState();
    _filteredTypes = _allTypes;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTypes = _allTypes
          .where((type) => type.title.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleAutoDetect(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Определить автоматически?",
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "⚠️ Автоматическое определение типа документа может быть менее точным.\n\n"
              "Рекомендуется выбрать тип вручную для максимальной точности анализа.",
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Продолжить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pop(context, "auto_detect");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Выберите тип документа",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Поиск по типу документа...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredTypes.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFE0E0E0),
                ),
                itemBuilder: (context, index) {
                  final type = _filteredTypes[index];
                  final bool isAuto = type.slug == "auto_detect";

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    splashColor: const Color(0x11800000),
                    onTap: () {
                      if (isAuto) {
                        _handleAutoDetect(context);
                      } else {
                        Navigator.pop(context, type.slug);
                      }
                    },
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              type.title,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16,
                                fontWeight: isAuto ? FontWeight.w600 : FontWeight.w400,
                                color: isAuto
                                    ? const Color(0xFF800000)
                                    : Colors.black,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 18, color: Color(0xFF737C97)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
