import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({
    super.key,
    required this.image,
  });
  final XFile image;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  HeadlessInAppWebView? headlessWebView;
  bool isLoading = false;
  TextEditingController tController = TextEditingController();
  @override
  void initState() {
    _postApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(child: Image.file(File(widget.image.path))),
            Positioned(
              top: MediaQuery.of(context).size.width * 0.04,
              left: MediaQuery.of(context).size.width * 0.04,
              child: Container(
                height: 45.0,
                width: 45.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 0),
                      blurRadius: 0.0,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    await headlessWebView
                        ?.dispose()
                        .then((value) => Navigator.pop(context));
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.width * 0.2,
              left: !isLoading
                  ? MediaQuery.of(context).size.width * 0.45
                  : MediaQuery.of(context).size.width * 0.25,
              child: !isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          fixedSize: const Size(190.0, 70.0)),
                      onPressed: () async {
                        try {
                          if (headlessWebView?.isRunning() ?? false) {
                            await headlessWebView?.webViewController
                                .evaluateJavascript(source: """
func = async () => {

    const firstElement = document.getElementById('ucj-2');

    if (!firstElement) {
      return;
    }

    firstElement.click();

     let i=0;
    let secondElements = null;
    while (!secondElements) {
      secondElements = document.querySelector('button[jscontroller="soHxf"][data-idom-class="nCP5yc AjY5Oe DuMIQc LQeN7 kCfKMb"]');
      await new Promise(resolve => setTimeout(resolve, 100));
      i++;
      if(i==20){
        console.log("jamal"+"No text Found");
      }
    }

    if (secondElements) {
      secondElements.click();
    } else {
      return;
    }

    let thirdElement = null;
    while (!thirdElement) {
      thirdElement = document.querySelector('h1.wCgoWb');
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    console.log("badiul"+thirdElement.innerText);
  };
func();

""");
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.wand_rays_inverse),
                          Text(
                            '    Extract Text',
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ],
                      )),
            )
          ],
        ),
      ),
    );
  }

  _postApiCall() async {
    String? picLink;
    var url = Uri.parse(
        'https://tmpfiles.org/api/v1/upload'); // Replace with your API endpoint
    var request = http.MultipartRequest('POST', url);

    // Add the file to the request
    var file = await http.MultipartFile.fromPath('file', widget.image.path);
    request.files.add(file);

    // Send the request
    try {
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        var responseBody = await http.Response.fromStream(response)
            .then((value) => value.body);
        var res = jsonDecode(responseBody);
        picLink = (res['data']['url'].toString().replaceFirst('org', 'org/dl'));
      }
    } catch (error) {
      debugPrint('Error uploading file: $error');
    }

    if (picLink != null && picLink != "") {
      headlessWebView = HeadlessInAppWebView(
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
                userAgent:
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3')),
        initialUrlRequest: URLRequest(
            url: Uri.parse("https://lens.google.com/uploadbyurl?url=$picLink")),
        onConsoleMessage: (controller, consoleMessage) {
          if (consoleMessage.message.startsWith('badiul')) {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 50, right: 20.0, left: 20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Recognized Text',
                            style: TextStyle(
                                fontSize: 24.0, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 20.0),
                          Center(
                              child: SelectableText(
                            consoleMessage.message.replaceFirst('badiul', ''),
                            maxLines: null,
                            style: const TextStyle(color: Colors.black),
                          )),
                        ],
                      ),
                    ),
                  );
                });
          }
          if (consoleMessage.message.startsWith('jamal')) {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SizedBox(
                    height: 300,
                    child: Center(
                        child: Text(
                            consoleMessage.message.replaceFirst('jamal', ''))),
                  );
                });
          }
        },
      );
      await headlessWebView?.dispose();
      await headlessWebView?.run().then((value) => setState(() {
            isLoading = true;
          }));
      picLink = "";
    }
  }
  
}
