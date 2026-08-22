import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/expense_model.dart';
import 'package:easy_localization/easy_localization.dart';
class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  List<String> _persons = [];
  String? _searchPersonQuery;

  // 🔹 قائمة لحفظ الإشعارات التي تم إخفاؤها/قراءتها مؤقتاً
final List<String> _dismissedAlerts = [];
  // ==========================================
  // 1. الميزات المستعادة (العملة، الوضع الليلي، الأرشيف)
  // ==========================================
  bool get isDarkMode {
    final box = Hive.box('settingsBox');
    return box.get('isDarkMode', defaultValue: false);
  }

  void toggleTheme() {
    final box = Hive.box('settingsBox');
    box.put('isDarkMode', !isDarkMode);
    notifyListeners();
  }

  String get currency {
    final box = Hive.box('settingsBox');
    return box.get('currency', defaultValue: 'جنيه');
  }

  void setCurrency(String newCurrency) {
    final box = Hive.box('settingsBox');
    box.put('currency', newCurrency);
    notifyListeners();
  }

  final List<dynamic> _archives = [];
  List<dynamic> get archives => _archives;

  // ==========================================
  // 2. إدارة البيانات الأساسية
  // ==========================================
  List<ExpenseModel> get expenses {
    if (_searchPersonQuery != null && _searchPersonQuery!.isNotEmpty) {
      return _expenses.where((e) => e.payer == _searchPersonQuery).toList();
    }
    List<ExpenseModel> sorted = List.from(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  List<ExpenseModel> get allExpenses => _expenses;
  List<String> get persons => _persons;
  String? get searchPersonQuery => _searchPersonQuery;

  ExpenseProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final box = Hive.box<ExpenseModel>('expenses');
    _expenses = box.values.toList();
    
    final personBox = Hive.box<String>('persons');
    _persons = personBox.values.toList();

    if (!Hive.isBoxOpen('archivesBox')) {
      await Hive.openBox('archivesBox');
    }
    final archiveBox = Hive.box('archivesBox');
    _archives.clear();
    _archives.addAll(archiveBox.values);

    notifyListeners();
  }

  void setFilter(String? person) {
    _searchPersonQuery = person;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final box = Hive.box<ExpenseModel>('expenses');
    await box.put(expense.id, expense);
    _expenses.add(expense);
    _dismissedAlerts.clear(); // تصفير الإشعارات المقروءة عند إضافة عملية جديدة
    notifyListeners();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final box = Hive.box<ExpenseModel>('expenses');
    await box.put(expense.id, expense);
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    final box = Hive.box<ExpenseModel>('expenses');
    await box.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> addPerson(String name) async {
    if (!_persons.contains(name)) {
      final personBox = Hive.box<String>('persons');
      await personBox.add(name);
      _persons.add(name);
      _dismissedAlerts.clear();
      notifyListeners();
    }
  }

  Future<void> removePerson(String name) async {
    final personBox = Hive.box<String>('persons');
    final key = personBox.keys.firstWhere((k) => personBox.get(k) == name, orElse: () => null);
    if (key != null) {
      await personBox.delete(key);
      _persons.remove(name);
      notifyListeners();
    }
  }

  // ==========================================
  // 3. الميزات المستعادة (تعديل اسم الشخص والتسوية)
  // ==========================================
  Future<void> editPersonName(String oldName, String newName) async {
    if (!_persons.contains(oldName) || _persons.contains(newName)) return;

    final personBox = Hive.box<String>('persons');
    final key = personBox.keys.firstWhere((k) => personBox.get(k) == oldName, orElse: () => null);
    if (key != null) {
      await personBox.put(key, newName);
      int index = _persons.indexOf(oldName);
      if (index != -1) _persons[index] = newName;

      final box = Hive.box<ExpenseModel>('expenses');
      for (var exp in _expenses) {
        if (exp.payer == oldName) {
          final updatedExp = ExpenseModel(
            id: exp.id,
            title: exp.title,
            amount: exp.amount,
            payer: newName,
            date: exp.date,
            category: exp.category,
          );
          await box.put(exp.id, updatedExp);
          int eIndex = _expenses.indexWhere((e) => e.id == exp.id);
          if (eIndex != -1) _expenses[eIndex] = updatedExp;
        }
      }
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> get settlementTransactions {
    double totalExpenses = _expenses.fold(0, (sum, item) => sum + item.amount);
    double sharePerPerson = _persons.isNotEmpty ? totalExpenses / _persons.length : 0;

    Map<String, double> balances = {};
    for (var p in _persons) {
      double paid = _expenses.where((e) => e.payer == p).fold(0, (sum, item) => sum + item.amount);
      balances[p] = paid - sharePerPerson;
    }

    List<MapEntry<String, double>> debtors = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> creditors = balances.entries.where((e) => e.value > 0.01).toList();

    debtors.sort((a, b) => a.value.compareTo(b.value));
    creditors.sort((a, b) => b.value.compareTo(a.value));

    List<Map<String, dynamic>> settlements = [];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      double debt = -debtors[i].value;
      double credit = creditors[j].value;
      double amount = debt < credit ? debt : credit;

      settlements.add({'from': debtors[i].key, 'to': creditors[j].key, 'amount': amount});

      debtors[i] = MapEntry(debtors[i].key, debtors[i].value + amount);
      creditors[j] = MapEntry(creditors[j].key, creditors[j].value - amount);

      if (debtors[i].value.abs() < 0.01) i++;
      if (creditors[j].value.abs() < 0.01) j++;
    }
    return settlements;
  }

  Future<void> settleAndArchive(String title) async {
    if (_expenses.isEmpty) return;

    if (!Hive.isBoxOpen('archivesBox')) {
      await Hive.openBox('archivesBox');
    }
    final archiveBox = Hive.box('archivesBox');

    final List<String> summaryLines = settlementTransactions.map((s) {
      return "${s['from']} يدفع لـ ${s['to']} مبلغ ${s['amount'].toStringAsFixed(2)} $currency";
    }).toList();

    final Map<String, dynamic> cycleData = {
      'title': title,
      'date': DateTime.now().toIso8601String(),
      'totalAmount': _expenses.fold(0.0, (sum, item) => sum + item.amount),
      'expensesCount': _expenses.length,
      'personsCount': _persons.length,
      'settlementSummary': summaryLines,
      'expensesList': _expenses.map((e) => {
        'title': e.title,
        'amount': e.amount,
        'payer': e.payer,
        'date': e.date.toIso8601String(),
        'category': e.category,
      }).toList(),
    };

    await archiveBox.add(cycleData);
    _archives.add(cycleData);

    final box = Hive.box<ExpenseModel>('expenses');
    await box.clear();
    _expenses.clear();
    _dismissedAlerts.clear();

    notifyListeners();
  }

  // ==========================================
  // 4. محرك التنبيهات الذكية (تم تحديثه)
  // ==========================================
  void dismissAlert(String title) {
    if (!_dismissedAlerts.contains(title)) {
      _dismissedAlerts.add(title);
      notifyListeners();
    }
  }

  void clearAllAlerts() {
    final currentAlerts = _generateRawAlerts();
    for (var alert in currentAlerts) {
      if (!_dismissedAlerts.contains(alert['title'])) {
        _dismissedAlerts.add(alert['title']);
      }
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> _generateRawAlerts() {
    List<Map<String, dynamic>> alerts = [];
    
    if (_persons.isEmpty) {
      alerts.add({'title': 'أهلاً بك!', 'subtitle': 'ابدأ بإضافة الأشخاص.', 'icon': Icons.group_add, 'color': Colors.blue});
      return alerts;
    }
    if (_expenses.isEmpty) {
      alerts.add({'title': 'المجموعة جاهزة!', 'subtitle': 'أضف أول مصروف.', 'icon': Icons.receipt_long, 'color': Colors.teal});
    }

    double totalExpenses = _expenses.fold(0.0, (sum, item) => sum + item.amount);
    if (targetBudget > 0) {
      double percentage = totalExpenses / targetBudget;
      if (percentage >= 1.0) {
        alerts.add({'title': 'تجاوزت الميزانية!', 'subtitle': 'لقد استهلكت 100% من الميزانية المحددة.', 'icon': Icons.warning_rounded, 'color': Colors.red});
      } else if (percentage >= 0.5) {
        alerts.add({'title': 'نصف الميزانية!', 'subtitle': 'لقد استهلكت أكثر من 50% من الميزانية المحددة.', 'icon': Icons.pie_chart, 'color': Colors.orange});
      }
    }

    for (var person in _persons) {
     if (!_expenses.any((e) => e.payer == person)) {
      alerts.add({
        // 🔹 دمج اسم الشخص مع الجملة المترجمة
        'title': '$person ${'لم يقم بأي دفع!'.tr()}', 
        'subtitle': 'تأكد من مشاركة المصروفات.'.tr(), 
        'icon': Icons.info_outline, 
        'color': Colors.blueGrey
      });
      }
    }

    if (settlementTransactions.isNotEmpty && _expenses.isNotEmpty) {
       alerts.add({
         // 🔹 إضافة .tr() للنصوص
         'title': 'اقتراح تسوية جاهز'.tr(), 
         'subtitle': 'يمكنك الآن تسوية حسابات المجموعة.'.tr(), 
         'icon': Icons.handshake, 
         'color': Colors.green 
       });
    }

    if (_expenses.isNotEmpty) {
      List<ExpenseModel> sortedExpenses = List.from(_expenses);
      sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
      final difference = DateTime.now().difference(sortedExpenses.first.date).inDays;
      if (difference >= 7) {
        alerts.add({'title': 'لم تتم المخالصة منذ فترة!', 'subtitle': 'آخر عملية كانت منذ $difference أيام.', 'icon': Icons.event_busy, 'color': Colors.deepOrange});
      }
    }
    return alerts;
  }

  List<Map<String, dynamic>> get smartAlerts {
    return _generateRawAlerts().where((alert) => !_dismissedAlerts.contains(alert['title'])).toList();
  }

  // ==========================================
  // 5. الميزانية المستهدفة
  // ==========================================
  double get targetBudget {
    final box = Hive.box('settingsBox');
    return box.get('targetBudget', defaultValue: 20000.0);
  }

  Future<void> setTargetBudget(double amount) async {
    final box = Hive.box('settingsBox');
    await box.put('targetBudget', amount);
    notifyListeners();
  }

  // ==========================================
  // 6. اسم المجموعة
  // ==========================================
  String get groupName {
    final box = Hive.box('settingsBox');
    return box.get('groupName', defaultValue: 'المجموعة الحالية');
  }

  Future<void> setGroupName(String name) async {
    final box = Hive.box('settingsBox');
    await box.put('groupName', name);
    notifyListeners();
  }
}