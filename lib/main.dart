import 'package:flutter/material.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TemperatureConverterScreen(),
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() =>
      _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState
    extends State<TemperatureConverterScreen> {
  // Controller for the temperature input field
  final TextEditingController _temperatureController = TextEditingController();

  // Enum to track conversion type
  ConversionType _conversionType = ConversionType.fahrenheitToCelsius;

  // List to store conversion history
  final List<ConversionRecord> _history = [];

  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _temperatureController.dispose();
    super.dispose();
  }

  // Convert the temperature based on selected conversion type
  void _convertTemperature() {
    if (!_formKey.currentState!.validate()) return;

    final inputTemp = double.parse(_temperatureController.text);
    double result;

    if (_conversionType == ConversionType.fahrenheitToCelsius) {
      result = (inputTemp - 32) * 5 / 9;
    } else {
      result = (inputTemp * 9 / 5) + 32;
    }

    // Add to history
    setState(() {
      _history.insert(
        0,
        ConversionRecord(
          inputTemp: inputTemp,
          outputTemp: result,
          type: _conversionType,
        ),
      );
    });

    // Show result in a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Converted ${inputTemp.toStringAsFixed(1)}° ${_conversionType == ConversionType.fahrenheitToCelsius ? 'F' : 'C'} to ${result.toStringAsFixed(2)}° ${_conversionType == ConversionType.fahrenheitToCelsius ? 'C' : 'F'}',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Conversion type selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RadioListTile<ConversionType>(
                            title: const Text('Fahrenheit to Celsius'),
                            value: ConversionType.fahrenheitToCelsius,
                            groupValue: _conversionType,
                            onChanged: (ConversionType? value) {
                              setState(() {
                                _conversionType = value!;
                              });
                            },
                          ),
                          RadioListTile<ConversionType>(
                            title: const Text('Celsius to Fahrenheit'),
                            value: ConversionType.celsiusToFahrenheit,
                            groupValue: _conversionType,
                            onChanged: (ConversionType? value) {
                              setState(() {
                                _conversionType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Temperature input form
                  Form(
                    key: _formKey,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _temperatureController,
                              decoration: InputDecoration(
                                labelText:
                                    'Enter temperature in ${_conversionType == ConversionType.fahrenheitToCelsius ? 'Fahrenheit' : 'Celsius'}',
                                border: const OutlineInputBorder(),
                                suffixText: _conversionType ==
                                        ConversionType.fahrenheitToCelsius
                                    ? '°F'
                                    : '°C',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a temperature';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _convertTemperature,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Convert'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Conversion history
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Conversion History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: orientation == Orientation.portrait
                                  ? 200
                                  : 150,
                            ),
                            child: _history.isEmpty
                                ? const Center(
                                    child: Text('No conversions yet'),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _history.length,
                                    itemBuilder: (context, index) {
                                      final record = _history[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          '${record.type == ConversionType.fahrenheitToCelsius ? 'F to C' : 'C to F'}: ${record.inputTemp.toStringAsFixed(1)} => ${record.outputTemp.toStringAsFixed(2)}',
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enum to represent conversion types
enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit,
}

// Class to represent a conversion record
class ConversionRecord {
  final double inputTemp;
  final double outputTemp;
  final ConversionType type;

  ConversionRecord({
    required this.inputTemp,
    required this.outputTemp,
    required this.type,
  });
}
