import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: 
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SETTINGS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  
                      ExpansionTile(
                        title: Text(
                          'Application Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          ExpansionTile(
                            title: Text(
                              'Version History'
                            ),
                          ),
                          ExpansionTile(
                            title: Text(
                              'Permissions'
                            )
                          )
                        ],
                      ),
                      ExpansionTile(
                        title: Text(
                          'Manage Reviews',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          ExpansionTile(
                            title: Text(
                              'Flagged Reviews'
                            ),
                          ),
                          ExpansionTile(
                            title: Text(
                              'Resolved Issues'
                              ),
                          ),
                          ExpansionTile(
                            title: Text(
                              'All Reviews'
                              ),
                          )
                        ]
                      ),
                      ExpansionTile(
                        title: Text(
                          'Report A Problem',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          ExpansionTile(
                            title: Text(
                              'Report A Bug'
                            ),
                          ),
                          ExpansionTile(
                            title: Text(
                              'Request A Feature'
                            )
                          )
                        ]
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {},
                           child: Text('Log Out'),
                        ),
                      )
                    ],
                  ),
                ),
              ),

        )
      ),
    );
  }
}