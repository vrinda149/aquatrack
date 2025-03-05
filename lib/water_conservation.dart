import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WaterConservationPage extends StatefulWidget {
  const WaterConservationPage({Key? key}) : super(key: key);

  @override
  _WaterConservationPageState createState() => _WaterConservationPageState();
}

class _WaterConservationPageState extends State<WaterConservationPage> {
  final List<Map<String, String>> _waterSavingTips = [
    {
      'title': 'Fix Leaky Faucets',
      'description':
          'A single dripping faucet can waste up to 3,000 gallons per year. Regularly check and repair leaks.',
      'icon': '💧'
    },
    {
      'title': 'Short Showers',
      'description':
          'Reduce shower time to 5 minutes. Each minute saved can conserve up to 2.1 gallons of water.',
      'icon': '🚿'
    },
    {
      'title': 'Full Loads Only',
      'description':
          'Run dishwashers and washing machines only when fully loaded to maximize water efficiency.',
      'icon': '🧼'
    },
    {
      'title': 'Collect Rainwater',
      'description':
          'Use rainwater for gardening and outdoor cleaning. Install rain barrels to capture runoff.',
      'icon': '🌧️'
    },
    {
      'title': 'Smart Irrigation',
      'description':
          'Water plants early morning or late evening. Use drip irrigation to minimize water waste.',
      'icon': '🌱'
    },
  ];

  final List<Map<String, dynamic>> _waterFactCards = [
    {
      'title': 'Global Water Crisis',
      'fact': 'Over 2 billion people lack access to safe drinking water.',
      'color': Colors.blue.shade100,
      'icon': Icons.water,
    },
    {
      'title': 'Household Usage',
      'fact':
          'An average family wastes 180 gallons per week from household leaks.',
      'color': Colors.green.shade100,
      'icon': Icons.house,
    },
    {
      'title': 'Agricultural Impact',
      'fact': 'Agriculture consumes 70% of global freshwater resources.',
      'color': Colors.orange.shade100,
      'icon': Icons.agriculture,
    },
  ];

  final _emailController = TextEditingController();
  final _suggestionController = TextEditingController();

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _submitSuggestion() {
    if (_emailController.text.isNotEmpty &&
        _suggestionController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You!'),
          content:
              const Text('Your suggestion has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Reset fields
      _emailController.clear();
      _suggestionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Conservation Insights'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Water Saving Tips Section
          _buildSectionTitle('Water Saving Tips'),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _waterSavingTips.length,
              itemBuilder: (context, index) {
                final tip = _waterSavingTips[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['icon']!,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tip['title']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(tip['description']!),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Water Facts Section
          _buildSectionTitle('Water Facts'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _waterFactCards.length,
            itemBuilder: (context, index) {
              final fact = _waterFactCards[index];
              return Card(
                color: fact['color'],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(fact['icon'], size: 50, color: Colors.blue.shade700),
                      const SizedBox(height: 10),
                      Text(
                        fact['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fact['fact'],
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Useful Resources Section
          _buildSectionTitle('Useful Resources'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _launchURL('https://www.epa.gov/waterdata'),
                icon: const Icon(Icons.public),
                label: const Text('EPA Water Data'),
              ),
              ElevatedButton.icon(
                onPressed: () => _launchURL(
                    'https://www.who.int/health-topics/water-sanitation-and-hygiene'),
                icon: const Icon(Icons.water_drop),
                label: const Text('WHO Water Resources'),
              ),
            ],
          ),

          // Suggestion Submission Section
          _buildSectionTitle('Share Your Ideas'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Your Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _suggestionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Water Conservation Suggestion',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitSuggestion,
                    child: const Text('Submit Suggestion'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }
}
