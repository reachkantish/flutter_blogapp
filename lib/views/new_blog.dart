import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutterblogapp/services/crud.dart';
import 'package:random_string/random_string.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class NewBlog extends StatefulWidget {
  @override
  _NewBlogState createState() => _NewBlogState();
}

class _NewBlogState extends State<NewBlog> {
  String authName = "", title = "", desc = "";

  File selectedImage;

  CrudMethods crudMethods = new CrudMethods();

  bool _loading = false;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  updateBlog() async {
    if (selectedImage != null) {
      setState(() {
        _loading = true;
      });

      // uploading image to firebase storage
      StorageReference blogImagesStoreageReference = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(10)}.jpg");

      final StorageUploadTask task =
          blogImagesStoreageReference.putFile(selectedImage);

      var downloadUrl = await (await task.onComplete).ref.getDownloadURL();

      print("$downloadUrl");

      Map<String, String> blog = {
        "authName": authName,
        "desc": desc,
        "imgUrl": downloadUrl,
        "title": title
      };

      crudMethods.addData(blog);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Anaka "),
            Text(
              "Travel Blog",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              updateBlog();
              setState(() {});
            },
            child: Container(
                padding: EdgeInsets.only(
                  right: 16,
                ),
                child: Icon(
                  Icons.file_upload,
                  color: Colors.white,
                )),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.symmetric(vertical: 24),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: <Widget>[
                      selectedImage == null
                          ? GestureDetector(
                              onTap: () {
                                getImage();
                              },
                              child: Container(
                                height: 150.0,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    (4),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(selectedImage,
                                    fit: BoxFit.cover),
                              ),
                            ),
                      SizedBox(
                        height: 8,
                      ),
                      TextField(
                        onChanged: (val) {
                          authName = val;
                        },
                        decoration: InputDecoration(hintText: "Author Name"),
                      ),
                      TextField(
                        onChanged: (val) {
                          title = val;
                        },
                        decoration: InputDecoration(hintText: "Title"),
                      ),
                      TextField(
                        onChanged: (val) {
                          desc = val;
                        },
                        decoration: InputDecoration(hintText: "Desc"),
                      ),
                    ],
                  )),
            ),
    );
  }
}
