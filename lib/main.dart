import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Own Pokedex'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Pokemon {
  final int id;
  final String name;
  final String image;
  final List<PokemonType>? types;
  final Stats stats;

  Pokemon(
      {required this.id,
      required this.name,
      required this.image,
      required this.types,
      required this.stats});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      stats: Stats.fromJson(json['stats']),
      types: List<PokemonType>.from(
          json['apiTypes'].map((x) => PokemonType.fromJson(x))),
    );
  }
}

class Stats {
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;

  Stats(
      {required this.hp,
      required this.attack,
      required this.defense,
      required this.specialAttack,
      required this.specialDefense,
      required this.speed});

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      hp: json['HP'],
      attack: json['attack'],
      defense: json['defense'],
      specialAttack: json['special_attack'],
      specialDefense: json['special_defense'],
      speed: json['speed'],
    );
  }

  List<int> toSortedList() {
    var stats = <int>[];
    stats.add(hp);
    stats.add(attack);
    stats.add(defense);
    stats.add(specialAttack);
    stats.add(specialDefense);
    stats.add(speed);
    stats.sort();
    return stats;
  }
}

class PokemonType {
  final String image;
  final String name;

  PokemonType({required this.image, required this.name});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      image: json['image'],
      name: json['name'],
    );
  }
}

Future<List<Pokemon>> fetchPokemons() async {
  final response = await http
      .get(Uri.parse('https://pokebuildapi.fr/api/v1/pokemon/generation/1'));
  if (response.statusCode == 200) {
    return List<Pokemon>.from(
        json.decode(response.body).map((x) => Pokemon.fromJson(x)));
  } else {
    throw Exception('Failed to load pokemons');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Pokemon>> pokedex;

  @override
  void initState() {
    super.initState();
    pokedex = fetchPokemons();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FutureBuilder<List<Pokemon>>(
          future: pokedex,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  children: [
                    for (var pokemon in snapshot.data!)
                      Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PokemonDetail(pokemon: pokemon)),
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 15,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (var type in pokemon.types!)
                                      Image.network(type.image,
                                          width: 30, height: 10)
                                  ],
                                ),
                              ),
                              Image.network(pokemon.image,
                                  width: 90, height: 90),
                              Text(pokemon.name),
                            ],
                          ),
                        ),
                      )
                  ]);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class PokemonDetail extends StatelessWidget {
  final Pokemon pokemon;
  final int biggestStat;

  //sort pokemon.stats by value

  //find biggest stat amongst pokemon.stats
  PokemonDetail({Key? key, required this.pokemon})
      : biggestStat = pokemon.stats.toSortedList().last,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(pokemon.image, width: 200, height: 200),
            Text(pokemon.name),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var type in pokemon.types!)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(type.image,
                                width: 20, height: 20),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(type.name),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
            Text("HP : ${pokemon.stats.hp}",
                style: TextStyle(
                    fontSize: pokemon.stats.hp == biggestStat ? 20 : 15)),
            Text("Attack : ${pokemon.stats.attack}",
                style: TextStyle(
                    fontSize: pokemon.stats.attack == biggestStat ? 20 : 15)),
            Text("Defense : ${pokemon.stats.defense}",
                style: TextStyle(
                    fontSize: pokemon.stats.defense == biggestStat ? 20 : 15)),
            Text("Special Attack : ${pokemon.stats.specialAttack}",
                style: TextStyle(
                    fontSize:
                        pokemon.stats.specialAttack == biggestStat ? 20 : 15)),
            Text("Special Defense : ${pokemon.stats.specialDefense}",
                style: TextStyle(
                    fontSize:
                        pokemon.stats.specialDefense == biggestStat ? 20 : 15)),
            Text("Speed : ${pokemon.stats.speed}",
                style: TextStyle(
                    fontSize: pokemon.stats.speed == biggestStat ? 20 : 15)),
          ],
        ),
      ),
    );
  }
}
