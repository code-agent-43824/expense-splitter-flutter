import 'package:expense_splitter_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptCalculator', () {
    test('splits evenly and builds settlements for multiple payers', () {
      final participants = [
        ParticipantInput(
          name: 'Аня',
          paidController: TextEditingController(text: '900'),
        ),
        ParticipantInput(
          name: 'Борис',
          paidController: TextEditingController(text: '300'),
        ),
        ParticipantInput(
          name: 'Вика',
          paidController: TextEditingController(text: '0'),
        ),
      ];

      final result = ReceiptCalculator.calculate(
        totalInput: '1200',
        participants: participants,
      );

      expect(result.error, isNull);
      expect(result.equalShareCents, 40000);
      expect(result.participants.map((p) => p.balanceCents).toList(), [
        50000,
        -10000,
        -40000,
      ]);
      expect(result.settlements.length, 2);
      expect(result.settlements[0].from, 'Вика');
      expect(result.settlements[0].to, 'Аня');
      expect(result.settlements[0].amountCents, 40000);
      expect(result.settlements[1].from, 'Борис');
      expect(result.settlements[1].to, 'Аня');
      expect(result.settlements[1].amountCents, 10000);
    });

    test('returns validation error for duplicate names', () {
      final participants = [
        ParticipantInput(
          name: 'Аня',
          paidController: TextEditingController(text: '100'),
        ),
        ParticipantInput(
          name: 'Аня',
          paidController: TextEditingController(text: '100'),
        ),
      ];

      final result = ReceiptCalculator.calculate(
        totalInput: '200',
        participants: participants,
      );

      expect(result.error, isNotNull);
    });

    test('returns validation error when paid sum exceeds receipt total', () {
      final participants = [
        ParticipantInput(
          name: 'Аня',
          paidController: TextEditingController(text: '700'),
        ),
        ParticipantInput(
          name: 'Борис',
          paidController: TextEditingController(text: '400'),
        ),
      ];

      final result = ReceiptCalculator.calculate(
        totalInput: '1000',
        participants: participants,
      );

      expect(result.error, 'Сумма оплат не может быть больше суммы чека.');
    });

    test('calculates remaining allowed amount for current participant', () {
      expect(
        ReceiptCalculator.remainingAllowedPaidCents(
          totalCents: 100000,
          otherPaidCents: 65000,
        ),
        35000,
      );
      expect(
        ReceiptCalculator.remainingAllowedPaidCents(
          totalCents: 100000,
          otherPaidCents: 120000,
        ),
        0,
      );
    });
  });
}
