import 'package:flutter/material.dart';

class BMIModel {
  final String name;
  final String result;
  final String date;
  final int bgColor;

  BMIModel({
    required this.name,
    required this.result,
    required this.date,
    required this.bgColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'result': result,
      'date': date,
      'bgColor': bgColor,
    };
  }

  factory BMIModel.fromJson(Map<String, dynamic> json) {
    return BMIModel(
      name: json['name'],
      result: json['result'],
      date: json['date'],
      bgColor: json['bgColor'] ?? Colors.blue.toARGB32(),
    );
  }
}

