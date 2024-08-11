import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
//import 'package:pdf/widgets.dart' as pw; // For PDF parsing
//import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  //await dotenv.load(); 
  runApp(const MyApp());
   // Replace MyApp with your actual app widget
}

//Declaring Minimizable Heading Class
class MinimizableHeading extends StatefulWidget {
  final String title;
  final String content; // The content to display

  MinimizableHeading({required this.title, required this.content});

  @override
  _MinimizableHeadingState createState() => _MinimizableHeadingState();
}

class _MinimizableHeadingState extends State<MinimizableHeading> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
          // Notify MyAppState about the current heading
          if (_isExpanded) {
            Provider.of<MyAppState>(context, listen: false).setCurrentHeading(widget.title);
          }
        });
      },
      children: [
        if (_isExpanded) Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(widget.content),
        ),
      ],
    );
  }
}

//Change Notifier Class
class MyAppState extends ChangeNotifier {
  final List<bool> _isSelected = List.generate(5, (_) => false);
  String _userInput = ''; // New variable to store user input
  final Map<String, String> _results = {}; // Store results for each section
  double _progress=0.0;
  String _pdfContent = '';
  bool _isProcessing = false;
  bool _isLoading = false;  
   String? _currentHeading;
  String get pdfContent => _pdfContent;
  bool get isProcessing => _isProcessing;
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Notify the UI to rebuild
  }
  void setProcessing(bool value) {
    _isProcessing = value;
    if (!value) _progress = 0.0; // Reset progress when not processing
    notifyListeners();
  }
  //For Progress Bar
  void setProgress(double value) {
    _progress = value;
     
    notifyListeners();
  }
  //Store the Notes Type and Output in Map
  Map<String, String> results = {};

  void setResult(String noteType, String result) {
    results[noteType] = result;
    notifyListeners();
  }

  //For setting pdf content
  void setPdfContent(String content) {
    _pdfContent = content;
    notifyListeners(); // Notify listeners to update the UI
  }

 //For Minimizable Heading
  void toggleSelection(int index) {
    _isSelected[index] = !_isSelected[index];
    notifyListeners(); // Notify listeners of state changes
  }

  List<bool> get isSelected => _isSelected;
  String get userInput => _userInput; // Getter for user input

  void setUserInput(String input) {
    _userInput = input;
    notifyListeners(); // Notify listeners of user input change
  }
  //Getting Heading from Minimizable Heading
  void setCurrentHeading(String heading) {
    _currentHeading = heading;
    notifyListeners();
  }

  String get currentHeadingContent {
    return _results[_currentHeading] ?? '';
  }
}

//App Definition Class
class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyAppState>(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Wisp', // Custom title for browser tab
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.lightBlue[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.lightBlue[200],
          )
        ),
        home: const MyHomePage(),
      ),
    );
  }
}
  
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final model= 'gemini-1.5-pro';
  //Set the API key here
  final apiKey= '';
  //final apiKey = dotenv.env['API_KEY'];
  
  String enteredText="";
  String? response;
  final TextEditingController textController = TextEditingController(); 
  //final TextEditingController prompt_output = TextEditingController();
   //Reading the PDF file from Explorer and extracting the content.
   Future<void> pickPdfFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        final Uint8List? fileBytes = result.files.single.bytes;

        if (fileBytes != null) {
          String extractedText = await extractPdfText(fileBytes);
          Provider.of<MyAppState>(context, listen: false).setPdfContent(extractedText);
          textController.text = extractedText; // Display PDF content in text field
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected. Please try again.')),
      );
        
      }
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file. Please try again.')),
      );
    }
  }

  Future<String> extractPdfText(Uint8List fileBytes) async {
    //final appState = Provider.of<MyAppState>(context, listen: false);
    //appState.setProcessing(true);  // Start processing

    final PdfDocument document = PdfDocument(inputBytes: fileBytes);
    String extractedText = '';

    // Create a single PdfTextExtractor instance for the document
    final PdfTextExtractor textExtractor = PdfTextExtractor(document);

    for (int i = 0; i < document.pages.count; i++) {
      extractedText += textExtractor.extractText(startPageIndex: i, endPageIndex: i);
      extractedText += '\n\n'; // Add newlines between pages
    }

    document.dispose();
    return extractedText;
    }

    

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisp'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          children: [
              Expanded(
              child: Consumer<MyAppState>(
                builder: (context, myAppState, child) {
                  return ListView(
                    children: [
                      //Minimizable headings for all notes types
                      MinimizableHeading(
                        title: "Short Notes",
                        content: myAppState.results["Short Notes"] ?? "",
                      ),
                      MinimizableHeading(
                        title: "Highlighted Keywords",
                        content: myAppState.results["Highlighted Keywords"] ?? "",
                      ),
                      MinimizableHeading(
                        title: "Flash Cards",
                        content: myAppState.results["Flash Cards"] ?? "",
                      ),
                      MinimizableHeading(
                        title: "Summary",
                        content:  myAppState.results["Summary"] ?? "",
                      ),
                      MinimizableHeading(
                        title: "Study Guide",
                        content: myAppState.results["Study Guide"] ?? "",
                      ), 
                    ],
                  );
                },
              ),
            ),
            Consumer<MyAppState>(
                                builder: (context, myAppState, child) {
                                  if (myAppState._isLoading) {
                                    return Column(
                                      children: [
                                        const Text(
                                            'Content is being generated, please wait...',
                                            style: TextStyle(fontSize: 16.0, color: Colors.black),
                                            ),
                                          SizedBox(height: 8.0), // Space between text and progress bar
                                          SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.8, // Adjust the width as needed
                                          child: LinearProgressIndicator(
                                          value: myAppState._progress, // Progress value
                                          backgroundColor: Colors.grey[300], // Background color
                                          color: Colors.blueAccent, // Progress bar color
                                          minHeight: 10.0, // Increase the height of the progress bar
                                          ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Container(); // Return an empty container when not loading
                                      }
                                    },
                                  ),
              
                              Row(
                                children: [
                                    Expanded(
                                      child: Container(),
                                    ),
                                  const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        //Popup window for taking input
                        return AlertDialog(
                          title: const Text('Input your data'),
                          content: const Text(
                              'Choose a way to input your data to process here.'),
                          actions: [
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Text:'),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 1000.0, // Adjusted width
                                  child: TextField(
                                    controller: textController,
                                    maxLines: 3,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter the text...',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.lightBlueAccent,
                                            width: 1.0),
                                      ),
                                    ),
                                  ),
                                ), 
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await pickPdfFile(context);
                                    
                                  },
                                  child: const Text('Pick PDF'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10.0),
                            Row(
                              children: [
                                //Setting the values on clicking Generate Content
                                ElevatedButton(
                                  onPressed: () async {
                                    String enteredText = textController.text;
                                    Provider.of<MyAppState>(context, listen: false).setLoading(true); 
                                    
                                    List<String> notesTypes = [
                                      "Short Notes",
                                      "Highlighted Keywords",
                                      "Flash Cards",
                                      "Summary",
                                      "Study Guide"
                                    ];
                                                                     
                                    for (int i = 0; i < notesTypes.length; i++) {
                                      String notesType = notesTypes[i];
                                      String response = await callGenAI(notesType, enteredText);
                                      await Future.delayed(Duration(seconds: 45));
                                      Provider.of<MyAppState>(context, listen: false).setProgress((notesTypes.indexOf(notesType) + 1) / notesTypes.length);
                                      Provider.of<MyAppState>(context, listen: false).setResult(notesType, response);
                                    }
                                    
                                    Provider.of<MyAppState>(context, listen: false).setLoading(false); // Stop progress bar
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: const Text('Generate Notes'),
                                ),
                              ],
                            ),
                            
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Input Data'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    
  }

//Call Gemini API with the notes type and the text
Future callGenAI(String notes_type, String input) async {
    final appState = Provider.of<MyAppState>(context, listen: false);
    appState.setProcessing(true);  // Start processing
    try {
      final gen_model = GenerativeModel( model: model, apiKey: apiKey!);
      final prompt = 'Can you read and generate $notes_type from this content ? $input';
      final content = [Content.text(prompt)];
      final tokenCount = await gen_model.countTokens(content);
      final response = await gen_model.generateContent(content);
      if (response.text != null) {
        return response.text;
      } else {
        return 'error';
      }
    } 
   catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to generate content. $e. Please try again.')),
  );
  }
  finally{
    appState.setProcessing(false);
  
  }
}
    
}

