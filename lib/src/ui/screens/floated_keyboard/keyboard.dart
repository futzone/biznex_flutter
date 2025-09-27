import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import '../../../../biznex.dart';

class NumberKeyboardScreen extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String str) onChanged;

  const NumberKeyboardScreen(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(
      builder: (theme, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: Dis.only(lr: 16, tb: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.accentColor, width: 2),
            ),
            child: TextField(
              // onChanged: onChanged,
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 32, fontFamily: mediumFamily),
            ),
          ),
          20.h,
          Expanded(
            child: _NumberKeyboard(
              onTextInput: (text) {
                controller.text += text;
                onChanged(controller.text);
              },
              onBackspace: () {
                final list = controller.text.split('');
                if (list.isEmpty) return;
                list.removeLast();
                controller.text = list.join('');
              },
            ),
          ),
          20.h,
          ElevatedButton(
            onPressed: () => AppRouter.close(context),
            style: ElevatedButton.styleFrom(
              padding: Dis.only(tb: 20),
              backgroundColor: AppColors(isDark: false).scaffoldBgColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Center(
              child: Text(
                AppLocales.save.tr(),
                style: const TextStyle(fontSize: 24, fontFamily: regularFamily),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberKeyboard extends StatelessWidget {
  final ValueChanged<String> onTextInput;
  final VoidCallback onBackspace;

  const _NumberKeyboard({
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
