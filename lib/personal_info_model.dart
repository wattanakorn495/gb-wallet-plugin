class PersonalInfoModel {
  PersonalInfoModel({
    this.idCard,
    this.firstName,
    this.lastName,
    this.address,
    this.filterAddress,
    this.birthday,
    this.ocrBackLaser,
    this.careerID,
    this.careerChildID,
    this.workName,
    this.workAddress,
    this.workAddressSearch,
    //passport
    this.passportNumber,
    this.countryCodeName,
    this.expirePassport,
  });
  int? careerID, careerChildID;
  String? idCard,
      firstName,
      lastName,
      firstNameEng,
      lastNameEng,
      address,
      filterAddress,
      birthday,
      ocrBackLaser,
      workName,
      workAddress,
      workAddressSearch,
      //passport
      passportNumber,
      countryCodeName,
      expirePassport;
}
