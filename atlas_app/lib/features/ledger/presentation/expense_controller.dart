import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';

final expenseControllerProvider =
    AsyncNotifierProvider.family<ExpenseController, List<Map<String, dynamic>>, String>(
  () => ExpenseController(),
);

class ExpenseController extends FamilyAsyncNotifier<List<Map<String, dynamic>>, String> {
  @override
  Future<List<Map<String, dynamic>>> build(String arg) async {
    return _fetchExpenses();
  }

  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    final repository = ref.read(expenseRepositoryProvider);
    return repository.getExpenses(arg);
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime expenseDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);
      await repository.addExpense(
        tripId: arg,
        title: title,
        amount: amount,
        expenseDate: expenseDate,
      );
      return _fetchExpenses();
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);
      await repository.deleteExpense(expenseId);
      return _fetchExpenses();
    });
  }
}
