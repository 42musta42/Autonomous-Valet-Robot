import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:valet_robot/time_cost.dart';



class SplashScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen>{
  int splashtime = 2;


  // duration of splash screen on second

  @override
  void initState() {
    Future.delayed(Duration(seconds: splashtime), () async {
      Navigator.pushReplacement(context, MaterialPageRoute(
        //pushReplacement = replacing the route so that
        //splash screen won't show on back button press
        //navigation to Home page.
          builder: (context){
            return MyCarPage();
          }));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:Container(
            alignment: Alignment.center,
            child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:<Widget>[
                  Container(
                    child:SizedBox(
                        height:200,width:200,
                        child:
                        Lottie.asset("assets/images/EfsrF5TbJV899x3I43.json")
                    ),
                  ),
                  Container(
                    margin:EdgeInsets.only(top:15),
                    child:LoadingAnimationWidget.staggeredDotsWave(
                        size: 45,
                        color: Color(0xFFfba321)
                    ),
                  ),
                ]
            )
        )
    );
  }
}
