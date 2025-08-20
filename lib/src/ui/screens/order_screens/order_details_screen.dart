import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

import '../../widgets/custom/app_text_widgets.dart';
import '../customer_screens/customers_screen.dart';

class OrderDetailsScreen extends StatefulHookWidget {
  final ValueNotifier<Customer?> customerNotifier;
  final TextEditingController noteController;
  final AppColors theme;

  const OrderDetailsScreen({
    super.key,
    required this.customerNotifier,
    required this.noteController,
    required this.theme,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final showNoteInput = useState(false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        16.h,
        if (showNoteInput.value)
          AppTextField(
            title: AppLocales.enterNoteForOrder.tr(),
            controller: widget.noteController,
            theme: widget.theme,
            minLines: 3,
            suffixIcon: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    showNoteInput.value = false;
                  },
                  icon: Icon(Icons.done, color: widget.theme.mainColor),
                ),
                4.h,
                IconButton(
                  onPressed: () {
                    widget.noteController.clear();
                    showNoteInput.value = false;
                  },
                  icon: Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
          ),
        if (showNoteInput.value) 16.h,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 16,
          children: [
            if (!showNoteInput.value)
              Expanded(
                child: AppPrimaryButton(
                  color: widget.theme.mainColor.withOpacity(0.2),
                  theme: widget.theme,
                  onPressed: () {
                    showNoteInput.value = true;
                  },
                  padding: Dis.only(lr: 16, tb: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.note_alt_outlined),
                      if (widget.noteController.text.trim().isEmpty)
                        AppText.$14Bold(AppLocales.addNote.tr())
                      else
                        Expanded(
                          child: Text(
                            widget.noteController.text.trim(),
                            style: TextStyle(fontSize: 14, fontFamily: boldFamily),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (widget.noteController.text.trim().isNotEmpty) Spacer(),
                      if (widget.noteController.text.trim().isNotEmpty)
                        IconButton(
                          onPressed: () {
                            widget.noteController.clear();
                            setState(() {});
                          },
                          icon: Icon(
                            Ionicons.close_circle_outline,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: AppPrimaryButton(
                color: widget.theme.mainColor.withOpacity(0.2),
                theme: widget.theme,
                onPressed: () {
                  showDesktopModal(
                    context: context,
                    body: CustomersScreen(
                      onSelected: (customerVal) {
                        widget.customerNotifier.value = customerVal;
                      },
                    ),
                  );
                },
                padding: Dis.only(lr: 16, tb: 12),
                child: Row(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline),
                    if (widget.customerNotifier.value == null)
                      AppText.$14Bold(AppLocales.addClient.tr())
                    else
                      AppText.$14Bold(widget.customerNotifier.value!.name),
                    if (widget.customerNotifier.value != null) Spacer(),
                    if (widget.customerNotifier.value != null)
                      IconButton(
                        onPressed: () => widget.customerNotifier.value = null,
                        icon: Icon(
                          Ionicons.close_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
