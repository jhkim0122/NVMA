
import 'package:flutter/material.dart';

getCard(Widget widget, {color}){
  return Container(
      margin: const EdgeInsets.symmetric(horizontal:15, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: color??Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5)
      ),
      child: widget
  );
}