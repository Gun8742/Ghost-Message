import 'package:flutter/material.dart';
import 'package:ghost_message/models/achievement_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectIndex = 0;
  final List<AchievementModel> achievement1 = [
    AchievementModel(title: "First", progress: 0.2),
    AchievementModel(title: "Second", progress: 0.5),
    AchievementModel(title: "Third", progress: 0.8),
    AchievementModel(title: "Fourth", progress: 0.3),
    ];
  final List<AchievementModel> achievement2 = [
    AchievementModel(title: "Fifth", progress: 0.9),
    AchievementModel(title: "Sixth", progress: 0.8),
    AchievementModel(title: "Seventh", progress: 0.8),
    AchievementModel(title: "Eighth", progress: 0.8),
  ];
  final List<AchievementModel> achievement3 = [
    AchievementModel(title: "Ninth", progress: 0.9),
    AchievementModel(title: "Ten", progress: 0.8),
  ];
  late final List<List<AchievementModel>> separatedAchievement = [
    achievement1,
    achievement2,
    achievement3
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile",
        style: TextStyle(
          fontWeight: FontWeight.bold
        )
        ),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade300,
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
          IndexedStack(
            index: _selectIndex,
            children: separatedAchievement.map((items){
              return _achievementColumnBuild(items);
            }).toList()
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                Icons.arrow_back_ios,
                color: _selectIndex > 0 ? Colors.black : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectIndex > 0) {
                      _selectIndex--;
                    }
                  });
                },
              ),
              Text(
                "${_selectIndex + 1}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
              ),
              SizedBox(width: 7),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: _selectIndex < separatedAchievement.length - 1 ? Colors.black : Colors.grey,
                  ),
                onPressed: () {
                  setState(() {
                    if (_selectIndex < separatedAchievement.length - 1) {
                      _selectIndex++;
                    }
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 100,)
        ],
      )
    );
  }
}

Widget _buildAchievement(AchievementModel item) {
  return Card(
    color: Colors.grey.shade300,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    child: ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade700,
        child: Text(item.title[0], style: TextStyle(color: Colors.white)), 
      ),
      title: Text(item.title),
      subtitle: Slider(
        value: item.progress * 100,
        onChanged: null,
        activeColor: Colors.blue,
        thumbColor: Colors.blue,
        inactiveColor: Colors.grey.shade400,
        min: 0,
        max: 100,
      ),
      horizontalTitleGap: 10,
    ),
  );
}

Widget _buildBadge() {
  return Container(
    width: 150,
    height: 150,
    padding: EdgeInsets.all(4), 
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.grey.shade300,
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

Widget _achievementColumnBuild(List<AchievementModel> items) {
  return Column(
    children: items.map((item){
      return Column(
        children: [
          _buildAchievement(item),
          SizedBox(height: 5),
        ],
      );
    }).toList()
  );
}