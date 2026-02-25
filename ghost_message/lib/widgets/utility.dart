import 'package:flutter/material.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/auth_service.dart';
import 'package:ghost_message/services/user_firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildTextField({
  required TextEditingController ctrl,
  required String label,
  required IconData icon,
  bool isPassword = false,
}) {
  return TextField(
    controller: ctrl,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
    ),
  );
}

Widget buildSectionTitle(String text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 15),
    ],
  );
}

Future<void> pickImage(ImageSource source) async {
  
}

Widget buildSettingSwitchRow({
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
      GhostSwitch(value: value, onChanged: onChanged),
    ],
  );
}

Widget buildSettingEditRow({
  required BuildContext context,
  required String label,
  required String valueText,
  required String editText,
  required VoidCallback onEdit,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final bool isDark = themeProvider.isDarkMode;

  return Row(
    children: [
      SizedBox(
        width: 90,
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
      Expanded(
        child: Text(
          valueText,
          style: TextStyle(
            color:
                isDark
                    ? ThemeProvider.textDark.withOpacity(0.5)
                    : ThemeProvider.textLight.withOpacity(0.5),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      GestureDetector(
        onTap: onEdit,
        child: Text(
          editText,
          style: TextStyle(
            decoration: TextDecoration.underline,
            color:
                isDark
                    ? ThemeProvider.textDark.withOpacity(0.8)
                    : ThemeProvider.textLight.withOpacity(0.8),
          ),
        ),
      ),
    ],
  );
}

Widget buildSegmentPill({
  required BuildContext context,
  required List<String> items,
  required int selectedIndex,
  required ValueChanged<int> onTap,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final bool isDark = themeProvider.isDarkMode;

  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: isDark ? ThemeProvider.buttonDark : ThemeProvider.pillLight,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? ThemeProvider.borderDark : ThemeProvider.borderLight,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (i) {
        final isSelected = selectedIndex == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? (isDark
                          ? ThemeProvider.fieldDark
                          : ThemeProvider.bgLight)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              items[i],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
              ),
            ),
          ),
        );
      }),
    ),
  );
}

Widget _buildDialogField({
  required BuildContext context,
  required TextEditingController? controller,
  required String hint,
  required bool obscureText,
}) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  final bool isDark = themeProvider.isDarkMode;

  return Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: isDark ? ThemeProvider.fieldDark : ThemeProvider.pillLight,
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(
        color: isDark ? ThemeProvider.textDark : ThemeProvider.textLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}

void showEditEmailDialog(
  BuildContext context,
  L l,
  String currentEmail,
  Function(String) onConfirm,
) {
  final TextEditingController controller = TextEditingController(
    text: currentEmail,
  );
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final _firebaseAuthService = AuthService();
  final _firebaseUserService = UserFirestoreService();
  final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
  final bool isDark = themeProvider.isDarkMode;

  showDialog(
    context: context,
    builder: (context) {
      final titleColor = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.email,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildDialogField(
                    context: context,
                    controller: controller,
                    hint: l.newEmailHint,
                    obscureText: false,
                  ),

                  const SizedBox(height: 18),

                  _buildDialogField(
                    context: context,
                    controller: passwordController,
                    hint: l.password,
                    obscureText: true,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                final String newEmail = controller.text.trim();
                                final String password =
                                    passwordController.text.trim();
                                final bool isValidEmail = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(newEmail);

                                if (newEmail.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.fulfillTheBox)),
                                  );
                                  return;
                                } else if (!isValidEmail) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('รูปแบบอีเมลไม่ถูกต้อง'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
                                  final userAuth =
                                      FirebaseAuth.instance.currentUser;

                                  if (userAuth != null &&
                                      userAuth.email != null) {
                                    AuthCredential credential = EmailAuthProvider.credential(
                                      email: userAuth.email!,
                                      password:password,
                                    );

                                    await userAuth.reauthenticateWithCredential(
                                      credential,
                                    );

                                    await _firebaseAuthService.updateEmail(newEmail);
                                    await _firebaseUserService.saveNewEmail(newEmail, currentUser!.uid);

                                    if (context.mounted) {
                                      onConfirm(newEmail);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context,).showSnackBar(
                                        SnackBar(content: Text(l.emailChanged),
                                        ),
                                      );
                                    }
                                  }
                                } on FirebaseAuthException catch (e) {
                                  String errorMessage = l.errorMessage;
                                  if (e.code == 'invalid-credential' ||
                                      e.code == 'wrong-password') {
                                    errorMessage = l.wrongPassword;
                                  } else if (e.code == 'email-already-in-use') {
                                    errorMessage = l.emailAlreadyInUse;
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const StadiumBorder(),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                l.confirm,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: ThemeProvider.textDark,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? ThemeProvider.fieldDark
                                : ThemeProvider.buttonLight,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l.cancel,
                        style: TextStyle(fontSize: 18, color: titleColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
void showEditUsernameDialog( BuildContext context, L l, String currentUsername,) {
  final TextEditingController controller = TextEditingController(text: currentUsername,);
  bool isLoading = false;
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final _firebaseUserService = UserFirestoreService();
  final currentUser = Provider.of<UserProvider>(context, listen: false).currentUser;
  final bool isDark = themeProvider.isDarkMode;

  showDialog(
    context: context,
    builder: (context) {
      final titleColor = isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildDialogField(
                    context: context,
                    controller: controller,
                    hint: l.newUsernameHint,
                    obscureText: false,
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                final String newUsername = controller.text.trim();

                                if (newUsername.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.fulfillTheBox)),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
                                    await _firebaseUserService.saveNewUsername(newUsername, currentUser!.uid);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context,).showSnackBar(
                                        SnackBar(content: Text(l.usernameChanged),
                                        ),
                                      );
                                    }
                                  }
                                catch (e) {
                                  String errorMessage = l.errorMessage;

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const StadiumBorder(),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                l.confirm,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: ThemeProvider.textDark,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? ThemeProvider.fieldDark
                                : ThemeProvider.buttonLight,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l.cancel,
                        style: TextStyle(fontSize: 18, color: titleColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showEditPasswordDialog(BuildContext context, L l) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final bool isDark = themeProvider.isDarkMode;
  final _firebaseAuthService = AuthService();

  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (context) {
      final titleColor =
          isDark ? ThemeProvider.textDark : ThemeProvider.textLight;

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.password,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 15),

              _buildDialogField(
                context: context,
                controller: oldPassCtrl,
                hint: l.oldPassHint,
                obscureText: true,
              ),

              const SizedBox(height: 12),
              _buildDialogField(
                context: context,
                controller: newPassCtrl,
                hint: l.newPassHint,
                obscureText: true,
              ),

              const SizedBox(height: 12),

              _buildDialogField(
                context: context,
                controller: confirmPassCtrl,
                hint: l.confirmPassHint,
                obscureText: true,
              ),

              const SizedBox(height: 18),

              StatefulBuilder(
                builder: (context, setState) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                final oldPassword = oldPassCtrl.text.trim();
                                final newPassword = newPassCtrl.text.trim();
                                final confirmPassword =
                                    confirmPassCtrl.text.trim();

                                if (oldPassword.isEmpty ||
                                    newPassword.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.fulfillTheBox)),
                                  );
                                  return;
                                }

                                if (newPassword != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l.passwordNotMatched),
                                    ),
                                  );
                                  return;
                                }

                                if (newPassword.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l.passwordNeedAtLeast),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
                                  _firebaseAuthService.updatePassword(
                                    context,
                                    oldPassword,
                                    newPassword,
                                  );
                                } on FirebaseAuthException catch (e) {
                                  String errorMessage = l.errorMessage;
                                  if (e.code == 'invalid-credential' ||
                                      e.code == 'wrong-password') {
                                    errorMessage = 'รหัสผ่านเดิมไม่ถูกต้อง';
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() => isLoading = false);
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const StadiumBorder(),
                      ),
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                              : Text(
                                l.confirm,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: ThemeProvider.textDark,
                                ),
                              ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark
                            ? ThemeProvider.fieldDark
                            : ThemeProvider.buttonLight,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    l.cancel,
                    style: TextStyle(fontSize: 18, color: titleColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class GhostSwitch extends StatelessWidget {
  const GhostSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    const double w = 64;
    const double h = 34;
    const double padding = 3;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final double thumbSize = value ? 28 : 18;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: w,
        height: h,
        padding: const EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color:
              value
                  ? (isDark
                      ? const Color.fromARGB(255, 168, 202, 168)
                      : const Color(0xFFBFE6BF))
                  : (isDark
                      ? ThemeProvider.buttonDark
                      : ThemeProvider.buttonLight),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? Colors.transparent : Colors.grey,
            width: 1.8,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: value ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget buildPillButton({
//   required BuildContext context,
//   required String text,
//   required VoidCallback onPressed,
// }) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;

//   final bg = isDark ? ThemeProvider.buttonDark : const Color.fromARGB(255, 202, 23, 23);
//   final border = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
//   final textColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? ThemeProvider.textDark : Colors.black);

//   return SizedBox(
//     width: double.infinity,
//     height: 55,
//     child: ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: bg,
//         elevation: 0,
//         shape: const StadiumBorder(),
//         side: BorderSide(color: border),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     ),
//   );
// }
