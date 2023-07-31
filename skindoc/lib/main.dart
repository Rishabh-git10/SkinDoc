import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:image/image.dart' as img;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Cancer Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Skin Cancer Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/images/friendly_health_logo.png',
              width: 500,
              height: 500), // Replace 'assets/logo.png' with your logo image
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SkinLesionScreen()),
            ),
            child: const Text('Check Skin Lesion'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PreventionTipsScreen()),
            ),
            child: const Text('Skin Cancer Tips'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => exit(0),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class SkinLesionScreen extends StatefulWidget {
  const SkinLesionScreen({super.key});

  @override
  _SkinLesionScreenState createState() => _SkinLesionScreenState();
}

class _SkinLesionScreenState extends State<SkinLesionScreen> {
  final picker = ImagePicker();
  File? _image;
  tfl.Interpreter? _interpreter;
  bool _skinCancerPositive = false;
  String? _predictedClassLabel;
  String? _predictedClassDescription;
  Float32List? _prediction;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  void loadModel() async {
    try {
      // Load the model from assets
      final interpreter =
          await tfl.Interpreter.fromAsset('assets/model.tflite');
      final interpreterOptions = tfl.InterpreterOptions();
      _interpreter = await tfl.Interpreter.fromAsset('assets/model.tflite');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(ImageSource img) async {
    final pickedFile = await picker.pickImage(source: img);
    XFile? xfilePick = pickedFile;
    setState(() {
      if (xfilePick != null) {
        _image = File(pickedFile!.path);

        // Process the image and make predictions
        final input = preprocessImage(_image!);
        final Float32List prediction = predict(input);

        final classLabels = {
          0: 'bkl',
          1: 'nv',
          2: 'df',
          3: 'mel',
          4: 'vasc',
          5: 'bcc',
          6: 'akiec'
        };
        // Find the class label with the highest probability using reduce.
        final int predictedClassIdx =
            prediction.indexOf(prediction.reduce((a, b) => a > b ? a : b));
        final String? predictedClassLabel = classLabels[predictedClassIdx];

        // Get the description of the predicted class
        final classDescriptions = {
          'bkl': 'Benign Keratosis-like Lesions',
          'nv': 'Melanocytic Nevi (Moles)',
          'df': 'Dermatofibroma',
          'mel': 'Melanoma',
          'vasc': 'Vascular Skin Lesions',
          'bcc': 'Basal Cell Carcinoma',
          'akiec': 'Actinic Keratoses and Intraepidermal Carcinoma'
        };
        final String? predictedClassDescription =
            classDescriptions[predictedClassLabel];

        // Check if skin cancer is positive or negative
        final bool skinCancerPositive =
            ['mel', 'vasc', 'bcc', 'akiec'].contains(predictedClassLabel);

        // Display the results
        print("Prediction: $predictedClassLabel");
        print("Description: $predictedClassDescription");
        print("Probabilities: $prediction");
        print("Skin cancer positive: $skinCancerPositive");

        setState(() {
          _predictedClassLabel = predictedClassLabel;
          _predictedClassDescription = predictedClassDescription;
          _prediction = prediction;
          _skinCancerPositive = skinCancerPositive;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }
    });
  }

  Uint8List preprocessImage(File file) {
    final img.Image inputImage = img.decodeImage(file.readAsBytesSync())!;
    final img.Image resizedImage =
        img.copyResize(inputImage, width: 224, height: 224);

    final Float32List input = Float32List(224 * 224 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final img.Color pixel = resizedImage.getPixel(x, y);
        final num alpha = pixel.a;
        final num red = pixel.r;
        final num green = pixel.g;
        final num blue = pixel.b;
        input[pixelIndex] = (red - 127.5) / 127.5;
        input[pixelIndex + 1] = (green - 127.5) / 127.5;
        input[pixelIndex + 2] = (blue - 127.5) / 127.5;
        pixelIndex += 3;
      }
    }

    return input.buffer.asUint8List();
  }

  Float32List predict(Uint8List input) {
    if (_interpreter == null) {
      throw Exception('Model not loaded yet.');
    }

    final output = List<List<double>>.filled(1, List<double>.filled(7, 0.0));
    _interpreter!.run(input, output);

    // Extract the first (and only) element of the 2D list, then convert it to a Float32List
    final List<double> probabilities = output[0];
    final Float32List result = Float32List.fromList(probabilities);

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Check Skin Lesion"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _showPicker(context: context);
            },
            child: const Text('Upload a picture'),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200.0,
            width: 300.0,
            child: _image == null
                ? const Center(child: Text('Sorry nothing selected!!'))
                : Stack(
                    children: [
                      Image.file(_image!),
                      if (_prediction != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: _skinCancerPositive
                                ? Colors.red.withOpacity(0.7)
                                : Colors.green.withOpacity(0.7),
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Prediction: $_predictedClassLabel\nDescription: $_predictedClassDescription\nSkin cancer positive: $_skinCancerPositive",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class PreventionTipsScreen extends StatefulWidget {
  const PreventionTipsScreen({super.key});

  @override
  _PreventionTipsScreenState createState() => _PreventionTipsScreenState();
}

class _PreventionTipsScreenState extends State<PreventionTipsScreen> {
  String _tip = '';

  @override
  void initState() {
    super.initState();
    _getRandomTip();
  }

  void _getRandomTip() async {
    // Get random skin cancer prevention tips
    // Hard coded for now
    var tips = [
      'GET ROUTINE SKIN EXAMS',
      'USE SUNSCREENS SPF 30 OR GREATER (BROAD SPECTRUM)',
      'WEAR SUN PROTECTIVE CLOTHING',
      'AVOID THE SUN AND TANNING BEDS',
      'USE ANTIOXIDANT SERUMS'
    ];

    // Choose a random tip
    var random = Random();
    var tip = tips[random.nextInt(tips.length)];

    setState(() {
      _tip = tip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Cancer Prevention Tips'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          _tip,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
