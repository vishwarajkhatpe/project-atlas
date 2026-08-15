import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/expense_repository.dart';

// Provider for fetching expenses for a specific trip
final tripExpensesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, tripId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpenses(tripId);
});

final expenseControllerProvider = AsyncNotifierProvider<ExpenseController, void>(() {
  return ExpenseController();
});

class ExpenseController extends AsyncNotifier<void> {
  late final ExpenseRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.watch(expenseRepositoryProvider);
    return null;
  }

  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required DateTime expenseDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addExpense(
        tripId: tripId,
        title: title,
        amount: amount,
        expenseDate: expenseDate,
      );
      ref.invalidate(tripExpensesProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteExpense({
    required String expenseId,
    required String tripId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteExpense(expenseId);
      ref.invalidate(tripExpensesProvider(tripId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
