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
        child: Container(
          color: Colors.pink[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Column(
                  children: [
                    Icon(Icons.rocket_launch, size: 48.0, color: Colors.pink),
                    Text('Mars Rovers', style: TextStyle(fontSize: 24)),
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
      ),
      body: Column(
        children: [
          ManifestDetails(manifestData: manifestData),
          Expanded(
            child: manifestData.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var photo in manifestData['photos']) ...[
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoGalleryPage(
                            rover: currentRover,
                            sol: photo['sol'],
                            totalImage: photo['total_photos'],
                            apiKey: 'EazAnfX134mZ6E2cgAVQRcXpQU75l4W5eNAJVBJZ',
                          )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 18, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Sol ${photo['sol']}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                    ),
                                    TextSpan(
                                      text: ' on ${photo['earth_date']}',
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${photo['total_photos']}',
                                style: TextStyle(fontSize: 18, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                    ]
                  ],
                ),
              ),
          ),
        ],
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
      width: double.infinity, 
      color: Colors.pink[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${manifestData['name']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
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
          SizedBox(height: 20),
        ],
      ),
    )
    );
  }
}


