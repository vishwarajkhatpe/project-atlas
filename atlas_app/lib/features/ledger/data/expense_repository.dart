import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(Supabase.instance.client);
});

class ExpenseRepository {
  final SupabaseClient _supabase;

  ExpenseRepository(this._supabase);

  // Fetch all expenses for a specific trip
  Future<List<Map<String, dynamic>>> getExpenses(String tripId) async {
    final response = await _supabase
        .from('expenses')
        .select('''
          *,
          users:paid_by (
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('trip_id', tripId)
        .order('expense_date', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Add a new expense
  Future<void> addExpense({
    required String tripId,
    required String title,
    required double amount,
    required DateTime expenseDate,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in');

    await _supabase.from('expenses').insert({
      'trip_id': tripId,
      'paid_by': userId,
      'title': title,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String(),
    });
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    await _supabase.from('expenses').delete().eq('id', expenseId);
  }
}
