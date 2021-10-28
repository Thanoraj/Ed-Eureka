import 'package:shared_preferences/shared_preferences.dart';

class LocalUserData {
  static String localUserLoggedInKey = 'IsLoggedIn';
  static String localUserNameKey = 'UserNameKey';
  static String localUserEmailKey = 'UserEmailKey';
  static String localChatList = 'UserChatList';
  static String localImageNameKey = 'LastImageName';
  static String localUserInfo = 'userInfoKey';
  static String localTheme = 'userThemeKey';
  static String versionInfoKey = 'versionInfoKey';
  static String textColorKey = 'textColorKey';
  static String bookList = 'bookListKey';
  static String photoURLKey = 'photoURLKey';
  static String recommendedLectureKey = 'recommendedKey';
  static String revisionLectureKey = 'revisionKey';
  static String recommendedSubjectsKey = 'recommendedSubjectsKey';
  static String revisionSubjectsKey = 'revisionSubjectsKey';
  static String zoomLectureKey = 'zoomLectureKey';
  static String examListKey = 'examKey';
  static String subjectListKey = 'subjectsKey';
  static String subscriptionListKey = 'subscriptionKey';
  static String attemptsKey = 'attemptsKey';
  static String permissionKey = 'permissionKey';

  static Future<void> saveLoggedInKey(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(localUserLoggedInKey, isUserLoggedIn);
  }

  static Future<void> saveUserNameKey(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(localUserNameKey, userName);
  }

  static Future<void> saveUserUidKey(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(localUserEmailKey, email);
  }

  static Future<void> saveUserInfo(String userInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(localUserInfo, userInfo);
  }

  static Future<void> saveVersionInfo(String version) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(versionInfoKey, version);
  }

  static Future<void> saveTextColor(String textColor) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(textColorKey, textColor);
  }

  static Future<void> saveLastBook(String subject, String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(subject, bookName);
  }

  static Future<void> saveBookList(
      String subscription, List<String> bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(subscription, bookName);
  }

  static Future<void> savePhotoURL(String photoURL) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(photoURLKey, photoURL);
  }

  static Future<void> saveRecommendedLectures(List<String> bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(recommendedLectureKey, bookName);
  }

  static Future<void> saveRevisionLectures(List<String> bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(revisionLectureKey, bookName);
  }

  static Future<void> saveRecommendedSubjects(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(recommendedSubjectsKey, bookName);
  }

  static Future<void> saveRevisionSubjects(String bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(revisionSubjectsKey, bookName);
  }

  static Future<void> saveExams(key, List<String> bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, bookName);
  }

  static Future<void> saveLectures(key, List<String> bookName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, bookName);
  }

  static Future<void> saveSubjects(String list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(subjectListKey, list);
  }

  static Future<void> saveSubscriptions(String list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(subscriptionListKey, list);
  }

  static Future<void> saveLastDate(String key, String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, date);
  }

  static Future<void> saveUpdateInfo(String key, String info) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(key, info);
  }

  static Future<void> saveFlashCard(String key, List imageNameList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList(key, imageNameList);
  }

  static Future<void> saveAttemptTimes(String info) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(attemptsKey, info);
  }

  static Future<void> savePermission(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(permissionKey, status);
  }

  static Future<bool> getUserIdKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(
      localUserLoggedInKey,
    );
  }

  static getUserNameKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      localUserNameKey,
    );
  }

  static getUserEmailKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      localUserEmailKey,
    );
  }

  static getChatList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      localChatList,
    );
  }

  static getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      localUserInfo,
    );
  }

  static setTheme(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(localTheme, theme.toString());
  }

  static getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      localTheme,
    );
  }

  static getVersionInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      versionInfoKey,
    );
  }

  static getTextColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(textColorKey);
  }

  static getLastBook(String subject) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(subject);
  }

  static getBookList(String subscription) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(subscription);
  }

  static getRecommendedLectures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      recommendedLectureKey,
    );
  }

  static getRevisionLectures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      revisionLectureKey,
    );
  }

  static getRecommendedSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      recommendedSubjectsKey,
    );
  }

  static getRevisionSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      revisionSubjectsKey,
    );
  }

  static getExams(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      key,
    );
  }

  static getLectures(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      key,
    );
  }

  static getSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      subjectListKey,
    );
  }

  static getSubscriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      subscriptionListKey,
    );
  }

  static getLastDate(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      key,
    );
  }

  static getUpdateInfo(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
      key,
    );
  }

  static getFlashCardList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(
      key,
    );
  }

  static getAttemptTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(attemptsKey);
  }

  static getPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(permissionKey);
  }
}
