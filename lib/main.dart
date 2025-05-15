//Felipe da Silva Leal e Felipe Leite
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Previsão do Tempo',
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Colors.white70,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiKey = '78a7fbfbd9be4e3f8b5170839251405';
  String cidade = 'Alfenas';
  final TextEditingController controller = TextEditingController();
  Map<String, dynamic>? clima;
  bool carregando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    buscarClima();
  }

  Future<void> buscarClima() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    final url = Uri.parse(
      'https://api.weatherapi.com/v1/current.json?q=$cidade&lang=pt&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          clima = jsonDecode(response.body);
          carregando = false;
        });
      } else {
        setState(() {
          erro = 'Cidade não encontrada';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao buscar os dados';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Previsão do Tempo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                if (carregando)
                  const CircularProgressIndicator()
                else if (erro != null)
                  Text(
                    erro!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                    ),
                  )
                else if (clima != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF5853EC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 10,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.network(
                          'https:${clima!['current']['condition']['icon']}',
                          scale: 0.8,
                        ),
                        Text(
                          clima!['location']['name'],
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          clima!['current']['condition']['text'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          '${clima!['current']['temp_c'].round()}°C',
                          style: const TextStyle(
                            fontSize: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sensação: ${clima!['current']['feelslike_c'].round()}°C',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Umidade: ${clima!['current']['humidity']}%  |  Vento: ${clima!['current']['wind_dir']} ${clima!['current']['wind_kph']} km/h',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        // Text(
                        //   'Vento: ${clima!['current']['wind_dir']} ${clima!['current']['wind_kph']} km/h',
                        //   style: const TextStyle(
                        //     fontSize: 16,
                        //     color: Colors.white70,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Digite o nome da cidade',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    if (controller.text.trim().isNotEmpty) {
                      setState(() => cidade = controller.text.trim());
                      await buscarClima();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
