import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var favorites = <WordPair>[];

  var history = [];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  bool findFavorite() {
    return favorites.contains(current);
  }

  void addHistory() {
    history.add({'fav': findFavorite(), 'word': current});
  }

  void delFavorite(current) {
    if (favorites.contains(current)) {
      favorites.remove(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  )
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);

    delFavoriteMethod(current) {
      appState.delFavorite(current);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'You Have ${appState.favorites.length} Favorite Messages: ',
                      overflow: TextOverflow.fade,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: GridView.count(
                crossAxisCount: constraints.maxWidth >= 390 ? 2 : 1,
                childAspectRatio: 5,
                shrinkWrap: true,
                children: [
                  ...appState.favorites.map(
                    (e) {
                      return Row(children: [
                        TextButton(
                          style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all(EdgeInsets.zero),
                              minimumSize:
                                  MaterialStateProperty.all(Size(50, 50))),
                          onPressed: () => delFavoriteMethod(e),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Icon(Icons.delete_outline),
                          ),
                        ),
                        Text(e.toString()),
                      ]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    var pair = appState.current;
    var style = theme.textTheme.labelLarge!.copyWith(
      color: Colors.redAccent,
    );

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border_outlined;
    }

    var textNext = Text('Next');
    var onPressedNext = () {
      appState.addHistory();
      appState.getNext();
    };

    var textFavorite = Row(children: [Icon(icon), Text('Like')]);
    var onPressedFavorite = () {
      appState.toggleFavorite();
    };

    return Center(
      child: Column(
        children: [
          Spacer(
            flex: 2,
          ),
          Expanded(
            flex: 2,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.primaryColor,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ).createShader(bounds),
              blendMode: BlendMode.dstOut,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...appState.history.map(
                      (element) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            element['fav']
                                ? Icon(
                                    Icons.favorite,
                                    size: style.fontSize,
                                    color: style.color,
                                  )
                                : Text(' '),
                            Text(
                              element['word'].toString(),
                              style: style,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                BigCard(pair: pair),
                SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionButton(
                        onPressed2: onPressedFavorite, text: textFavorite),
                    SizedBox(width: 10),
                    ActionButton(onPressed2: onPressedNext, text: textNext),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.onPressed2,
    required this.text,
  });

  final onPressed2;
  final text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed2,
      child: text,
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final bold = style.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 20.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: pair.first.toLowerCase()),
              TextSpan(text: pair.second.toLowerCase(), style: bold),
            ],
            style: style,
          ),
        ),
      ),
    );
  }
}
