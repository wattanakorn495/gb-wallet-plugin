import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
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
import 'package:gbkyc/utils/error_messages.dart';
import 'package:gbkyc/utils/file_uitility.dart';
import 'package:gbkyc/widgets/button_confirm.dart';
import 'package:gbkyc/widgets/custom_dialog.dart';
import 'package:gbkyc/widgets/select_address.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PersonalInfo extends StatefulWidget {
  final bool isCitizen;
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
  final Function? setCareerChildID;
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
  //passport
  final Function? setCountryCode;
  final Function? setPassportNumber;
  final Function? setExpirePassport;

  const PersonalInfo({
    required this.isCitizen,
    this.ocrAllFailed,
    this.person,
    this.setPinVisible,
    this.setSelectedStep,
    this.setCareerID,
    this.setCareerChildID,
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
    //passport
    this.setCountryCode,
    this.setPassportNumber,
    this.setExpirePassport,
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
  final checkImage = "assets/images/Check.png";
  final unCheckImage = "assets/images/uncheck.png";
  final cameraImage = "assets/icons/camera.png";
  String? workName, workAddress, workAdressSearch;
  DateTime? birthDatePick, expireDatePick;
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
  bool dopaValidate = false;

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
  final careerController = TextEditingController();
  final careerChildController = TextEditingController();
  final workNameController = TextEditingController();
  final workAddressController = TextEditingController();
  final workAddressShowController = TextEditingController();
  //passport
  final countryController = TextEditingController();
  final passportController = TextEditingController();
  final expirePassportController = TextEditingController();

  MaskTextInputFormatter laserCodeFormatter = MaskTextInputFormatter(
    mask: '###-#######-##',
    filter: {"#": RegExp(r'[a-zA-Z0-9]')},
  );

  MaskTextInputFormatter idCardFormatter = MaskTextInputFormatter(
    mask: '#-####-#####-##-#',
    filter: {"#": RegExp(r'[0-9]')},
  );

  List<int> careerIdSkipList = [1, 3, 5, 13, 14, 15, 16, 17];
  dynamic dataCareer;
  dynamic dataCareerChild;

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
    careerController.clear();
    careerChildController.clear();
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

  onLoad() {
    print('in on load');
    expireDatePick = DateTime.now();
    birthDatePick = DateTime(expireDatePick!.year - 20, expireDatePick!.month, expireDatePick!.day);

    if (widget.isCitizen) {
      if (StateStore.careers['success']) {
        dataCareer = StateStore.careers['response']['data']['careers'];
      }
      if (StateStore.careerChild.isNotEmpty && StateStore.careerChild['success']) {
        dataCareerChild = StateStore.careerChild['response']['data']['careers'];
      }
      idCardController.text = idCardFormatter.maskText(widget.person!.idCard ?? "");
      firstNameController.text = widget.person!.firstName ?? "";
      lastNameController.text = widget.person!.lastName ?? "";
      firstnameEngController.text = widget.person!.firstNameEng ?? "".toUpperCase();
      lastnameEngController.text = widget.person!.lastNameEng ?? "".toUpperCase();
      addressController.text = widget.person!.address ?? "";
      birthdayController.text = widget.person!.birthday ?? DateFormat('dd/MM/yyyy').format(birthDatePick!);
      if (birthdayController.text.isNotEmpty) {
        try {
          birthDatePick = DateFormat('dd/MM/yyyy').parse(birthdayController.text);
        } catch (e) {
          birthdayController.text = DateFormat('dd/MM/yyyy').format(birthDatePick!);
        }
      }
      laserCodeController.text = laserCodeFormatter.maskText(widget.person!.ocrBackLaser ?? "");
      ocrResultStatus = widget.ocrAllFailed ? "Failed" : "Passed";
      careerId = widget.person!.careerID;
      if (careerId != null && (dataCareer as List).map((e) => e['id']).contains(careerId)) {
        indexCareer = (dataCareer as List).indexWhere((item) => item['id'] == careerId);
        careerController.text = '${dataCareer[indexCareer]['name_${'language'.tr()}']}';
        careerId = dataCareer[indexCareer]['id'];
        skipInfomation = dataCareer[indexCareer]['skip_infomation'];
        if (widget.person!.careerChildID != null && dataCareerChild != null) {
          careerChildId = widget.person!.careerChildID;
          indexCareerChild = dataCareerChild.indexWhere((item) => item['id'] == careerChildId);
          careerChildController.text = '${dataCareerChild[indexCareerChild]['name_${'language'.tr()}']}';
        }
      }
      workNameController.text = widget.person!.workName ?? "";
      workAddressController.text = widget.person!.workAddress ?? "";
      workAddressShowController.text = widget.person!.workAddressSearch ?? "";
    } else {
      if (StateStore.careers['success']) {
        dataCareer = StateStore.careers['response']['data']['careers'];
      }
      if (StateStore.careerChild.isNotEmpty && StateStore.careerChild['success']) {
        dataCareerChild = StateStore.careerChild['response']['data']['careers'];
      }
      countryController.text = widget.person!.countryCodeName ?? "";
      passportController.text = widget.person!.passportNumber ?? "";
      firstNameController.text = widget.person!.firstName ?? "";
      lastNameController.text = widget.person!.lastName ?? "";
      birthdayController.text = widget.person!.birthday ?? DateFormat('dd/MM/yyyy').format(birthDatePick!);
      if (birthdayController.text.isNotEmpty) {
        try {
          birthDatePick = DateFormat('dd/MM/yyyy').parse(birthdayController.text);
        } catch (e) {
          birthdayController.text = DateFormat('dd/MM/yyyy').format(birthDatePick!);
        }
      }
      expirePassportController.text = widget.person!.expirePassport ?? DateFormat('dd/MM/yyyy').format(expireDatePick!);
      if (expirePassportController.text.isNotEmpty) {
        try {
          expireDatePick = DateFormat('dd/MM/yyyy').parse(expirePassportController.text);
        } catch (e) {
          expirePassportController.text = DateFormat('dd/MM/yyyy').format(expireDatePick!);
        }
      }
      ocrResultStatus = widget.ocrAllFailed ? "Failed" : "Passed";
      careerId = widget.person!.careerID;
      if (careerId != null && (dataCareer as List).map((e) => e['id']).contains(careerId)) {
        indexCareer = (dataCareer as List).indexWhere((item) => item['id'] == careerId);
        careerController.text = '${dataCareer[indexCareer]['name_${'language'.tr()}']}';
        careerId = dataCareer[indexCareer]['id'];
        skipInfomation = dataCareer[indexCareer]['skip_infomation'];
        if (widget.person!.careerChildID != null && dataCareerChild != null) {
          careerChildId = widget.person!.careerChildID;
          indexCareerChild = dataCareerChild.indexWhere((item) => item['id'] == careerChildId);
          careerChildController.text = '${dataCareerChild[indexCareerChild]['name_${'language'.tr()}']}';
        }
      }
      workNameController.text = widget.person!.workName ?? "";
      workAddressController.text = widget.person!.workAddress ?? "";
      workAddressShowController.text = widget.person!.workAddressSearch ?? "";
    }
  }

  _selectDate(BuildContext context, bool isBirthday) async {
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
              if (isBirthday) {
                birthdayController.text = DateFormat('dd/MM/yyyy').format(birthDatePick!);
              } else {
                expirePassportController.text = DateFormat('dd/MM/yyyy').format(expireDatePick!);
              }
              _formKey.currentState!.validate();
              Navigator.pop(popupContext);
            },
          ),
          SizedBox(
            height: 220,
            child: CupertinoDatePicker(
              initialDateTime: isBirthday ? birthDatePick : expireDatePick,
              mode: CupertinoDatePickerMode.date,
              minimumYear: isBirthday ? 1900 : DateTime.now().year - 10,
              maximumYear: isBirthday ? DateTime.now().year : DateTime.now().year + 10,
              onDateTimeChanged: (v) {
                if (isBirthday) {
                  birthDatePick = v;
                } else {
                  expireDatePick = v;
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget workLable() {
    return (!skipInfomation && !careerIdSkipList.contains(careerId))
        ? Column(children: [
            const SizedBox(height: 20),
            TextFormField(
              controller: workNameController,
              style: const TextStyle(fontSize: 15),
              onChanged: (v) {
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
                    onTap: () => showModalSearchAddress('workAddress'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: workAddressController,
              style: const TextStyle(fontSize: 15),
              onChanged: (v) {
                widget.setWorkAddress!(v);
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'addresscareer'.tr(), hintText: 'house_number_floor_village_road'.tr()),
            ),
          ])
        : const SizedBox();
  }

  Widget dropdownCareer() {
    if (dataCareer != null) {
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
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextFormField(
              readOnly: true,
              controller: careerController,
              style: const TextStyle(fontSize: 15),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: "career".tr(), suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54)),
              onTap: () {
                showBottomDialog(data, indexCareer, "career".tr(), (v) async {
                  if (v != null && v['selectedIndex'] != null) {
                    final int index = v['selectedIndex'];
                    final String selectItem = '${dataCareer[index - 1]['name_${'language'.tr()}']}';

                    if (indexCareer != null) widget.setCareerID!(index);
                    careerId = dataCareer[index - 1]['id'];
                    careerChildId = null;
                    careerController.text = selectItem;
                    await clearAndLoadCareerChild(careerId ?? 0);
                    setState(() {
                      validateCareer = false;
                      validateCareerChild = true;
                      indexCareer = index - 1;
                      indexCareerChild = null;
                      skipInfomation = dataCareer[index - 1]['skip_infomation'];
                      careerChildId = null;
                      widget.setCareerID!(careerId);
                    });
                  }
                });
              },
            ),
          )
        ],
      );
    }
    return const SizedBox();
  }

  clearAndLoadCareerChild(int mainCareerId) async {
    careerChildController.clear();
    indexCareerChild = null;
    workNameController.clear();
    workAddressShowController.clear();
    workAddressController.clear();
    StateStore.careerChild = await GetAPI.call(url: '$register3003/careers/$careerId/child', headers: Authorization.auth2, context: context);
    if (StateStore.careerChild['success']) {
      dataCareerChild = StateStore.careerChild['response']['data']['careers'];
    }
  }

  Widget dropdownCareerChild() {
    if (dataCareerChild != null && (dataCareerChild as List).isNotEmpty) {
      final data = dataCareerChild.map<DropdownMenuItem<int>>((item) {
        int index = dataCareerChild.indexOf(item);
        return DropdownMenuItem(
          value: index + 1,
          child: SizedBox(
            width: 300,
            child: Text(
              '${dataCareerChild[index]['name_${'language'.tr()}']}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList();
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: TextFormField(
                readOnly: true,
                controller: careerChildController,
                style: const TextStyle(fontSize: 15),
                textInputAction: TextInputAction.next,
                decoration:
                    InputDecoration(labelText: 'career_more'.tr(), suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54)),
                onTap: () {
                  showBottomDialog(data, indexCareerChild, '- ${'career_more'.tr()} -', (v) {
                    if (v != null && v['selectedIndex'] != null) {
                      final int index = v['selectedIndex'];
                      final String selectItem = '${dataCareerChild[index - 1]['name_${'language'.tr()}']}';
                      careerChildController.text = selectItem;
                      setState(() {
                        validateCareerChild = false;
                        indexCareerChild = index - 1;
                        skipInfomation = dataCareerChild[index - 1]['skip_infomation'];
                        careerChildId = dataCareerChild[index - 1]['id'];
                      });
                    }
                  });
                },
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox();
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
    return Padding(padding: const EdgeInsets.all(20), child: widget.isCitizen ? citizenInformation(screenWidth) : passportInformation(screenWidth));
  }

  citizenInformation(double screenWidth) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('idcard'.tr(), style: const TextStyle(fontSize: 24)),
        Text('${"Scan_result".tr()} $ocrResultStatus', style: const TextStyle(fontSize: 18))
      ]),
      Text('about_profile'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Expanded(
            child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[ก-ฮ]'))],
                controller: firstNameController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'name'.tr()))),
        const SizedBox(width: 20),
        Expanded(
            child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[ก-ฮ]'))],
                controller: lastNameController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
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
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                inputFormatters: [UpperCaseTextFormatter(), FilteringTextInputFormatter.allow(RegExp('[a-z A-Z]'))],
                decoration: InputDecoration(labelText: 'eng_name'.tr()))),
        const SizedBox(width: 20),
        Expanded(
            child: TextFormField(
                controller: lastnameEngController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                inputFormatters: [UpperCaseTextFormatter(), FilteringTextInputFormatter.allow(RegExp('[a-z A-Z]'))],
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
                onTap: () => _selectDate(context, true),
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
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
              if (v!.isEmpty && checkValidate) {
                return 'please_enter'.tr();
              } else if (v.length != 17 && checkValidate) {
                return "Please_enter_13_digit".tr();
              } else if (dopaValidate && checkValidate) {
                return 'please_check_data'.tr();
              }
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
            if (v!.isEmpty && checkValidate) {
              return 'please_enter'.tr();
            } else if (dopaValidate && checkValidate) {
              return 'please_check_data'.tr();
            }
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
    ]);
  }

  passportInformation(double screenWidth) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('passport_scan'.tr(), style: const TextStyle(fontSize: 24)),
      const SizedBox(
        height: 16,
      ),
      Text('about_profile'.tr(), style: const TextStyle(color: Colors.black54, fontSize: 16)),
      const SizedBox(height: 20),
      Text('personal_information'.tr(), style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Expanded(
            child: TextFormField(
                controller: countryController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'country'.tr()))),
        const SizedBox(width: 20),
        Expanded(
            child: TextFormField(
                controller: passportController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: 'passport'.tr())))
      ]),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Expanded(
            child: TextFormField(
                controller: firstNameController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: InputDecoration(labelText: 'name'.tr()))),
        const SizedBox(width: 20),
        Expanded(
            child: TextFormField(
                controller: lastNameController,
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                textInputAction: TextInputAction.next,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: InputDecoration(labelText: 'last_name'.tr())))
      ]),
      const SizedBox(height: 20),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
            child: TextFormField(
                controller: birthdayController,
                readOnly: true,
                onTap: () => _selectDate(context, true),
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                decoration: InputDecoration(
                    fillColor: Colors.white, labelText: 'birthday'.tr(), suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54)))),
        const SizedBox(width: 20),
        Expanded(
            child: TextFormField(
                controller: expirePassportController,
                readOnly: true,
                onTap: () => _selectDate(context, false),
                style: const TextStyle(fontSize: 15),
                validator: (v) {
                  if (v!.isEmpty && checkValidate) {
                    return 'please_enter'.tr();
                  } else if (dopaValidate && checkValidate) {
                    return 'please_check_data'.tr();
                  }
                  return null;
                },
                onChanged: (v) => _formKey.currentState!.validate(),
                decoration: InputDecoration(
                    fillColor: Colors.white, labelText: 'Expiration_date'.tr(), suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54))))
      ]),
    ]);
  }

  Widget idCapturing({
    double? screenWidth,
  }) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(20),
      child: widget.isCitizen ? idCardCapture() : passportCapture(),
    );
  }

  Widget idCardCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget passportCapture() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("confirm_identity_image".tr(), style: const TextStyle(fontSize: 17)),
        Text("confirm_identity_image_description_passport".tr(), style: const TextStyle(fontSize: 13, color: Color(0xff797979))),
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image(
                image: AssetImage(frontIDCardImage.isEmpty ? unCheckImage : checkImage, package: 'gbkyc'),
                width: 24,
              ),
              const SizedBox(
                height: 8,
              ),
              Text("passport_data".tr(), style: const TextStyle(color: Color(0xff555555))),
              Text("${"photolight".tr()}/${"photo_passport_info".tr()}", style: const TextStyle(fontSize: 12, color: Color(0xff555555)))
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
                        builder: (context) =>
                            CameraScanIDCard(titleAppbar: 'front_passport'.tr(), enableButton: true, isFront: false, noFrame: true)),
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
              Image(image: AssetImage(selfieIDCard.isEmpty ? unCheckImage : checkImage, package: 'gbkyc'), width: 24),
              const SizedBox(
                height: 8,
              ),
              Text("passport_selfie".tr(), style: const TextStyle(color: Color(0xff555555))),
              Text("${"photolight".tr()}/${"photo_passport_info".tr()}", style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
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
                      builder: (context) =>
                          CameraScanIDCard(titleAppbar: 'passport_take_selfie'.tr(), enableButton: true, isFront: true, noFrame: true),
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
      ],
    );
  }

  Widget workInformation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        dropdownCareer(),
        dropdownCareerChild(),
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
                if (_formKey.currentState!.validate() || dopaValidate) {
                  bool ocrPassed = true;
                  if (widget.ocrAllFailed) {
                    if (widget.isCitizen && (frontIDCardImage.isEmpty || backIDCardImage.isEmpty || selfieIDCard.isEmpty)) {
                      ocrPassed = false;
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
                      ocrPassed = false;
                    } else if (!widget.isCitizen && (frontIDCardImage.isEmpty || selfieIDCard.isEmpty)) {
                      ocrPassed = false;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: "confirm_identity_image".tr(),
                            content: "confirm_identity_image_description_passport".tr(),
                            avatar: false,
                          );
                        },
                      );
                    }
                  }
                  if (careerId == null && ocrPassed) {
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
                  } else if (ocrPassed) {
                    if (await _callVerifyDopa()) {
                      if (widget.isCitizen) {
                        final res = await PostAPI.call(
                            url: '$register3003/users/pre_verify',
                            headers: Authorization.auth2,
                            body: {"id_card": idCardController.text.replaceAll('-', '')},
                            context: context,
                            alert: false);
                        if (res['success']) {
                          if (careerChildId != null) {
                            widget.setCareerChildID!(careerChildId);
                          } else {
                            widget.setCareerChildID!(null);
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
                          widget.setFirstNameEng!(firstnameEngController.text.toUpperCase());
                          widget.setLastNameEng!(lastnameEngController.text.toUpperCase());
                          widget.setAddress!(addressController.text);
                          widget.setBirthday!(birthdayController.text);
                          widget.setIDCard!(idCardController.text.replaceAll('-', ''));
                          widget.setLaserCode!(laserCodeController.text.replaceAll('-', ''));
                          widget.setPinVisible!(true);
                          widget.setSelectedStep!(3);
                          widget.setDataVisible!(false);
                        } else if (res['response'] != null) {
                          await showDialog(
                              context: context,
                              builder: (builder) => CustomDialog(title: 'unable_register'.tr(), content: errorMessages(res), avatar: false));
                        } else {
                          await showDialog(
                              context: context,
                              builder: (builder) => CustomDialog(title: 'Something_went_wrong'.tr(), content: errorMessages(res), avatar: false));
                        }
                      } else {
                        if (careerChildId != null) {
                          widget.setCareerChildID!(careerChildId);
                        } else {
                          widget.setCareerChildID!(null);
                        }
                        if (frontIDCardImage.isNotEmpty) {
                          widget.setFileFrontCitizen!(frontIDCardImage);
                        }
                        if (selfieIDCard.isNotEmpty) {
                          widget.setFileSelfie!(selfieIDCard);
                        }
                        widget.setCountryCode!(countryController.text);
                        widget.setPassportNumber!(passportController.text);
                        widget.setFirstName!(firstNameController.text);
                        widget.setLastName!(lastNameController.text);
                        widget.setBirthday!(birthdayController.text);
                        widget.setExpirePassport!(expirePassportController.text);
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
    dopaValidate = false;
    if (widget.isCitizen) {
      var verifyDOPA = await PostAPI.call(
          url: 'https://api.gbwallet.co/register-api/users/verify_dopa', //TODO GB PRD
          headers: Authorization.auth2,
          body: {
            "id_card": idCardController.text.replaceAll('-', ''),
            "first_name": firstNameController.text,
            "last_name": lastNameController.text,
            "birthday": birthdayController.text,
            "laser": laserCodeController.text.replaceAll('-', ''),
          },
          context: context,
          alert: false);
      if (!verifyDOPA['success'] && verifyDOPA['response'] != null) {
        await showDialog(
            context: context, builder: (builder) => CustomDialog(title: 'invalid_id_card'.tr(), content: errorMessages(verifyDOPA), avatar: false));
      } else if (!verifyDOPA['success'] && verifyDOPA['response'] == null) {
        await showDialog(
            context: context,
            builder: (builder) => CustomDialog(title: 'Something_went_wrong'.tr(), content: errorMessages(verifyDOPA), avatar: false));
      }
      if ((verifyDOPA['response']['error_message']).toString().toLowerCase().contains('invalid_id_card_information'.tr())) {
        dopaValidate = true;
        _formKey.currentState!.validate();
      }
      return verifyDOPA['success'];
    } else {
      var verifyDOPA = await PostAPI.call(
        url: 'https://api-uat-villa.gbwallet.co/register-api/users/verify_amlo',
        headers: Authorization.authPassport,
        body: {
          "passportNo": passportController.text,
          "firstNameEng": firstNameController.text,
          "lastNameEng": lastNameController.text,
        },
        context: context,
      );
      if ((verifyDOPA['response']['error_message']).toString().toLowerCase().contains('invalid_id_card_information'.tr())) {
        dopaValidate = true;
        _formKey.currentState!.validate();
      }
      return verifyDOPA['success'];
    }
  }

  showBottomDialog(List<DropdownMenuItem> dataListDropdown, int? selectedIndex, String title, Function callback) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        width: double.infinity,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: dataListDropdown.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    title: dataListDropdown[index].child,
                    selected: index == selectedIndex,
                    trailing: index == selectedIndex
                        ? const Image(image: AssetImage('assets/images/Check.png', package: 'gbkyc'), width: 25, height: 25)
                        : const SizedBox(),
                    onTap: () {
                      selectedIndex = dataListDropdown[index].value;
                      Navigator.pop(context, {
                        "selectedIndex": selectedIndex,
                      });
                    });
              },
            ),
          ),
        ]),
      ),
    ).then((value) => callback(value));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView(physics: const ClampingScrollPhysics(), padding: const EdgeInsets.only(top: 5, bottom: 30), children: [
      Form(
          key: _formKey,
          child: Column(children: [
            personInformation(screenWidth),
            widget.ocrAllFailed ? Container(height: 20, width: double.infinity, color: Colors.grey[100]) : Container(),
            widget.ocrAllFailed
                ? idCapturing(
                    screenWidth: screenWidth,
                  )
                : Container(),
            Container(height: 20, width: double.infinity, color: Colors.grey[100]),
            workInformation(),
          ]))
    ]);
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
