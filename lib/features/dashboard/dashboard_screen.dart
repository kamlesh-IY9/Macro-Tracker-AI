import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../services/food_log_service.dart';
import '../logging/quick_add_macros_screen.dart';
import '../logging/logging_screen.dart';
import '../food_search/food_search_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late PageController _pageController;
  DateTime _currentDate = DateTime.now();
  final int _initialPage = 500; // Middle of 1000 pages for infinite scroll

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final daysDiff = page - _initialPage;
    setState(() {
      _currentDate = DateTime.now().add(Duration(days: daysDiff));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userServiceProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final daysDiff = index - _initialPage;
          final date = DateTime.now().add(Duration(days: daysDiff));
          return _buildDayView(date, user);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isToday = _currentDate.day == DateTime.now().day &&
        _currentDate.month == DateTime.now().month &&
        _currentDate.year == DateTime.now().year;

    return AppBar(
      backgroundColor: const Color(0xFF1E293B),
      elevation: 0,
      centerTitle: true,
      title: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _currentDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            final daysDiff = picked.difference(DateTime.now()).inDays;
            _pageController.jumpToPage(_initialPage + daysDiff);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isToday ? 'Today' : DateFormat('EEE, MMM d').format(_currentDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
      actions: [
        if (!isToday)
          TextButton(
            onPressed: () {
              _pageController.jumpToPage(_initialPage);
            },
            child: const Text(
              'Today',
              style: TextStyle(color: Color(0xFF14B8A6)),
            ),
          ),
      ],
    );
  }

  Widget _buildDayView(DateTime date, user) {
    final dailyTotals = ref.read(foodLogServiceProvider.notifier).getDailyTotals(date);
    final caloriesPercent = (dailyTotals['calories']! / user.tdee).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Daily Summary Card
          _buildDailySummaryCard(user, dailyTotals, caloriesPercent),

          // Meal Sections
          _buildMealSection('Breakfast', date),
          _buildMealSection('Lunch', date),
          _buildMealSection('Dinner', date),
          _buildMealSection('Snacks', date),

          const SizedBox(height: 80), // Bottom padding for FAB
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(user, Map<String, double> totals, double caloriesPercent) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Calorie Progress Bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totals['calories']!.toInt()} / ${user.tdee.toInt()} kcal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: caloriesPercent,
                      backgroundColor: const Color(0xFF334155),
                      color: const Color(0xFF00D9C0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Macro Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroIndicator(
                'Protein',
                totals['protein']!,
                user.proteinTarget,
                const Color(0xFF8B5CF6),
              ),
              _buildMacroIndicator(
                'Carbs',
                totals['carbs']!,
                user.carbTarget,
                const Color(0xFF3B82F6),
              ),
              _buildMacroIndicator(
                'Fat',
                totals['fat']!,
                user.fatTarget,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(String label, double current, double target, Color color) {
    final percent = (current / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
            ),
            Column(
              children: [
                Text(
                  current.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'of ${target.toInt()}g',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMealSection(String mealName, DateTime date) {
    final logs = ref.read(foodLogServiceProvider.notifier).getLogsForDate(date);
    final mealLogs = logs.where((log) {
      // Simple meal categorization by time - can be improved
      final hour = log.timestamp.hour;
      if (mealName == 'Breakfast' && hour >= 5 && hour < 11) return true;
      if (mealName == 'Lunch' && hour >= 11 && hour < 16) return true;
      if (mealName == 'Dinner' && hour >= 16 && hour < 22) return true;
      if (mealName == 'Snacks' && (hour < 5 || hour >= 22)) return true;
      return false;
    }).toList();

    final mealTotal = mealLogs.fold<double>(
      0.0,
      (sum, log) => sum + log.calories,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Meal Header
          ListTile(
            title: Text(
              mealName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (mealTotal > 0)
                  Text(
                    '${mealTotal.toInt()} kcal',
                    style: const TextStyle(
                      color: Color(0xFF14B8A6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF14B8A6)),
                  onPressed: () => _showAddFoodOptions(date, mealName),
                ),
              ],
            ),
          ),

          if (mealLogs.isNotEmpty)
            ...mealLogs.map((log) => Dismissible(
                  key: ValueKey('${log.userId}_${log.timestamp}_${log.name}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    // Find and delete by matching properties
                    final logsToDelete = ref.read(foodLogServiceProvider).where((l) => 
                      l.userId == log.userId && 
                      l.timestamp == log.timestamp && 
                      l.name == log.name
                    ).toList();
                    if (logsToDelete.isNotEmpty) {
                      ref.read(foodLogServiceProvider.notifier).deleteLog(logsToDelete.first.id);
                    }
                  },
                  child: ListTile(
                    title: Text(
                      log.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'P: ${log.protein.toInt()}g • C: ${log.carbs.toInt()}g • F: ${log.fat.toInt()}g',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                    trailing: Text(
                      '${log.calories.toInt()} kcal',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  void _showAddFoodOptions(DateTime date, String mealName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00D9C0)),
              title: const Text('AI Food Logging', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Photo or text analysis', style: TextStyle(color: Color(0xFF888888))),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoggingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF00D9C0)),
              title: const Text('Quick Add Macros', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuickAddMacrosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Color(0xFF00D9C0)),
              title: const Text('Search Food Database', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
