import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My First Flutter UI',
      home: const MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D2A1F),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6B4A36),
                Color(0xFF4A2F22),
                Color(0xFF1A120D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.brown[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akasaka Sad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Rina Sawayama',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.add_circle_outline, color: Colors.white),
                        SizedBox(width: 16),
                        Icon(Icons.favorite_border, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: 0.45,
                        onChanged: (_) {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '1:19',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '-1:39',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(Icons.shuffle, color: Colors.white70, size: 22),
                    const Icon(Icons.skip_previous, color: Colors.white, size: 32),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pause,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    const Icon(Icons.skip_next, color: Colors.white, size: 32),
                    const Icon(Icons.repeat, color: Colors.white70, size: 22),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.headphones, color: Colors.greenAccent, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Airpods Max',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.queue_music, color: Colors.white70, size: 20),
                        SizedBox(width: 16),
                        Icon(Icons.ios_share, color: Colors.white70, size: 20),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lyrics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.expand_less, color: Colors.white70),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
