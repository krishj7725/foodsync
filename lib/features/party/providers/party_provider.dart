import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// Simple class to hold Party Data
class PartyState {
  final bool isInParty;
  final String partyCode;
  final String partyName; // e.g., "Smith Family"

  PartyState({
    this.isInParty = false,
    this.partyCode = '',
    this.partyName = '',
  });

  PartyState copyWith({bool? isInParty, String? partyCode, String? partyName}) {
    return PartyState(
      isInParty: isInParty ?? this.isInParty,
      partyCode: partyCode ?? this.partyCode,
      partyName: partyName ?? this.partyName,
    );
  }
}

class PartyNotifier extends StateNotifier<PartyState> {
  PartyNotifier() : super(PartyState());

  // 1. CREATE PARTY (Generates a random 6-digit code)
  void createParty(String name) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    state = PartyState(isInParty: true, partyCode: code, partyName: name);
  }

  // 2. JOIN PARTY (User enters a code)
  void joinParty(String code) {
    // In a real app, this would check the database.
    // For now, we simulate a successful join.
    state = PartyState(isInParty: true, partyCode: code.toUpperCase(), partyName: "Joined Group");
  }

  // 3. LEAVE PARTY
  void leaveParty() {
    state = PartyState(isInParty: false, partyCode: '', partyName: '');
  }
}

final partyProvider = StateNotifierProvider<PartyNotifier, PartyState>((ref) {
  return PartyNotifier();
});