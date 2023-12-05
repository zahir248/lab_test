import 'package:flutter/material.dart';
import 'BMIDatabase.dart';

void main() {
  runApp(BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      home: BMICalculator(),
    );
  }
}

class BMIRecord {
  String fullName;
  double height;
  double weight;
  String gender;
  double bmi;
  String status;

  BMIRecord({
    required this.fullName,
    required this.height,
    required this.weight,
    required this.gender,
    required this.bmi,
    required this.status,
  });
}

class BMICalculator extends StatefulWidget {
  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  String gender = 'Male';
  double bmi = 0.0;
  String status = "";
  List<BMIRecord> bmiRecords = [];

  final BMIDatabase _bmiDatabase = BMIDatabase.instance;

  @override
  void initState() {
    super.initState();
    _initDatabase(); // Call the init method during initialization
  }

  void _initDatabase() async {
    await _bmiDatabase.init();
  }

  void calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;

    setState(() {
      bmi = weight / ((height / 100) * (height / 100));

      if (gender == 'Male') {
        if (bmi < 18.5) {
          status = "Underweight. Careful during strong wind!";
        } else if (18.5 <= bmi && bmi <= 24.9) {
          status = "That’s ideal! Please maintain";
        } else if (25.0 <= bmi && bmi <= 29.9) {
          status = "Overweight! Work out please";
        } else {
          status = "Whoa Obese! Dangerous mate!";
        }
      } else if (gender == 'Female') {
        if (bmi < 16) {
          status = "Underweight. Careful during strong wind!";
        } else if (16 <= bmi && bmi <= 22) {
          status = "That’s ideal! Please maintain";
        } else if (22 <= bmi && bmi <= 27) {
          status = "Overweight! Work out please";
        } else {
          status = "Whoa Obese! Dangerous mate!";
        }
      } else {
        status = "Invalid gender input";
      }

      BMIRecord record = BMIRecord(
        fullName: fullNameController.text,
        height: height,
        weight: weight,
        gender: gender,
        bmi: bmi,
        status: status,
      );

      bmiRecords.add(record);

      // Clear input fields after calculation
      fullNameController.clear();
      heightController.clear();
      weightController.clear();

      _bmiDatabase.insertData({
        _bmiDatabase.colUsername: fullNameController.text,
        _bmiDatabase.colWeight: weight,
        _bmiDatabase.colHeight: height,
        _bmiDatabase.colGender: gender,
        _bmiDatabase.colStatus: status,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(labelText: 'Your Fullname'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Height in cm; 170'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight in KG'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: bmi != 0.0 ? '$bmi' : 'BMI Value'),
                enabled: false,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio(
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value.toString();
                      });
                    },
                  ),
                  Text('Female'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  calculateBMI();
                },
                child: Text('Calculate BMI and Save'),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true, // Ensure this property is set
                itemCount: bmiRecords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${bmiRecords[index].status}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
