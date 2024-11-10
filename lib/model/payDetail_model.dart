class PaydetailModel {
  String? amount;
  String? bankType;
  String? codeBank;
  String? cardType;
  String? payDate;
  String? status;

  PaydetailModel({
    this.amount,
    this.bankType,
    this.codeBank,
    this.cardType,
    this.payDate,
    this.status
  });

    Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'bankType': bankType,
      'cardType': cardType,
      'codeBank': codeBank,
      'payDate': payDate,
      'status': status,
    };
  }


}