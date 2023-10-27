import 'package:animated_background/animated_background.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dog_api.dart';
import 'firebase_options.dart';
bool toTest= false;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // da commentare per testare in locale
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DeliveristoChallenge());
}

class DeliveristoChallenge extends StatelessWidget {
  const DeliveristoChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final Color mainColor = Colors.indigo;
  final dio = Dio();
  late Future<DogImage> getFirstDogImage;
  Future<List>? getSubBreeds;
  String breedListUrl = 'https://dog.ceo/api/breeds/list/all';
  String randomImageUrl = 'https://dog.ceo/api/breeds/image/random';
  String? selectedBreed;
  String? selectedSubBreed;

  Future<DogImage> getDogImage(String url) async {
    final response = await dio.get(url);
    return DogImage.fromJson(response.data);
  }

  Future<List<String>> getBreedStringList(String url,
      {String? selectedBreed}) async {
    final response = await dio.get(url);
    Map<String, dynamic> responseMap = response.data['message'];
    return responseMap.keys.toList();
  }

  Future<List> getSubBreedStringList() async {
    final response = await dio.get(breedListUrl);
    List responseMap = response.data['message'][selectedBreed];
    return responseMap;
  }

  Future<List> getImageList() async {
    String imageListUrl = 'https://dog.ceo/api/breed/$selectedBreed/images';
    if (selectedSubBreed != null) {
      imageListUrl =
          'https://dog.ceo/api/breed/$selectedBreed/$selectedSubBreed/images';
    }
    final response = await dio.get(imageListUrl);
    List responseMap = response.data['message'];
    return responseMap;
  }

  Future<List> resetSubBreeds() async {
    return [];
  }

  @override
  void initState() {
    super.initState();
    getFirstDogImage = getDogImage(randomImageUrl);
  }

  Widget adaptiveWrap(BuildContext context,
      {required List<Widget> children,
      CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
      MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start}) {
    final bool isDesktopView =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return isDesktopView
        ? Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          )
        : Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
  }

  // l' animazione continua con le ossa non mi permette di usare
  // tester.pumpAndSettle() quindi uso la variabile di appoggio toTest per
  // non mostrare l' animazione durante i test
Widget removeAnimationIfTesting({required Widget child}){return toTest?child: AnimatedBackground(
  vsync: this,
  behaviour: RandomParticleBehaviour(
    options: ParticleOptions(
        image: Image.asset(
          'assets/images/bone.png',
          color: mainColor,
        ),
        baseColor: Colors.red,
        spawnMaxSpeed: 50,
        spawnMinSpeed: 10),
  ),
  child: child
); }
  @override
  Widget build(BuildContext context) {
  final bool isDesktopView =
  MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        color: Colors.grey.shade100,
        child: removeAnimationIfTesting(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/dog_logo.png',
                  color: Colors.white38,
                ),
              ),
              backgroundColor: mainColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              title: const Text(
                'Deliveristo Challenge',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'JURA',
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
            ),
            body: adaptiveWrap(
              context,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FutureBuilder<List<String>>(
                              future: getBreedStringList(
                                  'https://dog.ceo/api/breeds/list/all'),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DropdownButton<String>(
                                    hint: const Text(
                                      'Breed',
                                    ),
                                    value: selectedBreed,
                                    borderRadius: BorderRadius.circular(15),
                                    elevation: 16,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: mainColor,
                                    ),
                                    underline: Container(
                                      height: 1,
                                      color: mainColor,
                                    ),
                                    onChanged: (String? value) {
                                      selectedBreed = value;
                                      selectedSubBreed = null;
                                      getSubBreeds = resetSubBreeds();
                                      getSubBreeds = getSubBreedStringList();
                                      randomImageUrl =
                                          'https://dog.ceo/api/breed/$selectedBreed/images/random';
                                      setState(() {});
                                    },
                                    style: const TextStyle(
                                        fontFamily: 'JURA',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    items: snapshot.data!
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        alignment: Alignment.center,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }),
                          FutureBuilder<List>(
                              future: getSubBreeds,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return DropdownButton(
                                    hint: const Text(
                                      'Sub-Breed',
                                    ),
                                    value: selectedSubBreed,
                                    borderRadius: BorderRadius.circular(15),
                                    elevation: 16,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: mainColor,
                                    ),
                                    style: const TextStyle(
                                        fontFamily: 'JURA',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    underline: Container(
                                      height: 1,
                                      color: mainColor,
                                    ),
                                    onChanged: (String? value) {
                                      selectedSubBreed = value;
                                      randomImageUrl =
                                          'https://dog.ceo/api/breed/$selectedBreed/$selectedSubBreed/images/random';
                                      setState(() {});
                                    },
                                    items: snapshot.data!
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value.toString(),
                                        alignment: Alignment.center,
                                        child: Text(
                                          value,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder<DogImage>(
                            future: getFirstDogImage,
                            builder: (context, snapshot) {
                              String getBreedName() {
                                String imageUrl = snapshot.data!.imageUrl!;
                                imageUrl =
                                    imageUrl.substring(imageUrl.indexOf('breeds/'));
                                imageUrl = imageUrl.replaceFirst('breeds/', '');
                                return imageUrl.substring(0, imageUrl.indexOf('/'));
                              }
                              if (!snapshot.hasData) {
                                return const Text(
                                  'Error',
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return Column(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.network(key: const Key('imageKey'),
                                            snapshot.data!.imageUrl!,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(child: Text('Image not found')),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Breed: ${getBreedName()}',
                                        style: const TextStyle(
                                            fontFamily: 'JURA',
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                );
                              }
                            }),
                      ),
                      Center(
                        child: TextButton(key: const Key('generateBtnKey'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                backgroundColor: mainColor),
                            onPressed: () {
                              getFirstDogImage = getDogImage(randomImageUrl);
                              setState(() {});
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Generate',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: 'JURA',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                            )),
                      ),
                      Center(
                        child: TextButton(
                            style:
                                TextButton.styleFrom(foregroundColor: Colors.black),
                            onPressed: () {
                              getSubBreeds = resetSubBreeds();
                              selectedBreed = null;
                              selectedSubBreed = null;
                              randomImageUrl =
                                  'https://dog.ceo/api/breeds/image/random';
                              setState(() {});
                            },
                            child: const Text(
                              'Reset',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: 'JURA',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                            )),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List>(
                      future: getImageList(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Text(
                                'List of ${selectedSubBreed ?? ''} ${selectedBreed}s',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'JURA',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final String imageUrl =
                                        snapshot.data![index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Center(
                                                  child: Text(
                                                      'Image not found')),
                                        ),
                                      ),
                                    );
                                  },
                                  scrollDirection: isDesktopView ? Axis.vertical:Axis.horizontal,
                                  itemCount: snapshot.data!.length,
                                  shrinkWrap: true,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
