enum Status { INITIAL, LOADING, COMPLETED, ERROR }

enum ServiceStatus { free, booked }

enum ImageType { images, profilepic, documents ,notype}

enum LoginStep {
  loginOptions,
  mobileInput,
  otp,
  changeNumber,
  emailVerification,
  checkMail,
  newPhone,
  verifyNewNumber,
  numberUpdated,
}