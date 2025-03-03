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

            Image.asset(
              'lib/assets/fit_panther.png',
              width: 250,
              height: 200,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
            ),

            Card(
              color: Theme.of(context).colorScheme.primary,
              elevation: 0,
              child: Text(
                'Panther Dining Recommendations',
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

            TextField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: 'example@fit.edu',
                fillColor: Colors.white,
                filled: true,
              ),
            ),

            TextField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                labelText: 'TRACKS Password',
                fillColor: Colors.white,
                filled: true,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.blue,
                    ),
                  ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => NavigationController()),
                    );
                  }, 
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: Text('Login', textAlign: TextAlign.center),
                ),
              ],
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
