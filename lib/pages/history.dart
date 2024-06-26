
import 'dart:convert';

import 'package:exam/pages/home_page.dart';
import 'package:exam/pages/recipedetail.dart';
import 'package:exam/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class History extends StatefulWidget {
  final String token; // Add token parameter to the constructor
  final id;


  const History({Key? key,required this.token,this.id }) : super(key: key);


  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<String> generatedTexts = [];
  List<String> messageId = [];

  String email ='';
  String password='';
  String token='';

  get data => null;

  @override

  Future<void> fetchData() async {
    try {
      final Uri uri = Uri.parse('http://localhost:3000/recipelistapi/getdatahistory/${widget.id}');
      final response = await http.get(
        uri,
        headers: <String, String>{
          'Authorization': 'Bearer $token',

        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          generatedTexts =
          List<String>.from(data.map((item) => item['message'].toString()));
          messageId =
          List<String>.from(data.map((item) => item['_id'].toString()));
        });
        print("generatedTexts");
        print(generatedTexts);
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? ''; // Initialize with default value
      password = prefs.getString('password') ?? ''; // Initialize with default value
    });
  }
  void initState() {
    super.initState();
    fetchData();
    getData();

  }
  Future<void> deleteItem(String id) async {
    try {
      final Uri uri = Uri.parse('http://localhost:3000/recipelistapi/deletedatahistory/$id');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        setState(() {
          generatedTexts.removeWhere((text) => text == id);
        });
        print('Data deleted successfully');
      } else if (response.statusCode == 404) {
        print('Data not found');
      } else {
        print('Failed to delete data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting data: $error');
    }
  }
  Future<void> refreshData() async {
    // Call the fetchData method to refresh the data
    await fetchData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeHome()),
            );          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(token: token, userId: data['id'])),
              );
              // Perform search action
            },
          ),
        ],
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Email: ${email != null ? email : ""}',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              Text(
                'Password: ${password != null ? password : ""}',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              Text(
                'token: ${token != null ? token : ""}',
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),

            ],
          ),
        ),
      ),


      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CarouselSlider(
                options: CarouselOptions(
                  aspectRatio: MediaQuery.of(context).size.width /
                      MediaQuery.of(context).size.height,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                ),
                items: [
                  // Replace these containers with network images
                  NetworkImage(
                    'https://images.unsplash.com/photo-1493808997710-b9681bc18443?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                  NetworkImage(
                    'https://images.unsplash.com/photo-1493808997710-b9681bc18443?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),

                ].map((imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Displaying text in separate containers
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 50,
                mainAxisSpacing: 50,
                childAspectRatio: 1, // Aspect ratio of the items
              ),
              itemCount: generatedTexts.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => recipedetail(content: generatedTexts[index])),
                    );
                    // Handle item tap if needed
                    // Handle item tap if needed
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width:200,
                    height:100
                    ,
                    // Adjust width
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   generatedTexts[index],
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     color: Colors.white, // Change the text color here
                          //   ),
                          // ),
                          Text(
                            generatedTexts[index],
                            style: GoogleFonts.lobster(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              String id = messageId[index];
                              await deleteItem(id);
                              setState(() {
                                generatedTexts.removeAt(index);
                                messageId.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),



          ],
        ),
      ),
    );
  }
}
