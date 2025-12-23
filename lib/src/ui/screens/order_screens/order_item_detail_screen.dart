import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/device_type.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../biznex.dart';

class OrderItemDetailScreen extends HookConsumerWidget {
  final void Function(double amount) onUpdateItemDetails;

  final void Function()? onDeletePressed;
  final OrderItem product;

  const OrderItemDetailScreen({
    super.key,
    required this.onUpdateItemDetails,
    required this.product,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context, ref) {
    final amountController =
        useTextEditingController(text: product.amount.toMeasure);
    final priceController = useTextEditingController(
        text: (product.product.price * product.amount).toMeasure);
    final focus = useState(0);

    void onUpdateDetails() {
      final price =
          double.tryParse(priceController.text.trim()) ?? product.product.price;
      final amount = double.tryParse(amountController.text.trim()) ?? 1;
      if (focus.value == 1) {
        amountController.text = (price / product.product.price).toMeasure;
      } else {
        priceController.text = (product.product.price * amount).toMeasure;
      }
    }

    final mobile = getDeviceType(context) == DeviceType.mobile;

    return AppStateWrapper(builder: (theme, state) {
      return Column(
        children: [
          Row(
            children: [
              Text(
                product.product.name,
                style: TextStyle(
                  fontFamily: boldFamily,
                  fontSize: mobile ? 16 : 18,
                ),
              ),
              Spacer(),
              Text(
                product.product.price.priceUZS,
                style: TextStyle(
                  fontFamily: boldFamily,
                  fontSize: mobile ? 16 : 18,
                ),
              ),
              Spacer(),
              AppPrimaryButton(
                theme: theme,
                onPressed: () {
                  if (onDeletePressed == null) return;
                  onDeletePressed!();
                  AppRouter.close(context);
                },
                icon: Iconsax.trash_copy,
                padding: Dis.all(8),
                color: Colors.red,
                border: Border.all(color: Colors.red),
              ),
            ],
          ),
          context.h(16).h,
          Row(
            spacing: context.w(16),
            children: [
              Expanded(
                child: Container(
                  padding: Dis.only(lr: context.w(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: focus.value == 1
                            ? theme.mainColor
                            : theme.secondaryTextColor,
                        width: 2),
                  ),
                  child: TextField(
                    onTap: () {
                      focus.value = 1;
                      try {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      } catch (_) {}
                    },
                    cursorColor: theme.mainColor,
                    readOnly: true,
                    style: TextStyle(
                        fontSize: mobile ? 16 : 24, fontFamily: boldFamily),
                    textAlign: TextAlign.start,
                    controller: priceController,
                    decoration: InputDecoration(
                      contentPadding: Dis.only(tb: mobile ? 16 : 24),
                      border: InputBorder.none,
                      suffix: Text(
                        'UZS',
                        style: TextStyle(fontFamily: regularFamily),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: Dis.only(lr: context.w(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: focus.value == 2
                            ? theme.mainColor
                            : theme.secondaryTextColor,
                        width: 2),
                  ),
                  child: TextField(
                    onTap: () {
                      focus.value = 2;
                      try {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      } catch (_) {}
                    },
                    cursorColor: theme.mainColor,
                    readOnly: true,
                    style: TextStyle(
                        fontSize: mobile ? 16 : 24, fontFamily: boldFamily),
                    textAlign: TextAlign.start,
                    controller: amountController,
                    decoration: InputDecoration(
                      contentPadding: Dis.only(tb: mobile ? 16 : 24),
                      border: InputBorder.none,
                      suffix: Text(
                        product.product.measure ?? '',
                        style: TextStyle(fontFamily: regularFamily),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          context.h(16).h,
          Expanded(
            child: NumberKeyboard(
              onBackspace: () {
                if (focus.value == 0) {
                  focus.value = 2;
                }

                if (focus.value == 2) {
                  final list = amountController.text.split('');
                  list.removeLast();
                  amountController.text = list.join('');
                }

                if (focus.value == 1) {
                  final list = priceController.text.split('');
                  list.removeLast();
                  priceController.text = list.join('');
                }

                onUpdateDetails();
              },
              onTextInput: (val) {
                if (focus.value == 0) {
                  focus.value = 2;
                }

                if (focus.value == 2) {
                  amountController.text += val;
                }

                if (focus.value == 1) {
                  priceController.text += val;
                }

                onUpdateDetails();
              },
            ),
          ),
          context.h(16).h,
          Row(
            spacing: context.w(16),
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.scaffoldBgColor,
                    padding: Dis.only(tb: context.h(32)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.close, size: 24),
                      Text(AppLocales.close.tr(),
                          style:
                              TextStyle(fontSize: 16, fontFamily: boldFamily)),
                    ],
                  ),
                  onPressed: () {
                    AppRouter.close(context);
                  },
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  // padding: Dis.only(tb: 16),
                  // theme: theme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.mainColor,
                    padding: Dis.only(tb: context.h(32)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.save, size: 24, color: Colors.white),
                      Text(
                        AppLocales.save.tr(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: boldFamily),
                      ),
                    ],
                  ),
                  onPressed: () {
                    onUpdateItemDetails(
                      double.parse(amountController.text.trim()),
                    );

                    AppRouter.close(context);
                  },
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}

class NumberKeyboard extends StatelessWidget {
  final ValueChanged<String> onTextInput;
  final VoidCallback onBackspace;

  const NumberKeyboard({
    super.key,
    required this.onTextInput,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        _buildRow(['1', '2', '3']),
        _buildRow(['4', '5', '6']),
        _buildRow(['7', '8', '9']),
        _buildRow(['.', '0', '⌫']),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        spacing: 16,
        children: keys.map((key) {
          if (key == '⌫') {
            return _buildButton(key, () => onBackspace());
          }
          return _buildButton(key, () => onTextInput(key));
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors(isDark: false).scaffoldBgColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 32, fontFamily: boldFamily),
          ),
        ),
      ),
    );
  }
}
