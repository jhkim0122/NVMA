import 'package:flutter/material.dart';

class NVMABottomNavigationBar extends StatefulWidget{
  final String currentPage;
  final Function(int index) getPageView;
  const NVMABottomNavigationBar(this.getPageView, {this.currentPage="", key}) : super(key:key);

  @override
  _NVMABottomNavigationBarState createState() => _NVMABottomNavigationBarState();
}

class _NVMABottomNavigationBarState extends State<NVMABottomNavigationBar> {
  int _selectedIndex = 0;

  static const int _noiseIndex = 0;
  static const int _vibrationIndex = 1;

  @override
  initState() {
    super.initState();
    _getSelectedIndex();
  }

  _getSelectedIndex(){
    if(widget.currentPage == 'noise') {
      _selectedIndex = _noiseIndex;
    } else if(widget.currentPage == 'vibration') {
      _selectedIndex = _vibrationIndex;
    }
  }

  _onTappedItem(index) {
    _selectedIndex = index;
    if(index == _noiseIndex && widget.currentPage != 'noise') {
      widget.getPageView(index);
    }
    if(index == _vibrationIndex && widget.currentPage != 'vibration') {
      widget.getPageView(index);
    }
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
                icon: Icon(Icons.mic),
                label: "Noise"
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.vibration),
                label: "Vibration"
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepOrange,
          onTap: (index) => _onTappedItem(index),
        ));
  }

}