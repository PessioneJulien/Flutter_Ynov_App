import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotoGalleryPage extends StatefulWidget {
  final String rover;
  final int sol;
  final String apiKey;
  final int totalImage;

  PhotoGalleryPage({required this.rover, required this.sol, required this.apiKey, required this.totalImage});

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  List<dynamic> photos = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    setState(() {
      isLoading = true; // Start loading
    });

    final url = Uri.parse(
        'https://api.nasa.gov/mars-photos/api/v1/rovers/${widget
            .rover}/photos?sol=${widget.sol}&page=$currentPage&api_key=${widget
            .apiKey}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // print in the console the response body
      if (kDebugMode) {
        print(json.decode(response.body)["photos"][0]['img_src']);
      }
      setState(() {
        photos = json.decode(response.body)['photos'];
        isLoading = false; // End loading
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void nextPage() {
    if (!isLoading) { // Prevent multiple requests at the same time
      setState(() {
        currentPage++;
        fetchPhotos();
      });
    }
  }

  void previousPage() {
    if (currentPage > 1 && !isLoading) {
      setState(() {
        currentPage--;
        fetchPhotos();
      });
    }
  }

  String modulo25RoundUp(int n){
    if (n % 25 == 0) {
      return n.toString();
    } else {
      return (n +1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rover ${widget.rover} Photos Sol ${widget.sol}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Text('Page $currentPage / ' + modulo25RoundUp(widget.totalImage), style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: photos.isEmpty
                ? Center(child: Text('No photos available for this Sol.'))
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.network(
                      photos[index]['img_src'],
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Center(child: Text('Error loading image.'));
                      },
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        color: Colors.black54,
                        child: Text(
                          photos[index]['camera']['name'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: previousPage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Précédent', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: nextPage,
              style: TextButton.styleFrom(
                backgroundColor: Colors.pink[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Suivant', style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}