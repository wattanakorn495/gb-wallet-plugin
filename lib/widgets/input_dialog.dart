import 'package:flutter/material.dart';
import 'package:gbkyc/utils/file_uitility.dart';

class InputDialog extends StatelessWidget {
  final String? title, content;
  final Function(String) onPressedConfirm;
  final inputController = TextEditingController();
  InputDialog({
    Key? key,
    this.title,
    this.content,
    required this.onPressedConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: Key('InputDialog_plugin_${DateTime.now().toString()}'),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(alignment: Alignment.topCenter, children: [
      Container(
        margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title ?? '-',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: inputController,
            style: const TextStyle(fontSize: 16),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: content ?? 'please_enter'.tr()),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: MaterialButton(
                minWidth: double.infinity,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: colorGradientDark),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel".tr(),
                  style: const TextStyle(
                    color: colorGradientDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorGradientLight,
                      colorGradientDark,
                    ],
                  ),
                ),
                child: MaterialButton(
                  minWidth: double.infinity,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onPressed: () {
                    onPressedConfirm(inputController.text);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ok'.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    ]);
  }
}
