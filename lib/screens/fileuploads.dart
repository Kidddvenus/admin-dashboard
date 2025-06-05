//LOL all I needed to do for this to work was to upgrade flutter
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<String> _imageUrls = [];
  List<String> _filteredImages = [];
  final supabaseClient = supabase.Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();
  String _searchQuery = '';

  Future<void> uploadImage(File? image, String? webFileName, Uint8List? webBytes) async {
    final fileName = webFileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    try {
      if (webBytes != null) {
        final dioFile = dio.MultipartFile.fromBytes(webBytes, filename: fileName);
        await supabaseClient.storage.from('mediafiles').uploadBinary(fileName, webBytes);
      } else if (image != null) {
        await supabaseClient.storage.from('mediafiles').upload(fileName, image);
      }
      fetchImages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  Future<void> fetchImages() async {
    try {
      final response = await supabaseClient.storage.from('mediafiles').list();
      setState(() {
        _imageUrls = response.map((file) {
          return supabaseClient.storage.from('mediafiles').getPublicUrl(file.name);
        }).toList();
        _filteredImages = List.from(_imageUrls); // Initialize filtered images
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching images: $e')),
      );
    }
  }

  Future<void> deleteImage(String fileName) async {
    try {
      await supabaseClient.storage.from('mediafiles').remove([fileName]);
      fetchImages();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: $e')),
      );
    }
  }

  void confirmDelete(String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Delete Image', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete this image?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteImage(fileName);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(imageUrls: _filteredImages, initialIndex: index),
      ),
    );
  }

  Future<void> downloadImage(String imageUrl) async {
    try {
      final response = await dio.Dio().get(
        imageUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      final directory = await getApplicationDocumentsDirectory();
      final fileName = Uri.parse(imageUrl).pathSegments.last;
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.data);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check out this image!',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Image Gallery'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  _filteredImages = _imageUrls.where((imageUrl) {
                    final fileName = Uri.parse(imageUrl).pathSegments.last.toLowerCase();
                    return fileName.contains(_searchQuery);
                  }).toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by name...',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white70),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _filteredImages.isEmpty
                ? Center(child: Text('No Images Found', style: TextStyle(color: Colors.white)))
                : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = (constraints.maxWidth ~/ 200).clamp(2, 6);
                return GridView.builder(
                  padding: EdgeInsets.all(defaultPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: defaultPadding,
                    mainAxisSpacing: defaultPadding,
                    childAspectRatio: 1,
                  ),
                  itemCount: _filteredImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = _filteredImages[index];
                    final fileName = Uri.parse(imageUrl).pathSegments.last;
                    return Card(
                      child: GestureDetector(
                        onTap: () => showFullScreenImage(index),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(imageUrl, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Text(
                                fileName,
                                style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.share, color: Colors.green),
                                    onPressed: () => downloadImage(imageUrl),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => confirmDelete(fileName),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            File imageFile = File(pickedFile.path);
            await uploadImage(imageFile, null, null);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Image Viewer'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: bgColor),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}