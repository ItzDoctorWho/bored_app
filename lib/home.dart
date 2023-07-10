import 'dart:convert';
import 'package:gdsc_session/saved.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_session/api/boredmodel.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Bored> futureBored;
  bool isfavorite = false;
  bool isPressed = false;

  Future<Bored> fetchBored() async {
    final response =
        await http.get(Uri.parse('http://www.boredapi.com/api/activity/'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Bored.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Bored');
    }
  }

  void saveString(String activity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteActivities =
        prefs.getStringList('favoriteActivities') ?? [];
    favoriteActivities.add(activity);
    prefs.setStringList('favoriteActivities', favoriteActivities);
  }

  @override
  void initState() {
    super.initState();
    futureBored = fetchBored();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Bored>(
        future: futureBored,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.87,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 221, 221, 221),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        snapshot.data!.activity.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.star_border_outlined,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Saved()));
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isfavorite = false;
                            isPressed = !isPressed;
                            futureBored = fetchBored();
                            Future.delayed(const Duration(milliseconds: 200),
                                () {
                              setState(() {
                                isPressed = !isPressed;
                              });
                            });
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: isPressed ? 100 : 80,
                          height: isPressed ? 100 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black),
                            image: const DecorationImage(
                              image: AssetImage("assets/bored.png"),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red),
                        ),
                        child: IconButton(
                          icon: isfavorite == false
                              ? const Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.red,
                                  size: 40,
                                )
                              : const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 40,
                                ),
                          onPressed: () {
                            saveString(snapshot.data!.activity.toString());
                            setState(() {
                              isfavorite = !isfavorite;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
