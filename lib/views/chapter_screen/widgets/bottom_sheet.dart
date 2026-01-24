import 'package:flutter/material.dart';

class PlaySheetBottom extends StatelessWidget {
  const PlaySheetBottom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.pause),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next),
              ),
            ],
          )
        ]));
  }
}
