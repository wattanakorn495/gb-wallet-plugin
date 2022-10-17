import 'package:flutter/material.dart';
import 'package:gbkyc/utils/file_uitility.dart';

class ScanIdDetail extends StatefulWidget {
  final bool isCitizen;
  final Function? setCitizenToggle;

  const ScanIdDetail({super.key, required this.isCitizen, this.setCitizenToggle});

  @override
  ScanIdDetailSate createState() => ScanIdDetailSate();
}

class ScanIdDetailSate extends State<ScanIdDetail> {
  bool isCitizen = true;

  @override
  void initState() {
    isCitizen = widget.isCitizen;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          width: double.infinity,
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (() {
                      widget.setCitizenToggle!(true);
                      setState(() {
                        isCitizen = true;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: isCitizen ? const Color(0xFF02416D) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: isCitizen ? null : Border.all(width: 1.0, color: Colors.grey[300] ?? const Color.fromARGB(255, 222, 221, 221))),
                      child: Text(
                        'thai_person'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isCitizen
                              ? Colors.white
                              : const Color(
                                  0xFF02416D,
                                ),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (() {
                      widget.setCitizenToggle!(false);
                      setState(() {
                        isCitizen = false;
                      });
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCitizen ? Colors.white : const Color(0xFF02416D),
                        borderRadius: BorderRadius.circular(8),
                        border: isCitizen ? Border.all(width: 1.0, color: Colors.grey[300] ?? const Color.fromARGB(255, 222, 221, 221)) : null,
                      ),
                      child: Text(
                        'foreigner'.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isCitizen ? const Color(0xFF02416D) : Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            isCitizen ? _citizenDetail() : _passportDetail()
          ])),
    );
  }

  Widget _citizenDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('idcard'.tr(), style: const TextStyle(fontSize: 24)),
        Text('idcard_security'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('suggestion'.tr(), style: const TextStyle(fontSize: 20)),
            _buildSuggestion('photolight'.tr()),
            _buildSuggestion('photoandIDcard_info'.tr()),
            _buildSuggestion('photoandIDcard_glare'.tr()),
            _buildSuggestion('idcard_official'.tr()),
          ]),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('idcard_policy'.tr(), style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _passportDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('passport_scan'.tr(), style: const TextStyle(fontSize: 24)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/passport_scan.png', package: 'gbkyc', scale: 2),
          ],
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('suggestion'.tr(), style: const TextStyle(fontSize: 20)),
            _buildSuggestion('photolight'.tr()),
            _buildSuggestion('photoandPassport_info'.tr()),
            _buildSuggestion('photoandPassport_glare'.tr()),
            _buildSuggestion('passport_official'.tr()),
          ]),
        ),
        const SizedBox(height: 10),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('idcard_policy'.tr(), style: const TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildSuggestion(String topic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Image.asset(
          'assets/images/Check.png',
          package: 'gbkyc',
          height: 24,
          width: 24,
        ),
        const SizedBox(
          width: 8,
        ),
        Text(topic, style: const TextStyle(color: Colors.black54, fontSize: 16)),
      ]),
    );
  }
}
