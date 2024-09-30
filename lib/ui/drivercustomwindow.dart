
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jutcapp/model/drivermodel.dart';

class CustomWindow extends StatelessWidget {
  const CustomWindow({super.key, required this.info});
  final Drivermodel info;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.4), spreadRadius: 2, blurRadius: 5),
                ],
              ),
              width: double.infinity,
              height: double.infinity,
              child: Container(
                child: Row(
                  children: [
                    if (info.type == InfoWindowType.position)
                      Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        color: Colors.amber,
                        height: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${(info.time!.inMinutes) % 60}',
                                style: const TextStyle(color: Colors.black)),
                            const Text('min',
                                style:TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    Expanded(
                  
                        child: Text(
                      '${info.name}',
                      style:const TextStyle(color: Colors.black),
                    )).paddingAll(8),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}