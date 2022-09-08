import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gbkyc/address_bloc.dart';
import 'package:gbkyc/api/config_api.dart';
import 'package:gbkyc/api/get_api.dart';
import 'package:gbkyc/api/post_api.dart';
import 'package:gbkyc/personal_info_model.dart';
import 'package:gbkyc/scan_id_card.dart';
import 'package:gbkyc/state_store.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:gbkyc/widgets/button_confirm.dart';
import 'package:gbkyc/widgets/custom_dialog.dart';
import 'package:gbkyc/widgets/select_address.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PersonalInfo extends StatefulWidget {
  final dynamic ocrAllFailed;
  final PersonalInfoModel? person;
  final Function? setSelectedStep;
  final Function? setPinVisible;
  final Function? setFirstName;
  final Function? setLastName;
  final Function? setFirstNameEng;
  final Function? setLastNameEng;
  final Function? setAddress;
  final Function? setAddressSearch;
  final Function? setBirthday;
  final Function? setIDCard;
  final Function? setLaserCode;
  final Function? setCareerID;
  final Function? setWorkName;
  final Function? setWorkAddress;
  final Function? setWorkAddressSearch;
  final Function? setindexProvince;
  final Function? setindexDistric;
  final Function? setindexSubDistric;
  final Function? setFileFrontCitizen;
  final Function? setFileBackCitizen;
  final Function? setFileSelfie;
  final Function? setDataVisible;
  final dynamic address;
  final int? provinceID;
  final int? districtId;
  final int? subDistrictId;

  const PersonalInfo({
    this.ocrAllFailed,
    this.person,
    this.setPinVisible,
    this.setSelectedStep,
    this.setCareerID,
    this.setWorkAddress,
    this.setWorkName,
    this.setWorkAddressSearch,
    this.setindexProvince,
    this.setindexDistric,
    this.setindexSubDistric,
    this.setFileFrontCitizen,
    this.setFileBackCitizen,
    this.setFileSelfie,
    this.setFirstName,
    this.setLastName,
    this.setFirstNameEng,
    this.setLastNameEng,
    this.setAddress,
    this.setAddressSearch,
    this.setBirthday,
    this.setIDCard,
    this.setLaserCode,
    this.setDataVisible,
    this.address,
    this.provinceID,
    this.districtId,
    this.subDistrictId,
    Key? key,
  }) : super(key: key);

  int? getIndexSubDistric() {
    return _PersonalInfoState().indexSubDistrict;
  }

  int? getIndexDistric() {
    return _PersonalInfoState().indexDistrict;
  }

  int? getIndexProvince() {
    return _PersonalInfoState().indexProvince;
  }

  int? getCareerID() {
    return _PersonalInfoState().careerId;
  }

  String? getWorkname() {
    return _PersonalInfoState().workName;
  }

  String? getWorkAddress() {
    return _PersonalInfoState().workAddress;
  }

  String? getWorkAdressSearch() {
    return _PersonalInfoState().workAdressSearch;
  }

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  String checkImage = "assets/images/Check.png";
  String unCheckImage = "assets/images/uncheck.png";
  String cameraImage = "assets/icons/camera.png";
  String? workName, workAddress, workAdressSearch;
  String? textBirthday;
  String? ocrResult;
  String? ocrResultStatus;
  String frontIDCardImage = "", backIDCardImage = "", selfieIDCard = "";
  String? fileFrontCitizen;
  String? fileBackCitizen;
  String? fileSelfie;

  int? indexCareer;
  int? indexCareerChild;
  int? careerId;
  int? careerChildId;

  int? indexProvince;
  int? indexDistrict;
  int? indexSubDistrict;

  bool checkValidate = false;
  bool skipInfomation = false;
  bool validateCareer = false;
  bool validateCareerChild = false;
  bool isChecked = false;

  final GlobalKey<FormState> _formKey = GlobalKey();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final firstnameEngController = TextEditingController();
  final lastnameEngController = TextEditingController();
  final addressController = TextEditingController();
  final addressShowController = TextEditingController();
  final idCardController = TextEditingController();
  final laserCodeController = TextEditingController();
  final birthdayController = TextEditingController();
  final workNameController = TextEditingController();
  final workAddressController = TextEditingController();
  final workAddressShowController = TextEditingController();

  MaskTextInputFormatter laserCodeFormatter = MaskTextInputFormatter(
    mask: '###-#######-##',
    filter: {"#": RegExp(r'[a-zA-Z0-9]')},
  );

  MaskTextInputFormatter idCardFormatter = MaskTextInputFormatter(
    mask: '#-####-#####-##-#',
    filter: {"#": RegExp(r'[0-9]')},
  );

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    onLoad();
    getAddress();
  }

  @override
  void dispose() {
    firstNameController.clear();
    lastNameController.clear();
    firstnameEngController.clear();
    lastnameEngController.clear();
    addressController.clear();
    addressShowController.clear();
    birthdayController.clear();
    idCardController.clear();
    workNameController.clear();
    workAddressController.clear();
    workAddressShowController.clear();

    checkValidate = false;

    super.dispose();
  }

  getAddress() {
    List dataProvince = widget.address['province'];
    List dataDistrict = widget.address['district'];
    List dataSubDistrict = widget.address['sub_district'];

    final provinceName = dataProvince.firstWhere((province) => province['id'] == widget.provinceID, orElse: (() => null));
    final districtName = dataDistrict.firstWhere((district) => district['id'] == widget.districtId, orElse: (() => null));
    final subDistricModel = dataSubDistrict.firstWhere((subDistrict) => subDistrict['id'] == widget.subDistrictId, orElse: (() => null));
    addressShowController.text =
        provinceName == null ? '' : "${provinceName?['name']}/${districtName?['name']}/${subDistricModel?['name']}/${subDistricModel?['post_code']}";

    dataProvince.sort((a, b) => a['name${'lang'.tr()}'].compareTo(b['name${'lang'.tr()}']));
    context.read<AddressBloc>().add(const ClearProvince());
    for (var item in dataProvince) {
      context.read<AddressBloc>().add(SetProvince(item));
    }
  }

  onLoad() async {
    idCardController.text = idCardFormatter.maskText(widget.person!.idCard ?? "");
    firstNameController.text = widget.person!.firstName ?? "";
    lastNameController.text = widget.person!.lastName ?? "";
    firstnameEngController.text = widget.person!.firstNameEng ?? "";
    lastnameEngController.text = widget.person!.lastNameEng ?? "";
    addressController.text = widget.person!.address ?? "";
    birthdayController.text = widget.person!.birthday ?? "";
    laserCodeController.text = laserCodeFormatter.maskText(widget.person!.ocrBackLaser ?? "");
    ocrResultStatus = widget.ocrAllFailed ? "Failed" : "Passed";
  }

  _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (popupContext) => Container(
        height: MediaQuery.of(context).size.width / 1.2,
        alignment: Alignment.center,
        color: Colors.white,
        child: Column(mainAxisSize: MainAxisSize.max, children: [
          ButtonConfirm(
            text: 'ok'.tr(),
            colorText: Colors.white,
            radius: 0,
            onPressed: () {
              birthdayController.text = textBirthday!;
              _formKey.currentState!.validate();
              Navigator.pop(popupContext);
            },
          ),
          SizedBox(
            height: 220,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              mode: CupertinoDatePickerMode.date,
              minimumYear: 1900,
              maximumYear: DateTime.now().year,
              onDateTimeChanged: (v) {
                textBirthday = DateFormat('dd/MM/yyyy').format(v);
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget workLable() {
    return (!skipInfomation)
        ? Column(children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: workNameController,
              style: const TextStyle(fontSize: 15),
              validator: (v) {
                if (v!.isEmpty && checkValidate) return 'please_enter'.tr();
                return null;
              },
              onChanged: (v) {
                _formKey.currentState!.validate();
                widget.setWorkName!(v);
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'careername'.tr()),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: workAddressShowController,
                    readOnly: true,
                    style: const TextStyle(fontSize: 15),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: "district_address".tr(),
                        hintText: "district_address".tr(),
                        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54)),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) {
                        return 'please_enter'.tr();
                      }
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    onTap: () => showModalSearchAddress('workAddress'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: workAddressController,
              style: const TextStyle(fontSize: 15),
              validator: (v) {
                if (v!.isEmpty && checkValidate) return 'please_enter'.tr();
                return null;
              },
              onChanged: (v) {
                _formKey.currentState!.validate();
                widget.setWorkAddress!(v);
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'addresscareer'.tr(), hintText: 'house_number_floor_village_road'.tr()),
            ),
          ])
        : const SizedBox();
  }

  Widget dropdownCareer() {
    if (StateStore.careers['success']) {
      final dataCareer = StateStore.careers['response']['data']['careers'];
      final data = dataCareer.map<DropdownMenuItem<int>>((item) {
        int index = dataCareer.indexOf(item);
        return DropdownMenuItem(
          value: index + 1,
          child: Text(
            '${dataCareer[index]['name_${'language'.tr()}']}',
            style: const TextStyle(fontFamily: 'kanit', package: 'gbkyc'),
          ),
        );
      }).toList();
      return Stack(children: [
        Container(
          height: 60,
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: validateCareer ? Colors.red : const Color(0xFF02416D),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
              dropdownMaxHeight: 400,
              dropdownWidth: 400,
              dropdownElevation: 8,
              dropdownDecoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              isDense: true,
              isExpanded: true,
              value: indexCareer,
              hint: Text('- ${"career".tr()} -'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: const TextStyle(color: Colors.black, fontFamily: 'kanit', package: 'gbkyc', fontSize: 15),
              onChanged: (dynamic v) {
                if (indexCareer != null) widget.setCareerID!(indexCareer);
                setState(() {
                  validateCareer = false;
                  validateCareerChild = false;
                  indexCareer = v;
                  indexCareerChild = null;
                  skipInfomation = dataCareer[v - 1]['skip_infomation'];
                  careerId = dataCareer[v - 1]['id'];
                  careerChildId = null;
                  widget.setCareerID!(v);
                });
              },
              items: data,
            ),
          ),
        ),
        if (indexCareer != null)
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              ' ${"titlecareer".tr()} ',
              style: const TextStyle(fontSize: 12, color: Colors.black54, backgroundColor: Colors.white),
            ),
          )
      ]);
    }
    return const SizedBox();
  }

  Widget dropdownCareerChild() {
    return FutureBuilder<Map>(
      future: GetAPI.call(url: '$register3003/careers/$careerId/child', headers: Authorization.auth2, context: context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const SizedBox();

          case ConnectionState.active:
            return const SizedBox();
          case ConnectionState.waiting:
            return const SizedBox();
          case ConnectionState.done:
            if (snapshot.data!['success']) {
              final List dataCareerChild = snapshot.data!['response']['data']['careers'];
              if (dataCareerChild.isNotEmpty) {
                final data = dataCareerChild.map<DropdownMenuItem<int>>((item) {
                  int index = dataCareerChild.indexOf(item);
                  return DropdownMenuItem(
                    value: index + 1,
                    child: SizedBox(
                      width: 300,
                      child: Text(
                        '${dataCareerChild[index]['name_${'language'.tr}']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList();
                return Stack(children: [
                  Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: validateCareerChild ? Colors.red : const Color(0xFF02416D),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                        buttonPadding: const EdgeInsets.symmetric(horizontal: 12),
                        dropdownMaxHeight: 400,
                        dropdownWidth: 400,
                        dropdownElevation: 8,
                        dropdownDecoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                        isExpanded: true,
                        value: indexCareerChild,
                        hint: Text('- ${"career_more".tr} -'),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(color: Colors.black, fontFamily: 'kanit', fontSize: 15),
                        onChanged: (dynamic v) {
                          setState(() {
                            validateCareerChild = false;
                            indexCareerChild = v;
                            skipInfomation = dataCareerChild[v - 1]['skip_infomation'];
                            careerChildId = dataCareerChild[v - 1]['id'];
                          });
                        },
                        items: data,
                      ),
                    ),
                  ),
                  if (indexCareerChild != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Text(
                        ' ${"career_more_choice".tr} ',
                        style: const TextStyle(fontSize: 12, color: Colors.black54, backgroundColor: Colors.white),
                      ),
                    )
                ]);
              }
              return const SizedBox();
            }
            return const SizedBox();
        }
      },
    );
  }

  void showModalSearchAddress(String from) {
    context.read<AddressBloc>().add(const ClearDistrict());
    context.read<AddressBloc>().add(const ClearSubDistrict());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => SelectAddress(widget.address),
    ).then((v) {
      if (v != null) {
        _formKey.currentState!.validate();
        from == 'address'
            ? setState(() {
                addressShowController.text = v['showAddress'];
                widget.setindexProvince!(v['indexProvince']);
                widget.setindexDistric!(v['indexDistrict']);
                widget.setindexSubDistric!(v['indexSubDistrict']);
                widget.setAddressSearch!(v['showAddress']);
              })
            : setState(() {
                workAddressShowController.text = v['showAddress'];
                widget.setWorkAddressSearch!(v['showAddress']);
              });
      }
    });
  }

  Widget personInformation(double screenWidth) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('idcard'.tr(), style: const TextStyle(fontSize: 24)),
            Text('${"Scan_result".tr()} $ocrResultStatus', style: const TextStyle(fontSize: 18))
          ]),
          Text('about_profile'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Expanded(
                child: TextFormField(
                    controller: firstNameController,
                    style: const TextStyle(fontSize: 15),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) {
                        return 'please_enter'.tr();
                      }
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'name'.tr()))),
            const SizedBox(width: 20),
            Expanded(
                child: TextFormField(
                    controller: lastNameController,
                    style: const TextStyle(fontSize: 15),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) {
                        return 'please_enter'.tr();
                      }
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'last_name'.tr())))
          ]),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Expanded(
                child: TextFormField(
                    controller: firstnameEngController,
                    style: const TextStyle(fontSize: 15),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) {
                        return 'please_enter'.tr();
                      }
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'eng_name'.tr()))),
            const SizedBox(width: 20),
            Expanded(
                child: TextFormField(
                    controller: lastnameEngController,
                    style: const TextStyle(fontSize: 15),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) {
                        return 'please_enter'.tr();
                      }
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'eng_lastname'.tr())))
          ]),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: addressShowController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "district_address".tr(),
                    hintText: "district_address".tr(),
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.black54,
                    ),
                  ),
                  validator: (v) {
                    if (v!.isEmpty && checkValidate) {
                      return 'please_enter'.tr();
                    }
                    return null;
                  },
                  onChanged: (v) => _formKey.currentState!.validate(),
                  onTap: () => showModalSearchAddress('address'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: addressController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'address'.tr(), hintText: 'house_number_floor_village_road'.tr()),
              ),
            )
          ]),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Expanded(
                child: TextFormField(
                    controller: birthdayController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: const TextStyle(fontSize: 15),
                    validator: (v) {
                      if (v!.isEmpty && checkValidate) return 'please_enter'.tr();
                      return null;
                    },
                    onChanged: (v) => _formKey.currentState!.validate(),
                    decoration: InputDecoration(
                        fillColor: Colors.white, labelText: 'birthday'.tr(), suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54)))),
            const SizedBox(width: 20),
            Expanded(
              child: TextFormField(
                controller: idCardController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) return 'please_enter'.tr();
                  if (v.length != 17 && checkValidate) return "Please_enter_13_digit".tr();
                  return null;
                },
                onChanged: (v) {
                  _formKey.currentState!.validate();
                },
                keyboardType: TextInputType.number,
                maxLength: 17,
                inputFormatters: [
                  MaskTextInputFormatter(
                    initialText: idCardController.text,
                    mask: '#-####-#####-##-#',
                    filter: {"#": RegExp(r'[0-9]')},
                  ),
                  LengthLimitingTextInputFormatter(17)
                ],
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  labelText: 'id_card_code'.tr(),
                ),
              ),
            )
          ]),
          Container(
            padding: const EdgeInsets.only(top: 10),
            width: screenWidth,
            margin: EdgeInsets.only(left: screenWidth * 0.475),
            child: TextFormField(
              controller: laserCodeController,
              style: const TextStyle(fontSize: 15),
              validator: (v) {
                if (v!.isEmpty && checkValidate) return 'please_enter'.tr();
                return null;
              },
              onChanged: (v) => _formKey.currentState!.validate(),
              maxLength: 14,
              inputFormatters: [
                MaskTextInputFormatter(
                  initialText: laserCodeController.text,
                  mask: '###-#######-##',
                  filter: {"#": RegExp(r'[a-zA-Z0-9]')},
                )
              ],
              decoration: InputDecoration(fillColor: Colors.white, labelText: "id_card_laserNo".tr()),
              textCapitalization: TextCapitalization.characters,
            ),
          )
        ]));
  }

  Widget idCardCapturing({double? screenWidth, double? screenheight}) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("confirm_identity_image".tr(), style: const TextStyle(fontSize: 17)),
        Text("confirm_identity_image_description".tr(), style: const TextStyle(fontSize: 13, color: Color(0xff797979))),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image(
                image: AssetImage(frontIDCardImage.isEmpty ? unCheckImage : checkImage, package: 'gbkyc'),
                width: 24,
              ),
              Text("idcard_front".tr(), style: const TextStyle(color: Color(0xff555555))),
              Text("${"photolight".tr()}/${"photoandIDcard_info".tr()}", style: const TextStyle(fontSize: 12, color: Color(0xff555555)))
            ]),
          ),
          const SizedBox(width: 15),
          DottedBorder(
            dashPattern: const [6, 3, 6, 3],
            padding: const EdgeInsets.all(6),
            color: const Color(0xffc4c4c4),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraScanIDCard(titleAppbar: 'Front_ID_Card'.tr(), enableButton: true, isFront: true, noFrame: false)),
                  ).then((v) async {
                    if (v != null) {
                      int fileSize = await getFileSize(filepath: v);
                      if (frontIDCardImage.isNotEmpty) {
                        await File(frontIDCardImage).delete();
                      }
                      if (!isImage(v)) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "Extension_not_correct".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else if (fileSize > 10000000) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "File_size_larger".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else {
                        setState(() => frontIDCardImage = v);
                      }
                    }
                  });
                },
                child: SizedBox(
                  height: 102,
                  width: 143,
                  child: frontIDCardImage.isEmpty
                      ? Image.asset(cameraImage, scale: 3, package: 'gbkyc')
                      : Image.file(File(frontIDCardImage), width: 143, fit: BoxFit.cover),
                ),
              ),
            ),
          )
        ]),
        Divider(height: 30, thickness: 2, color: Colors.grey[100]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image(image: AssetImage(backIDCardImage.isEmpty ? unCheckImage : checkImage, package: 'gbkyc'), width: 24),
              Text("idcard_back".tr(), style: const TextStyle(color: Color(0xff555555))),
              Text("${"photolight".tr()}/${"photoandIDcard_info".tr()}", style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
            ]),
          ),
          const SizedBox(width: 15),
          DottedBorder(
            dashPattern: const [6, 3, 6, 3],
            padding: const EdgeInsets.all(6),
            color: const Color(0xffc4c4c4),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScanIDCard(titleAppbar: 'Back_ID_Card'.tr(), enableButton: true, isFront: false, noFrame: false),
                    ),
                  ).then((v) async {
                    if (v != null) {
                      int fileSize = await getFileSize(filepath: v);
                      if (backIDCardImage.isNotEmpty) {
                        await File(backIDCardImage).delete();
                      }
                      if (!isImage(v)) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "Extension_not_correct".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else if (fileSize > 10000000) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "File_size_larger".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else {
                        setState(() => backIDCardImage = v);
                      }
                    }
                  });
                },
                child: SizedBox(
                    height: 102,
                    width: 143,
                    child: backIDCardImage.isEmpty
                        ? Image.asset(cameraImage, scale: 3, package: 'gbkyc')
                        : Image.file(File(backIDCardImage), width: 143, fit: BoxFit.cover)),
              ),
            ),
          )
        ]),
        Divider(height: 30, thickness: 2, color: Colors.grey[100]),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image(image: AssetImage(selfieIDCard.isEmpty ? unCheckImage : checkImage, package: 'gbkyc'), width: 24),
              Text("idcard_selfie".tr(), style: const TextStyle(color: Color(0xff555555))),
              Text("${"photolight".tr()}/${"photoandIDcard_info".tr()}", style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
            ]),
          ),
          const SizedBox(width: 15),
          DottedBorder(
            dashPattern: const [6, 3, 6, 3],
            padding: const EdgeInsets.all(6),
            color: const Color(0xffc4c4c4),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScanIDCard(titleAppbar: 'Selfie_ID_Card'.tr(), enableButton: true, isFront: true, noFrame: true),
                    ),
                  ).then((v) async {
                    if (v != null) {
                      int fileSize = await getFileSize(filepath: v);
                      if (selfieIDCard.isNotEmpty) {
                        await File(selfieIDCard).delete();
                      }
                      if (!isImage(v)) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "Extension_not_correct".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else if (fileSize > 10000000) {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (context) {
                            return CustomDialog(
                                title: "File_size_larger".tr(), textConfirm: "ok".tr(), onPressedConfirm: () => Navigator.pop(context));
                          },
                        );
                      } else {
                        setState(() => selfieIDCard = v);
                      }
                    }
                  });
                },
                child: SizedBox(
                  height: 102,
                  width: 143,
                  child: selfieIDCard.isEmpty
                      ? Image.asset(cameraImage, scale: 3, package: 'gbkyc')
                      : Image.file(File(selfieIDCard), width: 143, fit: BoxFit.cover),
                ),
              ),
            ),
          )
        ])
      ]),
    );
  }

  Widget workInformation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("titlecareer".tr(), style: const TextStyle(fontSize: 16)),
        dropdownCareer(),
        if (careerId != null) dropdownCareerChild(),
        if (indexCareer != null) workLable(),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => setState(() {
            isChecked = !isChecked;
          }),
          child: Row(
            children: [
              Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = !isChecked;
                    });
                  }),
              Text('confirm_information_correct'.tr()),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(
            child: ButtonConfirm(
              text: 'continue'.tr(),
              enable: isChecked,
              onPressed: () async {
                FocusScope.of(context).unfocus();
                checkValidate = true;

                if (careerId == null) {
                  setState(() => validateCareer = true);
                }

                if ((indexCareer == 19 || indexCareer == 20) && careerChildId == null) {
                  setState(() => validateCareerChild = true);
                }

                if (_formKey.currentState!.validate()) {
                  if (widget.ocrAllFailed && (frontIDCardImage.isEmpty || backIDCardImage.isEmpty || selfieIDCard.isEmpty)) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "confirm_identity_image".tr(),
                          content: "confirm_identity_image_description".tr(),
                          avatar: false,
                        );
                      },
                    );
                  } else if (careerId == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "career".tr(),
                          content: "career_request".tr(),
                          avatar: false,
                        );
                      },
                    );
                  } else if ((indexCareer == 19 || indexCareer == 20) && careerChildId == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialog(
                          title: "career_more".tr(),
                          content: "career_request".tr(),
                          avatar: false,
                        );
                      },
                    );
                  } else {
                    if (await _callVerifyDopa()) {
                      final res = await PostAPI.call(
                          url: '$register3003/users/pre_verify',
                          headers: Authorization.auth2,
                          body: {"id_card": idCardController.text.replaceAll('-', '')},
                          context: context);

                      if (res['success']) {
                        if (careerChildId != null) {
                          careerId = careerChildId;
                          widget.setCareerID!(careerId);
                        }
                        if (frontIDCardImage.isNotEmpty) {
                          widget.setFileFrontCitizen!(frontIDCardImage);
                        }
                        if (backIDCardImage.isNotEmpty) {
                          widget.setFileBackCitizen!(backIDCardImage);
                        }
                        if (selfieIDCard.isNotEmpty) {
                          widget.setFileSelfie!(selfieIDCard);
                        }

                        widget.setFirstName!(firstNameController.text);
                        widget.setLastName!(lastNameController.text);
                        widget.setFirstNameEng!(firstnameEngController.text);
                        widget.setLastNameEng!(lastnameEngController.text);
                        widget.setAddress!(addressController.text);
                        widget.setBirthday!(birthdayController.text);
                        widget.setIDCard!(idCardController.text.replaceAll('-', ''));
                        widget.setLaserCode!(laserCodeController.text.replaceAll('-', ''));
                        widget.setPinVisible!(true);
                        widget.setSelectedStep!(3);
                        widget.setDataVisible!(false);
                      }
                    }
                  }
                }
              },
            ),
          )
        ])
      ]),
    );
  }

  Future<bool> _callVerifyDopa() async {
    var verifyDOPA = await PostAPI.call(
        url: '$register3003/users/verify_dopa',
        headers: Authorization.auth2,
        body: {
          "id_card": idCardController.text.replaceAll('-', ''),
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "birthday": birthdayController.text,
          "laser": laserCodeController.text.replaceAll('-', ''),
        },
        context: context);

    return verifyDOPA['success'];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return ListView(physics: const ClampingScrollPhysics(), padding: const EdgeInsets.only(top: 5, bottom: 30), children: [
      Form(
          key: _formKey,
          child: Column(children: [
            personInformation(screenWidth),
            widget.ocrAllFailed ? Container(height: 20, width: double.infinity, color: Colors.grey[100]) : Container(),
            widget.ocrAllFailed ? idCardCapturing(screenWidth: screenWidth, screenheight: screenheight) : Container(),
            Container(height: 20, width: double.infinity, color: Colors.grey[100]),
            workInformation(),
          ]))
    ]);
  }
}
