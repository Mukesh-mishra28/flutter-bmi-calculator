import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_stateful_flutter_app/result_page.dart';
import 'package:new_stateful_flutter_app/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var wtController = TextEditingController();
  var ftController = TextEditingController();
  var inController = TextEditingController();

  String? wtError;
  String? ftError;
  String? inchError;

  var result = "";

  RangeValues values = RangeValues(0, 10);

  @override
  Widget build(BuildContext context) {


    RangeLabels labels = RangeLabels(
      values.start.toString(),
      values.end.toString(),

    );

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'BMI APP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfffdfcfb), Color(0xffe2d1c3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Text(
                  'Know Your BMI',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        TextField(
                          controller: wtController,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            if(value.isNotEmpty && wtError != null){
                              setState(() {
                                wtError=null;
                              });

                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.line_weight),
                            labelText: 'Weight (Kg)',
                            errorText: wtError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: ftController,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            if(value.isNotEmpty && ftError != null){
                              setState(() {
                                ftError=null;
                              });

                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.height),
                            labelText: 'Height (Feet)',
                            errorText: ftError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: inController,
                          keyboardType: TextInputType.number,
                          onChanged: (value){
                            if(value.isNotEmpty && inchError != null){
                              setState(() {
                                inchError=null;
                              });

                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.height),
                            labelText: 'Height (Inches)',
                            errorText: inchError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              var wt = wtController.text.trim();
                              var ft = ftController.text.trim();
                              var inch = inController.text.trim();

                              wtError = null;
                              ftError = null;
                              inchError = null;

                              bool hasError = false;

                              if(wt.isEmpty){
                                wtError='Please enter weight';
                                hasError = true;
                              }

                              if(ft.isEmpty){
                                ftError='Please enter height in feet';
                                hasError = true;
                              }
                              if(inch.isEmpty){
                                inchError='Please enter height in inch';
                                hasError = true;
                              }

                              setState(() {
                              });
                              if(hasError)return;

                              var iWt = int.parse(wt);
                              var iFt = int.parse(ft);
                              var iInch = int.parse(inch);

                              if (iWt <= 0) {
                                setState(() {
                                  wtError = "Weight must be greater than 0";
                                });
                                return;
                              }

                              if (iFt <= 0 && iInch <= 0) {
                                setState(() {
                                  ftError = "Invalid height";
                                  inchError = "Invalid height";
                                });
                                return;
                              }

                              var tInch = (iFt * 12) + iInch;
                              var tCm = tInch * 2.54;
                              var tM = tCm / 100;
                              var bmi = iWt / (tM * tM);

                              String msg;
                              Color bg;
                              String advice = "";
                              double targetBMI;

                              if (bmi >= 25) {
                                targetBMI = 24.9;
                              } else if (bmi < 18.5) {
                                targetBMI = 18.5;
                              } else {
                                targetBMI = bmi;
                              }

                              double targetWeight = targetBMI * (tM * tM);
                              double diff = (iWt - targetWeight).abs();

                              if (bmi >= 25) {
                                msg = "You are OverWeight!!";
                                bg = Colors.orange.shade200;
                                advice = "You need to lose: ${diff.toStringAsFixed(1)} kg";
                              } else if (bmi < 18.5) {
                                msg = "You are UnderWeight!!";
                                bg = Colors.redAccent.shade200;
                                advice = "You need to gain: ${diff.toStringAsFixed(1)} kg";
                              } else {
                                msg = "You are Healthy!!";
                                bg = Colors.green.shade200;
                                advice = "Your weight is perfectly normal";
                              }


                              final finalResult =
                                  "$msg\nYour BMI: ${bmi.toStringAsFixed(2)}\n$advice";

                              final shouldClear = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ResultPage(finalResult, bg),
                                ),
                              );

                              if (shouldClear == true) {
                                setState(() {
                                  wtController.clear();
                                  ftController.clear();
                                  inController.clear();
                                  result = "";
                                });
                              }
                            },
                            child: Text(
                              'Calculate BMI',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),

    );
  }
}
