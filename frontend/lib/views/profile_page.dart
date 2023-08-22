import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/models/user.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile Page'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            children: [
              // Details Tab
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: _pickImage, // Picking image from gallery
                        child: ClipOval(
                          child: _imageFile == null
                              ? (widget.user.avatarUrl.isEmpty
                                  ? Icon(Icons.person,
                                      size: 150) // Default Icon
                                  : Image.network(
                                      widget.user.avatarUrl,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ))
                              : Image.file(
                                  File(_imageFile!.path),
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('${widget.user.firstName} ${widget.user.lastName}',
                          style: Theme.of(context).textTheme.headline5),
                      SizedBox(height: 16.0),
                      Text('@${widget.user.username}#${widget.user.id}',
                          style: Theme.of(context).textTheme.subtitle1),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
              // Contact Tab
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${widget.user.email}',
                          style: Theme.of(context).textTheme.subtitle1),
                      SizedBox(height: 16.0),
                      Text('Phone: +${widget.user.phoneNumber}',
                          style: Theme.of(context).textTheme.subtitle1),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
