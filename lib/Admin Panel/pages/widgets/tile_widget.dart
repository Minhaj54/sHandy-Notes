import 'package:flutter/material.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({super.key, required this.title, required this.index, required this.icon, required this.onTap});
  final String title;
  final String index;
  final IconData icon;
  final VoidCallback onTap;


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent,
      child:
      ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(8),
        title: Text(title,style: const TextStyle(color: Colors.white,fontSize : 20, fontWeight: FontWeight.bold),),
        leading:  CircleAvatar(child: Icon(icon,color: Colors.red,),),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,color: Colors.white,),
      ),
    );
  }
}
