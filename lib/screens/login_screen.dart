import 'package:flutter/material.dart';
import 'package:pdh_recommendation/navigation_controller.dart';
import 'home_screen.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.displaySmall;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Text(
                'PDH Recommendations',
                textAlign: TextAlign.center,
                style: style!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold
                  
                ),
              ),
              // child: ListTile(
              //   title: Text('PDH Recommendations', textAlign: TextAlign.center, style: style),
              // ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
            ),

            Image.asset(
              'lib/assets/fit-seal.png',
              width: 250,
              height: 200,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
            ),

            TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Student ID',
              ),
            ),

            BirthdayDropdown(),

            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => NavigationController()),
                );
              }, 
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Login', textAlign: TextAlign.center),
            )
          ],
        ),
      ),
    );
  }
}

class  BirthdayDropdown extends StatefulWidget {
  @override
  State<BirthdayDropdown> createState() => _BirthdayDropdownState();
}

class _BirthdayDropdownState extends State<BirthdayDropdown> {
  int? selectedMonth;
  int? selectedDay;

  List<int> months = List.generate(12, (index) => (index + 1));
  List<int> days = List.generate(31, (index) => (index + 1));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<int>(
            hint: Text('Month'),
            value: selectedMonth,
            onChanged: (value) {
              setState(() {
                selectedMonth = value;
              });
            },
            items: months.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString())
              );
            }).toList(),
          ),
          DropdownButton<int>(
            hint: Text('Day'),
            value: selectedDay,
            onChanged: (value) {
              setState(() {
                selectedDay = value;
              });
            },
            items: days.map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(value.toString())
              );
            }).toList(),
          ),
        ]
      )
    );
    
  }
}
