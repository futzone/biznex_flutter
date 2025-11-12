import '../../model/order_models/order.dart';
import '../../model/transaction_model/transaction_isar.dart';
import '../../model/transaction_model/transaction_model.dart';

extension TransactionToIsar on Transaction {
  TransactionIsar toIsar() {
    final t = TransactionIsar()
      ..id = id
      ..createdDate = createdDate
      ..paymentType = paymentType
      ..note = note
      ..value = value
      ..orderId = order?.id;

    if (employee != null) {
      t.employee = EmployeeIsar()
        ..id = employee!.id
        ..fullname = employee!.fullname
        ..createdDate = employee!.createdDate
        ..phone = employee!.phone
        ..description = employee!.description
        ..roleId = employee!.roleId
        ..roleName = employee!.roleName
        ..pincode = employee!.pincode;
    }

    t.paymentTypes = [];

    return t;
  }
}
