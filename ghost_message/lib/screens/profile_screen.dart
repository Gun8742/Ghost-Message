import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 200,
                  height: 200,
                  padding: EdgeInsets.all(4), 
                  decoration: BoxDecoration(
                    color: Colors.white, // พื้นหลังของช่องว่างให้เป็นสีขาว (หรือสีเดียวกับพื้นหลังแอป)
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300, // แนะนำสีเทาอ่อน หรือ สีหลักของแอป (Theme Color)
                      width: 3.0, 
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/black.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                  right: 80,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit_square),
                    onPressed: () {},
                )
              )
            ]
          ),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 40,),
                Text(
                  "FirstName",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
                SizedBox(width: 10),
                Text(
                  "LastName",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  )
                ),
                IconButton(
                  icon: Icon(Icons.edit_square),
                  onPressed: () {
                    
                  },
                )
              ]
            )
          ),
          SizedBox(height: 30),
          Text(
            textAlign: TextAlign.center,
            "Badge",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 180,
            child:
            ListView(
              padding: EdgeInsets.all(12),
              scrollDirection: Axis.horizontal,
              children: [
                _buildBadge(),
                _buildBadge(),
                _buildBadge(),
                _buildBadge()
              ],
            )
          ),
          SizedBox(height: 30,),
          Text(
            textAlign: TextAlign.center,
            "Achievement",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
            ),
          ),
          SizedBox(height: 30,),
          Column(
            children: [
              _buildAchievement(),
              SizedBox(height: 5,),
              _buildAchievement(),
              SizedBox(height: 5,),
              _buildAchievement(),
              SizedBox(height: 5,),
              _buildAchievement(),
            ],
          )
        ],
      )
    );
  }
}

Widget _buildAchievement() {
  return Card(
    color: Colors.grey.shade300,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade700,
      ),
      title: Text("Achievement"),
      subtitle: Slider(
          value: 0.2,
          onChanged: (val) {},
          activeColor: Colors.blue,
          thumbColor: Colors.blue,
          inactiveColor: Colors.grey.shade400,
        ),
      horizontalTitleGap: 10,
    )
  );
}

Widget _buildBadge() {
  return Container(
    width: 150,
    height: 150,
    padding: EdgeInsets.all(4), 
    decoration: BoxDecoration(
      color: Colors.white, // พื้นหลังของช่องว่างให้เป็นสีขาว (หรือสีเดียวกับพื้นหลังแอป)
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey.shade300, // แนะนำสีเทาอ่อน หรือ สีหลักของแอป (Theme Color)
        width: 3.0, 
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: ClipOval(
      child: Image.asset(
        "assets/images/black.png",
        fit: BoxFit.cover,
      ),
    ),
  );
}