import '../../domain/models/debt.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/finance_summary.dart';
import '../../domain/models/income.dart';
import '../../domain/models/due_period.dart';
import '../../domain/models/payment.dart';


class DebtDto {
  final int id;
  final String? unitDisplay;
  final String? apartmentName;
  final String description;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final double lateFeeAmount;
  final double lateFeeRate;
  final String status;
  final String statusDisplay;
  final String category;
  final String categoryDisplay;
  final String dueDate;
  final String createdAt;
  final List<PaymentDto> payments;

  const DebtDto({
    required this.id,
    this.unitDisplay,
    this.apartmentName,
    required this.description,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.lateFeeAmount,
    required this.lateFeeRate,
    required this.status,
    required this.statusDisplay,
    required this.category,
    required this.categoryDisplay,
    required this.dueDate,
    required this.createdAt,
    this.payments = const [],
  });

  factory DebtDto.fromJson(Map<String, dynamic> json) {
    return DebtDto(
      id: json['id'] as int? ?? 0,
      unitDisplay: json['transaction_id'] as String? ?? json['unit_display'] as String?,
      apartmentName: json['apartment_name'] as String?,
      description: json['description'] as String? ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      paidAmount: double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0,
      remainingAmount: double.tryParse(json['remaining_amount']?.toString() ?? '0') ?? 0,
      lateFeeAmount: double.tryParse(json['late_fee_amount']?.toString() ?? '0') ?? 0,
      lateFeeRate: double.tryParse(json['late_fee_rate']?.toString() ?? '0') ?? 0,
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      payments: (json['payments'] as List<dynamic>? ?? []).map((e) => PaymentDto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Debt toModel() {
    return Debt(
      id: id.toString(),
      unitDisplay: unitDisplay,
      apartmentName: apartmentName,
      description: description,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      lateFeeAmount: lateFeeAmount,
      lateFeeRate: lateFeeRate,
      status: status,
      statusDisplay: statusDisplay,
      category: category,
      categoryDisplay: categoryDisplay,
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      payments: payments.map((p) => p.toModel()).toList(),
    );
  }
}

class ExpenseDto {
  final int id;
  final String? apartmentName;
  final String title;
  final double amount;
  final String category;
  final String categoryDisplay;
  final String date;
  final String description;
  final String? createdByName;

  const ExpenseDto({
    required this.id,
    this.apartmentName,
    required this.title,
    required this.amount,
    required this.category,
    required this.categoryDisplay,
    required this.date,
    required this.description,
    this.createdByName,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) {
    return ExpenseDto(
      id: json['id'] as int? ?? 0,
      apartmentName: json['apartment_name'] as String?,
      title: json['title'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String? ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdByName: json['created_by_name'] as String?,
    );
  }

  Expense toModel() {
    return Expense(
      id: id.toString(),
      apartmentName: apartmentName,
      title: title,
      amount: amount,
      category: category,
      categoryDisplay: categoryDisplay,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      description: description,
      createdByName: createdByName,
    );
  }
}

class FinanceSummaryDto {
  final double totalDebts;
  final double totalPaid;
  final double totalUnpaid;
  final double totalOverdue;
  final double totalLateFee;

  const FinanceSummaryDto({
    required this.totalDebts,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalOverdue,
    required this.totalLateFee,
  });

  factory FinanceSummaryDto.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryDto(
      totalDebts: double.tryParse(json['total_debts']?.toString() ?? '0') ?? 0,
      totalPaid: double.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
      totalUnpaid: double.tryParse(json['total_unpaid']?.toString() ?? '0') ?? 0,
      totalOverdue: double.tryParse(json['total_overdue']?.toString() ?? '0') ?? 0,
      totalLateFee: double.tryParse(json['total_late_fee']?.toString() ?? '0') ?? 0,
    );
  }

  FinanceSummary toModel() {
    
    return FinanceSummary(
      totalDebts: totalDebts,
      totalPaid: totalPaid,
      totalUnpaid: totalUnpaid,
      totalOverdue: totalOverdue,
      totalLateFee: totalLateFee,
    );
  }
}

class IncomeDto {
  final int id;
  final String? apartmentName;
  final String title;
  final double amount;
  final String category;
  final String categoryDisplay;
  final String date;
  final String description;

  const IncomeDto({
    required this.id,
    this.apartmentName,
    required this.title,
    required this.amount,
    required this.category,
    required this.categoryDisplay,
    required this.date,
    required this.description,
  });

  factory IncomeDto.fromJson(Map<String, dynamic> json) {
    return IncomeDto(
      id: json['id'] as int? ?? 0,
      apartmentName: json['apartment_name'] as String?,
      title: json['title'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String? ?? '',
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Income toModel() {
    
    return Income(
      id: id.toString(),
      apartmentName: apartmentName,
      title: title,
      amount: amount,
      category: category,
      categoryDisplay: categoryDisplay,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      description: description,
    );
  }
}

class DuePeriodDto {
  final int id;
  final String? apartmentName;
  final String period;
  final double amount;
  final String dueDate;

  const DuePeriodDto({
    required this.id,
    this.apartmentName,
    required this.period,
    required this.amount,
    required this.dueDate,
  });

  factory DuePeriodDto.fromJson(Map<String, dynamic> json) {
    return DuePeriodDto(
      id: json['id'] as int? ?? 0,
      apartmentName: json['apartment_name'] as String?,
      period: json['period'] as String? ?? json['month_display'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      dueDate: json['due_date'] as String? ?? '',
    );
  }

  DuePeriod toModel() {
    return DuePeriod(
      id: id.toString(),
      apartmentName: apartmentName ?? '',
      period: period,
      amount: amount,
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
    );
  }
}

class PaymentDto {
  final int id;
  final int? debtId;
  final String? debtDescription;
  final String? unitDisplay;
  final double amount;
  final String paymentDate;
  final String status;
  final String statusDisplay;

  const PaymentDto({
    required this.id,
    this.debtId,
    this.debtDescription,
    this.unitDisplay,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.statusDisplay,
  });

  factory PaymentDto.fromJson(Map<String, dynamic> json) {
    return PaymentDto(
      id: json['id'] as int? ?? 0,
      debtId: json['debt'] as int?,
      debtDescription: json['description'] as String? ?? json['debt_description'] as String?,
      unitDisplay: json['transaction_id'] as String? ?? json['unit_display'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      paymentDate: json['payment_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
    );
  }

  Payment toModel() {
    
    return Payment(
      id: id.toString(),
      debtId: debtId?.toString() ?? '',
      debtDescription: debtDescription,
      unitDisplay: unitDisplay,
      amount: amount,
      paymentDate: DateTime.tryParse(paymentDate) ?? DateTime.now(),
      status: status,
      statusDisplay: statusDisplay,
    );
  }
}

class PaymentInitiateRequestDto {
  final String cardName;
  final String cardNumber;
  final String cardExpiry;
  final String cardCvv;

  const PaymentInitiateRequestDto({
    required this.cardName,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cardCvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'card_name': cardName,
      'card_number': cardNumber,
      'card_expiry': cardExpiry,
      'card_cvv': cardCvv,
    };
  }
}

class PaymentInitiateResponseDto {
  final bool success;
  final bool needs3ds;
  final String? htmlContent;
  final String? detail;

  const PaymentInitiateResponseDto({
    required this.success,
    required this.needs3ds,
    this.htmlContent,
    this.detail,
  });

  factory PaymentInitiateResponseDto.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateResponseDto(
      success: json['success'] as bool? ?? false,
      needs3ds: json['needs_3ds'] as bool? ?? false,
      htmlContent: json['html_content'] as String?,
      detail: json['detail'] as String?,
    );
  }
}
