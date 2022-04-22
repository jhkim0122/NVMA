import 'package:flutter/material.dart';

class NVMABottomNavigationBar extends StatefulWidget{
  final Function(int index) setPageIndex;
  final int selectedIndex;
  const NVMABottomNavigationBar(this.setPageIndex, this.selectedIndex, {key}) : super(key:key);

  @override
  _NVMABottomNavigationBarState createState() => _NVMABottomNavigationBarState();
}

class _NVMABottomNavigationBarState extends State<NVMABottomNavigationBar> {

  _onTappedItem(index) {
    widget.setPageIndex(index);
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height:70,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: 0.8, color: Colors.grey.withOpacity(0.3)),),
        ),
        child: BottomNavigationBar(
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Main"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.mic),
                label: "Noise"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.vibration),
                label: "Vibration"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Setting"
            ),
          ],
          currentIndex: widget.selectedIndex,
          selectedItemColor: Colors.deepOrange,
          onTap: (index) => _onTappedItem(index),
        ));
  }

}