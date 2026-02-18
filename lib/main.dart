import 'package:flutter/material.dart';
import 'package:flutter_bmi_calculator/result_page.dart';
import 'package:flutter_bmi_calculator/splash_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'bmi_model.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter BMI Calculator',
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

  final FocusNode nameFocus = FocusNode();
  final FocusNode wtFocus = FocusNode();
  final FocusNode ftFocus = FocusNode();
  final FocusNode inchFocus = FocusNode();

  var wtController = TextEditingController();
  var ftController = TextEditingController();
  var inController = TextEditingController();
  var nameController = TextEditingController();

  String? wtError;
  String? ftError;
  String? inchError;
  String? nameError;

  var result = "";

  RangeValues values = RangeValues(0, 10);

  List<BMIModel> historyList = [];

  Future<void> saveHistory(BMIModel model) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('bmi_history') ?? [];
    history.add(jsonEncode(model.toJson()));
    await prefs.setStringList('bmi_history', history);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('bmi_history') ?? [];

    historyList = history
        .map((item) => BMIModel.fromJson(jsonDecode(item)))
        .toList()
        .reversed
        .toList();
    setState(() {});
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bmi_history');
    historyList.clear();
    setState(() {});
  }

  Future<void> confirmClear() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete History?"),
        content: Text("Are you sure you want to clear all history?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await clearHistory();
            },
            child: Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadHistory();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(nameFocus);
    });
  }

  @override
  void dispose() {
    nameFocus.dispose();
    wtFocus.dispose();
    ftFocus.dispose();
    inchFocus.dispose();
    super.dispose();
  }

  Future<void> calculateBMI() async {

    var wt = wtController.text.trim();
    var ft = ftController.text.trim();
    var inch = inController.text.trim();
    var name = nameController.text.trim();

    wtError = null;
    ftError = null;
    inchError = null;
    nameError = null;

    bool hasError = false;

    if (name.isEmpty) {
      nameError = "Please enter name";
      hasError = true;
    }

    if (wt.isEmpty) {
      wtError = 'Please enter weight';
      hasError = true;
    }

    if (ft.isEmpty) {
      ftError = 'Please enter height in feet';
      hasError = true;
    }

    if (inch.isEmpty) {
      inchError = 'Please enter height in inch';
      hasError = true;
    }

    setState(() {});
    if (hasError) return;

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

    await saveHistory(
      BMIModel(
        name: name,
        result: finalResult,
        bgColor: bg.toARGB32(),
        date: DateFormat('dd MMM yyyy – hh:mm a')
            .format(DateTime.now()),
      ),
    );

    await loadHistory();

    if (!mounted) return;

    final shouldClear = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResultPage(name, finalResult, bg),
      ),
    );
    if (!mounted) return;

    if (shouldClear == true) {
      wtController.clear();
      ftController.clear();
      inController.clear();
      nameController.clear();
      FocusScope.of(context).requestFocus(nameFocus);
    }
  }

  Widget buildHistorySection() {
    if (historyList.isEmpty) {
      return Column(
        children: [
          SizedBox(height: 40),
          Icon(Icons.history, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No History Yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "History",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: confirmClear,
              icon: Icon(Icons.delete, size: 18, color: Colors.white),
              label: Text("Clear", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),

        SizedBox(height: 10),

        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            final item = historyList[index];

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(item.bgColor),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(item.name),
                subtitle: Text(item.date),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResultPage(
                            item.name,
                            item.result,
                            Color(item.bgColor),
                          ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'BMI Calculator',
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
                          controller: nameController,
                          focusNode: nameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(wtFocus);
                          },
                          keyboardType: TextInputType.text,
                          onChanged: (value){
                            if(value.isNotEmpty && nameError != null){
                              setState(() {
                                nameError=null;
                              });

                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person),
                            labelText: 'Name',
                            errorText: nameError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                          ),


                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: wtController,
                          focusNode: wtFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(ftFocus);
                          },
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
                          focusNode: ftFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(inchFocus);
                          },
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
                          focusNode: inchFocus,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                            calculateBMI();
                          },
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
                            onPressed: calculateBMI,
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


                buildHistorySection(),

              ],
            ),
          ),
        ),
      ),

    );
  }
}
