import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Extraction Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Extraction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _extractAllText,
              child: const Text(
                'Extract all text',
                style: TextStyle(color: Colors.white),
              ),
             
            ),
            ElevatedButton(
              onPressed: _extractTextWithBounds,
              child: const Text(
                'Extract text with predefined bounds',
                style: TextStyle(color: Colors.white),
              ),
              
            ),
            ElevatedButton(
              onPressed: _extractTextFromSpecificPage,
              child: const Text(
                'Extract text from a specific page',
                style: TextStyle(color: Colors.white),
              ),
              
            ),
            ElevatedButton(
              onPressed: _extractTextFromRangeOfPage,
              child: const Text(
                'Extract text from a range of pages',
                style: TextStyle(color: Colors.white),
              ),
              
            ),
            ElevatedButton(
              onPressed: _extractTextWithFontAndStyleInformation,
              child: const Text(
                'Extract text with font and style information',
                style: TextStyle(color: Colors.white),
              ),
              
            ),
            ElevatedButton(
              onPressed: _generatePDF,
              child: Text('Generate PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _extractAllText() async {
    //Load the existing PDF document.
    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));


    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the document.
    String text = extractor.extractText();

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextWithBounds() async {
    //Load the existing PDF document.
    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData('invoice.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the particular page.
    List<TextLine> result = extractor.extractTextLines(startPageIndex: 0);

    //Predefined bound.
    Rect textBounds = const Rect.fromLTWH(200, 300, 500, 400);

    String invoiceNumber = '';

    for (int i = 0; i < result.length; i++) {
      List<TextWord> wordCollection = result[i].wordCollection;
      for (int j = 0; j < wordCollection.length; j++) {
        if (textBounds.overlaps(wordCollection[j].bounds)) {
          invoiceNumber = wordCollection[j].text;
          _showResult(invoiceNumber);
          break;
        }
      }
      // if (invoiceNumber != '') {
      //   break;
      // }
    }

    //Display the text.

  }

  Future<void> _extractTextFromSpecificPage() async {
    //Load the existing PDF document.
    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));


    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the first page of the PDF document.
    String text = extractor.extractText(startPageIndex: 2);

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextFromRangeOfPage() async {
    //Load the existing PDF document.
    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Extract all the text from the first page to 3rd page of the PDF document.
    String text = extractor.extractText(startPageIndex: 0, endPageIndex: 2);

    //Display the text.
    _showResult(text);
  }

  Future<void> _extractTextWithFontAndStyleInformation() async {
    //Load the existing PDF document.
    PdfDocument document = PdfDocument(inputBytes: await _readDocumentData('invoice.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);
    //Extract all the text from specific page.
    List<TextLine> result = extractor.extractTextLines(startPageIndex: 0);

    //Draw rectangle..
    for (int i = 0; i < result.length; i++) {
      List<TextWord> wordCollection = result[i].wordCollection;
      for (int j = 0; j < wordCollection.length; j++) {
        // if ('2058557939' == wordCollection[j].text) {
          //Get the font name.
          String fontName = wordCollection[j].fontName;
          //Get the font size.
          double fontSize = wordCollection[j].fontSize;
          //Get the font style.
          List<PdfFontStyle> fontStyle = wordCollection[j].fontStyle;
          //Get the text.
          String text = wordCollection[j].text;
          String fontStyleText = '';
          for (int i = 0; i < fontStyle.length; i++) {
            fontStyleText += fontStyle[i].toString() + ' ';
          }
          fontStyleText = fontStyleText.replaceAll('PdfFontStyle.', '');
          _showResult(
              'Text : $text \r\n Font Name: $fontName \r\n Font Size: $fontSize \r\n Font Style: $fontStyleText');
          break;
        // }
      }
    }
    //Dispose the document.
    document.dispose();
  }

  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  void _showResult(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Extracted text'),
            content: Scrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Text(text),
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
  Future<void> _generatePDF() async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();


    // Add a page to the document.
    final PdfPage page = document.pages.add();

    // Draw text on the PDF page.
    page.graphics.drawString(
      'Hello World!',
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: const Rect.fromLTWH(0, 0, 150, 20),
    );


    final directory = await getApplicationDocumentsDirectory();

    final outputFile = File('${directory.path}/output.pdf');

    await outputFile.writeAsBytes(await document.save());

    // Dispose the document.
    document.dispose();
    final extractedText = await _extractTextFromPdf(outputFile);

    // Show the extracted text in the _showResult dialog.
    _showResult(extractedText);

    // Show a dialog to indicate success.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PDF Generated'),
          content: Text('The PDF has been generated and saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<String> _extractTextFromPdf(File pdfFile) async {
    // Load the PDF document.
    final PdfDocument document = PdfDocument(inputBytes: pdfFile.readAsBytesSync());

    // Extract the text from the document.
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final String text = extractor.extractText();

    // Dispose the document.
    document.dispose();

    return text;
  }

}
