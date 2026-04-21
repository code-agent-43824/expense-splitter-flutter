import 'package:flutter/material.dart';

void main() {
  runApp(const ReceiptSplitApp());
}

class ReceiptSplitApp extends StatelessWidget {
  const ReceiptSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B6CFF),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Делим расходы',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const SplitPage(),
    );
  }
}

class SplitPage extends StatefulWidget {
  const SplitPage({super.key});

  @override
  State<SplitPage> createState() => _SplitPageState();
}

class _SplitPageState extends State<SplitPage> {
  final _totalController = TextEditingController(text: '0');
  final List<ParticipantInput> _participants = [
    ParticipantInput(
      name: 'Аня',
      paidController: TextEditingController(text: '0'),
    ),
    ParticipantInput(
      name: 'Борис',
      paidController: TextEditingController(text: '0'),
    ),
  ];

  @override
  void dispose() {
    _totalController.dispose();
    for (final participant in _participants) {
      participant.nameController.dispose();
      participant.paidController.dispose();
    }
    super.dispose();
  }

  void _addParticipant() {
    setState(() {
      _participants.add(
        ParticipantInput(
          name: 'Участник ${_participants.length + 1}',
          paidController: TextEditingController(text: '0'),
        ),
      );
    });
  }

  void _removeParticipant(int index) {
    if (_participants.length <= 1) {
      return;
    }

    setState(() {
      _participants[index].nameController.dispose();
      _participants[index].paidController.dispose();
      _participants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = ReceiptCalculator.calculate(
      totalInput: _totalController.text,
      participants: _participants,
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      equalShareText: _formatMoney(result.equalShareCents),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Сумма чека'),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _totalController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Общая сумма',
                              prefixText: '₽ ',
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (result.error != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              result.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: _SectionTitle(
                                  'Кто участвовал и кто платил',
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: _addParticipant,
                                icon: const Icon(Icons.add),
                                label: const Text('Добавить'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          for (
                            var index = 0;
                            index < _participants.length;
                            index++
                          ) ...[
                            _ParticipantCard(
                              participant: _participants[index],
                              canRemove: _participants.length > 1,
                              onChanged: () => setState(() {}),
                              onRemove: () => _removeParticipant(index),
                            ),
                            if (index != _participants.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Баланс'),
                          const SizedBox(height: 12),
                          _SummaryRow(
                            label: 'Сумма чека',
                            value: _formatMoney(result.totalCents),
                          ),
                          _SummaryRow(
                            label: 'Участников',
                            value: '${result.participants.length}',
                          ),
                          _SummaryRow(
                            label: 'Поровну на человека',
                            value: _formatMoney(result.equalShareCents),
                            emphasize: true,
                          ),
                          const SizedBox(height: 12),
                          for (final participant in result.participants) ...[
                            _BalanceTile(participant: participant),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Кто кому должен'),
                          const SizedBox(height: 12),
                          if (result.settlements.isEmpty)
                            const Text(
                              'Все сошлось. Дополнительных переводов не нужно.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Column(
                              children: [
                                for (final settlement
                                    in result.settlements) ...[
                                  _SettlementTile(settlement: settlement),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _formatMoney(int cents) {
    final negative = cents < 0;
    final absolute = cents.abs();
    final rubles = absolute ~/ 100;
    final kopeks = absolute % 100;
    final text = '$rubles.${kopeks.toString().padLeft(2, '0')} ₽';
    return negative ? '-$text' : text;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.equalShareText});

  final String equalShareText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B6CFF), Color(0xFF8F6BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Делим расходы',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Вводишь сумму чека и кто сколько заплатил. Приложение само покажет, как закрыть долг.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Поровну на человека',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    Text(
                      equalShareText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ParticipantCard extends StatelessWidget {
  const _ParticipantCard({
    required this.participant,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final ParticipantInput participant;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TextField(
            controller: participant.nameController,
            decoration: const InputDecoration(labelText: 'Имя'),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: participant.paidController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Заплатил',
                    prefixText: '₽ ',
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: canRemove ? onRemove : null,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textStyle)),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({required this.participant});

  final ParticipantResult participant;

  @override
  Widget build(BuildContext context) {
    final balance = participant.balanceCents;
    final positive = balance > 0;
    final neutral = balance == 0;
    final color = neutral
        ? const Color(0xFF6B7280)
        : positive
        ? const Color(0xFF0F9D58)
        : const Color(0xFFD93025);
    final label = neutral
        ? 'без разницы'
        : positive
        ? 'должны получить'
        : 'должны доплатить';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Заплатил ${_SplitPageState._formatMoney(participant.paidCents)}',
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _SplitPageState._formatMoney(balance.abs()),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({required this.settlement});

  final Settlement settlement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_outward_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${settlement.from} переводит ${settlement.to}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _SplitPageState._formatMoney(settlement.amountCents),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class ParticipantInput {
  ParticipantInput({required String name, required this.paidController})
    : nameController = TextEditingController(text: name);

  final TextEditingController nameController;
  final TextEditingController paidController;

  String get name => nameController.text.trim();
}

class ParticipantResult {
  const ParticipantResult({
    required this.name,
    required this.paidCents,
    required this.shareCents,
    required this.balanceCents,
  });

  final String name;
  final int paidCents;
  final int shareCents;
  final int balanceCents;
}

class Settlement {
  const Settlement({
    required this.from,
    required this.to,
    required this.amountCents,
  });

  final String from;
  final String to;
  final int amountCents;
}

class CalculationResult {
  const CalculationResult({
    required this.totalCents,
    required this.equalShareCents,
    required this.participants,
    required this.settlements,
    this.error,
  });

  final int totalCents;
  final int equalShareCents;
  final List<ParticipantResult> participants;
  final List<Settlement> settlements;
  final String? error;
}

class ReceiptCalculator {
  static CalculationResult calculate({
    required String totalInput,
    required List<ParticipantInput> participants,
  }) {
    final totalCents = _parseMoneyToCents(totalInput);
    if (totalCents == null || totalCents < 0) {
      return CalculationResult(
        totalCents: 0,
        equalShareCents: 0,
        participants: const [],
        settlements: const [],
        error: 'Введите корректную сумму чека.',
      );
    }

    if (participants.isEmpty) {
      return CalculationResult(
        totalCents: totalCents,
        equalShareCents: 0,
        participants: const [],
        settlements: const [],
        error: 'Добавьте хотя бы одного участника.',
      );
    }

    final names = <String>{};
    final normalized = <_ParticipantMoney>[];
    for (var index = 0; index < participants.length; index++) {
      final input = participants[index];
      final name = input.name.isEmpty ? 'Участник ${index + 1}' : input.name;
      final paid = _parseMoneyToCents(input.paidController.text);
      if (paid == null || paid < 0) {
        return CalculationResult(
          totalCents: totalCents,
          equalShareCents: 0,
          participants: const [],
          settlements: const [],
          error: 'Проверьте суммы у участников. Нужны числа не меньше нуля.',
        );
      }
      if (!names.add(name)) {
        return CalculationResult(
          totalCents: totalCents,
          equalShareCents: 0,
          participants: const [],
          settlements: const [],
          error: 'Имена участников должны быть уникальными.',
        );
      }
      normalized.add(_ParticipantMoney(name: name, paidCents: paid));
    }

    final baseShare = totalCents ~/ normalized.length;
    final remainder = totalCents % normalized.length;

    final participantResults = <ParticipantResult>[];
    for (var index = 0; index < normalized.length; index++) {
      final share = baseShare + (index < remainder ? 1 : 0);
      final item = normalized[index];
      participantResults.add(
        ParticipantResult(
          name: item.name,
          paidCents: item.paidCents,
          shareCents: share,
          balanceCents: item.paidCents - share,
        ),
      );
    }

    final settlements = _buildSettlements(participantResults);
    final equalShareRounded = normalized.isEmpty
        ? 0
        : totalCents ~/ normalized.length;

    return CalculationResult(
      totalCents: totalCents,
      equalShareCents: equalShareRounded,
      participants: participantResults,
      settlements: settlements,
    );
  }

  static List<Settlement> _buildSettlements(
    List<ParticipantResult> participants,
  ) {
    final creditors = participants
        .where((p) => p.balanceCents > 0)
        .map((p) => _BalanceEntry(name: p.name, cents: p.balanceCents))
        .toList();
    final debtors = participants
        .where((p) => p.balanceCents < 0)
        .map((p) => _BalanceEntry(name: p.name, cents: -p.balanceCents))
        .toList();

    creditors.sort((a, b) => b.cents.compareTo(a.cents));
    debtors.sort((a, b) => b.cents.compareTo(a.cents));

    final settlements = <Settlement>[];
    var creditorIndex = 0;
    var debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];
      final amount = creditor.cents < debtor.cents
          ? creditor.cents
          : debtor.cents;

      if (amount > 0) {
        settlements.add(
          Settlement(from: debtor.name, to: creditor.name, amountCents: amount),
        );
      }

      creditor.cents -= amount;
      debtor.cents -= amount;

      if (creditor.cents == 0) {
        creditorIndex++;
      }
      if (debtor.cents == 0) {
        debtorIndex++;
      }
    }

    return settlements;
  }

  static int? _parseMoneyToCents(String input) {
    final sanitized = input.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (sanitized.isEmpty) {
      return 0;
    }

    final match = RegExp(r'^-?(\d+)(?:\.(\d{0,2}))?$').firstMatch(sanitized);
    if (match == null) {
      return null;
    }

    final sign = sanitized.startsWith('-') ? -1 : 1;
    final whole = int.tryParse(match.group(1) ?? '');
    if (whole == null) {
      return null;
    }

    final decimalRaw = (match.group(2) ?? '').padRight(2, '0');
    final decimal = decimalRaw.isEmpty ? 0 : int.tryParse(decimalRaw);
    if (decimal == null) {
      return null;
    }

    return sign * (whole * 100 + decimal);
  }
}

class _ParticipantMoney {
  const _ParticipantMoney({required this.name, required this.paidCents});

  final String name;
  final int paidCents;
}

class _BalanceEntry {
  _BalanceEntry({required this.name, required this.cents});

  final String name;
  int cents;
}
