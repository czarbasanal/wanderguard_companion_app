import 'package:flutter/material.dart';

class CompanionDetail extends StatelessWidget {
  final bool isEditMode;

  CompanionDetail({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Companion detail',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF313131),
            ),
          ),
          SizedBox(height: 10),
          isEditMode
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: 'Ryan Mendoza',
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: '+639081102982',
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: 'ryanmendoza@gmail.com',
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      initialValue: '12 orchid street, Capitol site',
                      decoration: InputDecoration(
                        labelText: 'Home Address',
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF313131),
                            ),
                          ),
                          TextSpan(text: 'Ryan Mendoza'),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Phone Number: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF313131),
                            ),
                          ),
                          TextSpan(text: '+639081102982'),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Email: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF313131),
                            ),
                          ),
                          TextSpan(text: 'ryanmendoza@gmail.com'),
                        ],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Home Address: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF313131),
                            ),
                          ),
                          TextSpan(text: '12 orchid street, Capitol site'),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
