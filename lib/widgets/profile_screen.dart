import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isSignedIn = false;
  String? fullName = "";
  String userName = "";
  int faouriteCandiCount = 0;

  Future<void> _retrieveAndDecryptDataFromPrefs() async {
    final Future<SharedPreferences> prefsFuture =
        SharedPreferences.getInstance();
    final SharedPreferences sharedPreferences = await prefsFuture;

    final encryptedUsername = sharedPreferences.getString('username') ?? '';
    final encryptedFullname = sharedPreferences.getString('fullname') ?? '';
    final keyString = sharedPreferences.getString('key') ?? '';
    final ivString = sharedPreferences.getString('iv') ?? '';

    final encrypt.Key key = encrypt.Key.fromBase64(keyString);
    final iv = encrypt.IV.fromBase64(ivString);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    if (encryptedFullname != "") {
      final decryptedUsername = encrypter.decrypt64(encryptedUsername, iv: iv);
      final decryptedFullname = encrypter.decrypt64(encryptedFullname, iv: iv);

      setState(() {
        userName = decryptedUsername;
        fullName = decryptedFullname;
        isSignedIn = true;
      });
    }
  }

  void _signOutLocalStorage() async {
    try {
      final Future<SharedPreferences> prefsFuture =
          SharedPreferences.getInstance();

      final SharedPreferences prefs = await prefsFuture;
      prefs.setBool('isSignedIn', false);
      prefs.setString('fullname', "");
      prefs.setString('username', "");
      prefs.setString('password', "");
      prefs.setString('key', "");
      prefs.setString('iv', "");

      setState(() {
        fullName = "";
        userName = "";
        isSignedIn = false;
      });
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  void signIn() {
    setState(() {
      Navigator.pushNamed(context, '/signin');
    });
  }

  void signOut() {
    setState(() {
      //isSignedIn = !isSignedIn;
      _signOutLocalStorage();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _retrieveAndDecryptDataFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.deepPurple,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                //TODO : Profile Header
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 150),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.deepPurple, width: 2),
                              shape: BoxShape.circle),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage('images/placeholder_image.png'),
                          ),
                        ),
                        if (isSignedIn)
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.deepPurple[50],
                              )),
                      ],
                    ),
                  ),
                ),
                //TODO : Profile Info
                const SizedBox(
                  height: 20,
                ),
                const Divider(
                  color: Colors.deepPurple,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: const Row(children: [
                        Icon(
                          Icons.lock,
                          color: Colors.amber,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Pengguna',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    Expanded(
                        child: Text(
                      ': $userName',
                      style: const TextStyle(fontSize: 18),
                    )),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Divider(
                  color: Colors.deepPurple.shade400,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: const Row(children: [
                        Icon(
                          Icons.person,
                          color: Colors.amber,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Nama',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    Expanded(
                        child: Text(
                      ': $fullName',
                      style: const TextStyle(fontSize: 18),
                    )),
                    if (isSignedIn) const Icon(Icons.edit),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Divider(
                  color: Colors.deepPurple.shade400,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: const Row(children: [
                        Icon(
                          Icons.favorite,
                          color: Color.fromARGB(255, 255, 7, 28),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Favorit',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    Expanded(
                        child: Text(
                      ': $faouriteCandiCount',
                      style: const TextStyle(fontSize: 18),
                    )),
                  ],
                ),

                const SizedBox(
                  height: 4,
                ),
                Divider(
                  color: Colors.deepPurple.shade400,
                ),
                const SizedBox(
                  height: 4,
                ),
                isSignedIn
                    ? TextButton(
                        onPressed: signOut, child: const Text("Sign Out"))
                    : TextButton(
                        onPressed: signIn, child: const Text("Sign In")),
              ],
            ),
          )
        ],
      ),
    );
  }
}
