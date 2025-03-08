import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class WaterConservationPage extends StatefulWidget {
  const WaterConservationPage({super.key});

  @override
  State<WaterConservationPage> createState() => _WaterConservationPageState();
}

class _WaterConservationPageState extends State<WaterConservationPage> {
  // Water conservation tips by category
  final Map<String, List<Map<String, String>>> _waterSavingTipsByCategory = {
    'General Water Conservation Tips': [
      {
        'title': 'Track Your Usage',
        'description':
            'Monitor your daily and monthly water consumption trends through the app and set personal goals.',
        'icon': '📊'
      },
      {
        'title': 'Fix Leaks Immediately',
        'description':
            'Even a small leak can waste thousands of liters of water annually.',
        'icon': '🔧'
      },
      {
        'title': 'Water-Efficient Fixtures',
        'description':
            'Install low-flow faucets, showerheads, and dual-flush toilets to reduce consumption.',
        'icon': '🚿'
      },
      {
        'title': 'Collect & Reuse Water',
        'description':
            'Capture rainwater or reuse RO wastewater for cleaning or gardening.',
        'icon': '🌧️'
      },
      {
        'title': 'Avoid Overwatering Plants',
        'description':
            'Water your plants early in the morning or late in the evening to reduce evaporation.',
        'icon': '🌱'
      },
    ],
    'In the Bathroom': [
      {
        'title': 'Turn Off Tap While Brushing',
        'description': 'Save up to 15 liters of water per minute.',
        'icon': '🪥'
      },
      {
        'title': 'Shorter Showers',
        'description':
            'Reduce your shower time by 2 minutes to save 20-40 liters per shower.',
        'icon': '🚿'
      },
      {
        'title': 'Use a Bucket Instead',
        'description':
            'Save 40-50 liters per bath by using a bucket instead of a shower.',
        'icon': '🪣'
      },
      {
        'title': 'Check Toilet for Leaks',
        'description':
            'Put food coloring in the tank; if it seeps into the bowl without flushing, fix it.',
        'icon': '🚽'
      },
      {
        'title': 'Flush Only When Necessary',
        'description': 'Avoid using the toilet as a trash can.',
        'icon': '🚮'
      },
    ],
    'In the Kitchen': [
      {
        'title': 'Run Full Dishwasher Loads',
        'description': 'Avoid running half-loads to maximize efficiency.',
        'icon': '🍽️'
      },
      {
        'title': 'Scrape, Don\'t Rinse',
        'description':
            'Wipe off food scraps before washing dishes instead of using running water.',
        'icon': '🧼'
      },
      {
        'title': 'Use a Bowl for Washing Produce',
        'description':
            'Instead of rinsing under a tap, wash fruits & veggies in a bowl.',
        'icon': '🥣'
      },
      {
        'title': 'Reuse Cooking Water',
        'description':
            'Water used for boiling veggies or pasta can be used for soups or watering plants.',
        'icon': '♻️'
      },
      {
        'title': 'Fix Dripping Faucets',
        'description': 'A dripping faucet can waste up to 20 liters per day.',
        'icon': '💧'
      },
    ],
    'Laundry & Cleaning': [
      {
        'title': 'Run Full Loads in Washing Machines',
        'description': 'A full load optimizes water and energy usage.',
        'icon': '👕'
      },
      {
        'title': 'Water-Efficient Detergents',
        'description': 'Some detergents require less water for rinsing.',
        'icon': '🧴'
      },
      {
        'title': 'Reuse Laundry Water',
        'description': 'Use greywater for mopping floors or flushing.',
        'icon': '🧹'
      },
      {
        'title': 'Skip Extra Rinses',
        'description':
            'Modern washing machines don\'t need multiple rinse cycles.',
        'icon': '🧺'
      },
      {
        'title': 'Use a Broom Instead of a Hose',
        'description':
            'Sweep driveways & sidewalks instead of hosing them down.',
        'icon': '🧹'
      },
    ],
    'Outdoor & Garden Use': [
      {
        'title': 'Water Plants Wisely',
        'description': 'Use drip irrigation or water early morning/evening.',
        'icon': '💦'
      },
      {
        'title': 'Use Native Plants',
        'description': 'They require less water and maintenance.',
        'icon': '🌿'
      },
      {
        'title': 'Mulch Your Garden',
        'description': 'Reduces evaporation and keeps soil moist longer.',
        'icon': '🌱'
      },
      {
        'title': 'Cover Pools When Not in Use',
        'description': 'Prevents evaporation and reduces refill needs.',
        'icon': '🏊'
      },
      {
        'title': 'Use a Rain Barrel',
        'description': 'Collect rainwater for gardening & cleaning.',
        'icon': '🛢️'
      },
    ],
  };

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
          // Water Conservation Tips by Category
          ..._waterSavingTipsByCategory.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(entry.key),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final tip = entry.value[index];
                      return Card(
                        margin:
                            const EdgeInsets.only(right: 12.0, bottom: 12.0),
                        child: Container(
                          width: 250,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  tip['description']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),

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
              ElevatedButton.icon(
                onPressed: () => _launchURL('https://www.unwater.org/'),
                icon: const Icon(Icons.public),
                label: const Text('UN Water'),
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
