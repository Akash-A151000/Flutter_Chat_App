import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction{
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";


  //saving the data to sf

  static Future<bool?> saveUserLoggedInStatus(bool isUserLoggedIn)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool result = await sf.setBool(userLoggedInKey, isUserLoggedIn);
    print(userLoggedInKey);
    print(isUserLoggedIn);
    return result;
  }

    static Future<bool?> saveUserNameSF(String userName)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool result =  await sf.setString(userNameKey, userName);
    print(userNameKey);
    print(userName);
    return result;
  }

    static Future<bool?> saveUserEmailSF(String userEmail)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    bool result= await sf.setString(userEmailKey, userEmail);
    print(userEmailKey);
    print(userEmail);
    return result;
  }


  //getting the data from sf

  static Future<bool?> getUserLoggedInstatus()async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF()async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

   static Future<String?> getUserNameFromSF()async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }
}