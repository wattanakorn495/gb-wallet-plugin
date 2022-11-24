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
    //passport
    this.passportNumber,
    this.countryCodeName,
    this.expirePassport,
  });
  int? careerID;
  String? idCard,
      firstName,
      lastName,
      firstNameEng,
      lastNameEng,
      address,
      filterAddress,
      birthday,
      ocrBackLaser,
      //passport
      passportNumber,
      countryCodeName,
      expirePassport;
}
