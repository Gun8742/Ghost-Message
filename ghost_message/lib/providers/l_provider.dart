import 'package:ghost_message/providers/language_provider.dart';

class L {
  final AppLang lang;
  L(this.lang);

  // Bottom Nav
  String get navProfile => lang == AppLang.th ? "โปรไฟล์" : "Profile";
  String get navHome => lang == AppLang.th ? "หน้าแรก" : "Home";
  String get navSetting => lang == AppLang.th ? "ตั้งค่า" : "Setting";

  // Setting Screen
  String get settingTitle => lang == AppLang.th ? "ตั้งค่า" : "Setting";

  String get sectionNotification => lang == AppLang.th ? "การแจ้งเตือน" : "Notification";
  String get settingNotification => lang == AppLang.th ? "แจ้งเตือน" : "Notification";
  String get settingNearbyChat => lang == AppLang.th ? "แจ้งเตือนแชทใกล้ตัว" : "Nearby Chat Notification";

  String get sectionLocation => lang == AppLang.th ? "ตำแหน่ง" : "Location";
  String get settingLocation => lang == AppLang.th ? "ตำแหน่ง" : "Location";
  String get settingChatDistance => lang == AppLang.th ? "ระยะแชท" : "Chat Distance";
  String get low => lang == AppLang.th ? "ใกล้" : "Low";
  String get high => lang == AppLang.th ? "ไกล" : "High";

  String get sectionProfile => lang == AppLang.th ? "บัญชี" : "Profile";
  String get email => lang == AppLang.th ? "อีเมล" : "Email";
  String get password => lang == AppLang.th ? "รหัสผ่าน" : "Password";
  String get edit => lang == AppLang.th ? "แก้ไข" : "Edit";

  String get sectionAppearance => lang == AppLang.th ? "หน้าตาแอป" : "Appearance";
  String get theme => lang == AppLang.th ? "ธีม" : "Theme";
  String get light => lang == AppLang.th ? "สว่าง" : "Light";
  String get dark => lang == AppLang.th ? "มืด" : "Dark";

  String get languages => lang == AppLang.th ? "ภาษา" : "Languages";
  String get thai => "ไทย";
  String get english => "English";

  String get confirm => lang == AppLang.th ? "ยืนยัน" : "Confirm";
  String get cancel => lang == AppLang.th ? "ยกเลิก" : "Cancel";
  String get newEmailHint => lang == AppLang.th ? "อีเมลใหม่" : "new email";
  String get newPassHint => lang == AppLang.th ? "รหัสผ่านใหม่" : "new password";
  String get confirmPassHint => lang == AppLang.th ? "ยืนยันรหัสผ่าน" : "confirm password";

  String get signOutButton => lang == AppLang.th ? "ออกจากระบบ" : "Sign Out";
  String get confirmtoSignOutTitle => lang == AppLang.th ? "ยืนยันที่จะออกจากระบบหรือไม่" : "Are you sure want to SIGN OUT?";

  //Profile Page
  String get profileTitle => lang == AppLang.th ? "โปรไฟล์" : "Profile";
  String get badgeTitle => lang == AppLang.th ? "เหรียญตรา" : "Badge";
  String get achievementTitle => lang == AppLang.th ? "ความสำเร็จ" : "Achievement";
}
