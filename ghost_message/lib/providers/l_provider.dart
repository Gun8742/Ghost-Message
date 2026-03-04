import 'package:ghost_message/providers/language_provider.dart';

class L {
  final AppLang lang;
  L(this.lang);

  String get errorMessage => lang == AppLang.th ? "เกิดข้อผิดพลาดกรุณาลองใหม่อีกครั้ง" : "There's some problem try again later.";


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
  String get username => lang == AppLang.th ? "ชื่อผู้ใช้" : "Username";
  String get password => lang == AppLang.th ? "รหัสผ่าน" : "Password";
  String get confirmPassword => lang == AppLang.th ? "ยืนยันรหัสผ่าน" : "Confirm Password";
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
  String get newUsernameHint => lang == AppLang.th ? "ชื่อผู้ใช้ใหม่" : "new username";
  
  String get oldPassHint => lang == AppLang.th ? "รหัสผ่านเดิม" : "old password";
  String get newPassHint => lang == AppLang.th ? "รหัสผ่านใหม่" : "new password";
  String get confirmPassHint => lang == AppLang.th ? "ยืนยันรหัสผ่าน" : "confirm password";

  String get signOutButton => lang == AppLang.th ? "ออกจากระบบ" : "Sign Out";
  String get confirmtoSignOutTitle =>
      lang == AppLang.th ? "ยืนยันที่จะออกจากระบบหรือไม่" : "Are you sure want to SIGN OUT?";
  String get adminButton => lang == AppLang.th ? "ไปหน้าแอดมิน" : "Go to admin dashboard";

  String get fulfillTheBox => lang == AppLang.th ? "กรุณากรอกข้อมูลให้ครบ" :  "Please fill in the blank.";
  String get passwordNotMatched => lang == AppLang.th ? "รหัสผ่านไม่ตรงกัน" :  "Passwords do not match.";
  String get passwordNeedAtLeast => lang == AppLang.th ? "รหัสผ่านต้องการอย่างน้อย 6 ตัวอักษร" :  "A password requiring at least 6 characters.";
  String get passwordChanged => lang == AppLang.th ? "เปลี่ยนรหัสผ่านเรียบร้อยแล้ว" :  "Password changed successfully.";
  String get wrongOldPassword => lang == AppLang.th ? "รหัสผ่านเดิมไม่ถูกต้อง" :  "The previous password is incorrect.";
  String get wrongPassword => lang == AppLang.th ? "รหัสผ่านไม่ถูกต้อง" :  "The password is incorrect.";
  String get invalidEmail => lang == AppLang.th ? "รูปแบบอีเมลไม่ถูกต้อง" :  "The email format is incorrect.";
  String get emailAlreadyInUse => lang == AppLang.th ? "อีเมลนี้มีผู้ใช้งานแล้ว" :  "Email already in use";
  String get emailChanged => lang == AppLang.th ? "เปลี่ยนอีเมลสำเร็จ" :  "Email Changed successfully.";

  // Profile Page
  String get profileTitle => lang == AppLang.th ? "โปรไฟล์" : "Profile";
  String get badgeTitle => lang == AppLang.th ? "เหรียญตรา" : "Badge";
  String get achievementTitle => lang == AppLang.th ? "ความสำเร็จ" : "Achievement";
  String get usernameChanged => lang == AppLang.th ? "เปลี่ยนชื่อผู้ใช้สำเร็จ" :  "Username Changed successfully.";

  // Admin Dashboard
  String get adminTitle => lang == AppLang.th ? "แอดมิน" : "Admin";
  String get adminTabUser => lang == AppLang.th ? "ผู้ใช้" : "User";
  String get adminTabMessage => lang == AppLang.th ? "ข้อความ" : "Message";

  String get adminSubUserList => lang == AppLang.th ? "รายชื่อผู้ใช้" : "User List";
  String get adminSubReportedUser => lang == AppLang.th ? "ผู้ใช้ถูกรายงาน" : "Reported User";
  String get adminSubMessage => lang == AppLang.th ? "ข้อความ" : "Message";
  String get adminSubReportedMessage => lang == AppLang.th ? "ข้อความถูกรายงาน" : "Reported Message";

  String get adminSearchHint => lang == AppLang.th ? "ค้นหา" : "Search";
  String get adminFilter => lang == AppLang.th ? "ตัวกรอง" : "Filter";

  String get adminUserDetailBtn => lang == AppLang.th ? "ดูผู้ใช้" : "User Detail";
  String get adminMessageDetailBtn => lang == AppLang.th ? "ดูข้อความ" : "Message Detail";

  String get adminUid => "UID";
  String get adminEmail => lang == AppLang.th ? "อีเมล" : "Email";
  String get adminRole => lang == AppLang.th ? "บทบาท" : "Role";
  String get adminLevel => lang == AppLang.th ? "เลเวล" : "Level";
  String get adminLanguage => lang == AppLang.th ? "ภาษา" : "Language";
  String get adminCreated => lang == AppLang.th ? "สร้างเมื่อ" : "Created";
  String get adminLastActive => lang == AppLang.th ? "ใช้งานล่าสุด" : "Last Active";

  String get adminReportedAccount => lang == AppLang.th ? "บัญชีถูกรายงาน" : "Reported Account";
  String get adminCleanRecord => lang == AppLang.th ? "ปกติ" : "Clean Record";
  String get adminReportedCountPrefix => lang == AppLang.th ? "มีผู้ใช้รายงาน " : "";
  String get adminReportedCountSuffix => lang == AppLang.th ? " คน" : " users reported this user";
  String get unbannedUserSuccessfully => lang == AppLang.th ? "ปลดแบนแล้ว" : "Unbanned this user";
  String get bannedUserSuccessfully => lang == AppLang.th ? "แบนเรียบร้อย" : "Banned this user";
  String get ban=> lang == AppLang.th ? "ระงับบัญชี" : "Ban";
  String get unban => lang == AppLang.th ? "ยกเลิกการระงับบัญชี" : "Unban";
  String get adminClose => lang == AppLang.th ? "ปิด" : "Close";
  String get adminDelete => lang == AppLang.th ? "ลบ" : "Delete";
  String get adminDeleted => lang == AppLang.th ? "ลบเรียบร้อย" : "Deleted";
  String get adminReportDetail => lang == AppLang.th ? "รายละเอียดรายงาน" : "Report Detail";
  String get adminReportReason => lang == AppLang.th ? "เหตุผล" : "Reason";
  String get adminReportType => lang == AppLang.th ? "ประเภท" : "Type";
  String get adminTargetId => lang == AppLang.th ? "ID เป้าหมาย" : "Target ID";
  String get adminAccountInfo => lang == AppLang.th ? "ข้อมูลบัญชี" : "Account Info";
  String get adminActivityStats => lang == AppLang.th ? "กิจกรรม & สถิติ" : "Activity & Stats";
  String get adminLikesGiven => lang == AppLang.th ? "ถูกใจผู้อื่น" : "Likes Given";
  String get adminJoined => lang == AppLang.th ? "วันที่สมัคร" : "Created";

  String get adminAckKeep => lang == AppLang.th ? "รับทราบ" : "Acknowledge";
  String get adminDeleteContent => lang == AppLang.th ? "ลบเนื้อหา" : "Delete Content";
  String get adminBanUser => lang == AppLang.th ? "แบนผู้ใช้" : "Ban User";

  String get adminMsgAckKeep => lang == AppLang.th ? "รับทราบ: เก็บเนื้อหาไว้" : "Acknowledged: Content kept";
  String get adminMsgDeleteSuccess => lang == AppLang.th ? "จัดการเรียบร้อย (ลบเนื้อหา + ลบรายงาน)" : "Success (Content deleted + Report deleted)";
  String get adminMsgBanSuccess => lang == AppLang.th ? "แบนผู้ใช้เรียบร้อย" : "User banned successfully";

  // Leaderboard  
  String get leaderboardTitle => lang == AppLang.th ? "อันดับ" : "Leaderboard";
  String get leaderboardPostTab => lang == AppLang.th ? "จำนวนโพสต์" : "Posts";
  String get leaderboardLikeTab => lang == AppLang.th ? "ไลก์" : "Likes";
  String get leaderboardButton => lang == AppLang.th ? "ตารางอันดับ" : "Leaderboard";

  //HOme page
  String get postTitle => lang == AppLang.th ? "โพสต์" : "Post";
  String get replyHint => lang == AppLang.th ? "พิมพ์ตอบกลับ..." : "Reply something...";
  String get noReplyYet => lang == AppLang.th ? "ยังไม่มีคนตอบกลับ เป็นคนแรกสิ!" : "No one reply this be the first one";
  String get reportReasonTitle => lang == AppLang.th ? "รายงานความไม่เหมาะสม" : "Report with reason";
  String get reportReasonHint => lang == AppLang.th ? "ใส่เหตุผลที่นี่..." : "Enter reason here...";
  String get submitReport => lang == AppLang.th ? "ส่งรายงาน" : "Submit Report";
  String get reportSuccess => lang == AppLang.th ? "ส่งรายงานเรียบร้อยแล้ว" : "Report submitted successfully.";
  String get locationPermissionDenied => lang == AppLang.th ? "ไม่สามารถใช้งานตำแหน่งได้ กรุณาเปิด Location และ Permission" : "Location access denied. Please enable location permissions.";
  
  String get pleaseLoginFirst => lang == AppLang.th ? "กรุณาล็อกอินก่อนดูข้อความ" : "Please login to view messages";
  
  String distanceTooFar(String dist, String remain) => lang == AppLang.th ? " ไกลเกินไป! ต้องเข้าใกล้อีก $remain m" : "Too far!, Get $remain m closer to open";
      
  String get findingLocation => lang == AppLang.th ? "กำลังหาพิกัดของคุณ... รอก่อนนะ" : "Locating you... wait a minute who are u";
  
  // Create Post Sheet
  String get createPostTitle => lang == AppLang.th ? "ทิ้งข้อความไว้ที่นี่..." : "Drop a message here...";
  
  String get createPostHint => lang == AppLang.th ? "พิมพ์ข้อความของคุณ..." : "Type your message here...";
  
  String get createPostButton => lang == AppLang.th ? "ทิ้งข้อความ" : "Drop Message";
      
  String get createPostSuccess => lang == AppLang.th ? "สร้างโพสต์สำเร็จ!" : "Message dropped successfully! 👻";
      
  String errorOccurred(String error) => lang == AppLang.th ? "เกิดข้อผิดพลาด: $error" : "An error occurred: $error";
      
  String get mapMode => lang == AppLang.th ? "โหมด" : "Mode";
  String get reportPost => lang == AppLang.th ? "รายงานโพสต์นี้" : "Report this post.";
  String get reportUser => lang == AppLang.th ? "รายงานผู้ใช้" : "Report this user.";
  String get reportReply => lang == AppLang.th ? "รายงานการตอบกลับ" : "Report this reply.";
  String get reportReplyWithReason => lang == AppLang.th ? "รายงานด้วยเหตุผล (ตอบกลับ)" : "Report Reason (reply)";
  String get reportPostWithReason => lang == AppLang.th ? "รายงานด้วยเหตุผล (โพสต์)" : "Report Reason (post)";
  String get reportUserWithReason => lang == AppLang.th ? "รายงานด้วยเหตุผล (ผู้ใช้)" : "Report Reason (user)";


  //Authorities
  String get signIn => lang == AppLang.th ? "เข้าสู่ระบบ" : "Sign In"; 
  String get signUp => lang == AppLang.th ? "สมัครสมาชิก" : "Sign Up"; 
  String get noHaveAccount => lang == AppLang.th ? "ไม่มีบัญชีงั้นเหรอ กดเลยที่นี่!" : "Doesn't have an account? Sign Up"; 
  String get haveAccount => lang == AppLang.th ? "มีบัญชีแล้วงั้นเหรอ ไปที่เข้าสู่ระบบ ตรงนี้!" : "Already have an account? Sign In"; 
  String get accountSuspended => lang == AppLang.th ? "บัญชีของคุณถูกระงับการใช้งาน กรุณาติดต่อแอดมิน" : "Your account has been suspended. Please contact admin.";
  String get signInFailed => lang == AppLang.th ? "ไม่สามารถเข้าสู่ระบบได้" : "Sign in Failed";
}