import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Humor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MoodHomePage(),
    );
  }
}

class MoodHomePage extends StatefulWidget {
  const MoodHomePage({super.key});

  @override
  _MoodHomePageState createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
  List<String> moods = ["Feliz", "Triste", "Estressado", "Calmo", "Ansioso"];
  String? selectedMood;
  List<String> moodHistory = [];

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  // Carregar histórico de humor de `SharedPreferences`
  Future<void> _loadMoodHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      moodHistory = prefs.getStringList('moodHistory') ?? [];
    });
  }

  // Salvar humor atual no histórico e em `SharedPreferences`
  Future<void> _saveMood() async {
    if (selectedMood != null) {
      setState(() {
        moodHistory.add(selectedMood!);
        selectedMood = null;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('moodHistory', moodHistory);
    }
  }

  // Widget para exibir o gráfico de humor
  Widget _buildMoodChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
                moodHistory.length,
                (index) => FlSpot(
                      index.toDouble(),
                      moods.indexOf(moodHistory[index]).toDouble(),
                    )),
            isCurved: true,
            dotData: const FlDotData(show: true),
            color: Colors.blueAccent,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.3),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                // Mapear índices dos humores para os respectivos nomes
                if (value >= 0 && value < moods.length) {
                  return Text(moods[value.toInt()],
                      style: const TextStyle(fontSize: 12));
                }
                return const Text('');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  'Dia ${(value + 1).toInt()}', // ou outro indicador de tempo
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black, width: 2),
            left: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBorder: BorderSide(color: Colors.yellow.withOpacity(0.8)),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final moodIndex = touchedSpot.y.toInt();
                final moodName = moodIndex >= 0 && moodIndex < moods.length
                    ? moods[moodIndex]
                    : '';
                return LineTooltipItem(
                  moodName,
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Humor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Como você se sente hoje?',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedMood,
              hint: const Text("Selecione seu humor"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMood = newValue;
                });
              },
              items: moods.map<DropdownMenuItem<String>>((String mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(mood),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMood,
              child: const Text("Salvar Humor"),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Histórico de Humor',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildMoodChart()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
