
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inkwiz/image_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            _pickImage(false, context);
          },
          child: Container(
            height: height * 0.75,
            width: width * 0.75,
            decoration: BoxDecoration(
                color: Colors.teal.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.teal.shade400,
                    width: 4.0,
                    strokeAlign: BorderSide.strokeAlignCenter)),
            child: const Center(
                child: Text(
              'Insert Image to Extract text',
              style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
            )),
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: true,
        child: NavigationBar(
          destinations: const [
            NavigationDestination(icon: Icon(Icons.photo), label: "Gallery"),
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Camera')
          ],
          onDestinationSelected: (index) async {
            if (index == 1) {
              _pickImage(true, context);
            }
          },
        ),
      ),
    );
  }

  _pickImage(bool isCam, context) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
        source: isCam ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ImagePage(image: image)));
    }
  }
}
