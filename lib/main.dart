import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'photo_gallery_page.dart'; // Import the new photo gallery page

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MarsRoverManifest(),
  ));
}

class MarsRoverManifest extends StatefulWidget {
  @override
  _MarsRoverManifestState createState() => _MarsRoverManifestState();
}

class _MarsRoverManifestState extends State<MarsRoverManifest> {
  String currentRover = 'curiosity';
  Map<String, dynamic> manifestData = {};

  @override
  void initState() {
    super.initState();
    fetchManifest();
  }

  Future<void> fetchManifest() async {
    final apiKey = 'EazAnfX134mZ6E2cgAVQRcXpQU75l4W5eNAJVBJZ'; // Replace with your actual NASA API key
    final url = Uri.parse(
        'https://api.nasa.gov/mars-photos/api/v1/manifests/$currentRover?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        manifestData = json.decode(response.body)['photo_manifest'];
        //manifestData = json.decode(response.body)['photo_manifest'][0].img_src;
      });
    } else {
      throw Exception('Failed to load manifest');
    }
  }

  void switchRover(String rover) {
    setState(() {
      currentRover = rover;
      fetchManifest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mars Rover Manifest'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch, size: 72.0, color: Colors.white),
                  Text('Choose Rover',
                      style: TextStyle(color: Colors.white, fontSize: 24)),
                ],
              ),
            ),
            ListTile(
              title: Text('Curiosity'),
              onTap: () => switchRover('curiosity'),
            ),
            ListTile(
              title: Text('Spirit'),
              onTap: () => switchRover('spirit'),
            ),
            ListTile(
              title: Text('Opportunity'),
              onTap: () => switchRover('opportunity'),
            ),
          ],
        ),
      ),
      body: manifestData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ManifestDetails(manifestData: manifestData),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Column(
                    children: List.generate(manifestData['photos'].length, (index) {
                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PhotoGalleryPage(
                                  rover: currentRover,
                                  sol: manifestData['photos'][index]['sol'],
                                  totalImage : manifestData['photos'][index]['total_photos'],
                                  apiKey: 'EazAnfX134mZ6E2cgAVQRcXpQU75l4W5eNAJVBJZ',  // Use your actual API key here
                                )),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: 18, color: Colors.black), // Default text style
                                      children: [
                                        TextSpan(
                                          text: 'Sol ${manifestData['photos'][index]['sol']}',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue), // Sol and sol number are bold and blue
                                        ),
                                        TextSpan(
                                          text: ' on ${manifestData['photos'][index]['earth_date']}',
                                          // 'on' and the date are normal weight and black
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${manifestData['photos'][index]['total_photos']}',
                                    style: TextStyle(fontSize: 18, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < manifestData['photos'].length - 1) Divider(), // Adds a divider between each row, except after the last one
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManifestDetails extends StatelessWidget {
  final dynamic manifestData;

  const ManifestDetails({Key? key, required this.manifestData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
    child: Container(
      width: double.infinity,  // Sets the container width to 100% of the screen width
      color: Colors.pink[50],  // Updated to a light pink background as seen in the screenshot
      padding: const EdgeInsets.all(16.0),  // Increased padding for more space around the text
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${manifestData['name']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          // Each line is now a Row with MainAxisAlignment.spaceBetween
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('landing date:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['landing_date']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Launch date:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['launch_date']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mission status:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['status']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max sol:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['max_sol']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Max date:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['max_date']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total photos:', style: TextStyle(fontSize: 18, color: Colors.black)),
              Text('${manifestData['total_photos']}', style: TextStyle(fontSize: 18, color: Colors.black)),
            ],
          ),
          SizedBox(height: 20), // Used for spacing between the last text component and any following content
        ],
      ),
    )
    );
  }
}


