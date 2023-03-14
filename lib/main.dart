import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    // El nuevo método getNext() reasigna el actual con un nuevo WordPair aleatorio. También llama a notificarListeners() (un método de ChangeNotifier) ​​que garantiza que cualquier persona que vea MyAppState sea notificada.
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toogleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
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
        page = FavoritePage();
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
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                    print(value);
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.onSurface,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Cada widget define un método build() que se llama automáticamente cada vez que cambian las circunstancias del widget para que el widget esté siempre actualizado.
    var appState = context.watch<
        MyAppState>(); //MyHomePage realiza un seguimiento de los cambios en el estado actual de la aplicación mediante el método de vigilancia.
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      //Cada método de compilación debe devolver un widget o (más típicamente) un árbol anidado de widgets. En este caso, el widget de nivel superior es Scaffold. No vas a trabajar con Scaffold en este laboratorio de código, pero es un widget útil y se encuentra en la gran mayoría de las aplicaciones Flutter del mundo real.
      child: Column(
        // La columna es uno de los widgets de diseño más básicos en Flutter. Toma cualquier número de niños y los pone en una columna de arriba a abajo. De forma predeterminada, la columna coloca visualmente a sus elementos secundarios en la parte superior. Pronto cambiará esto para que la columna esté centrada.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(
              pair:
                  pair), //Este segundo widget de texto toma appState y accede al único miembro de esa clase, actual (que es un WordPair). WordPair proporciona varios captadores útiles, como asPascalCase o asSnakeCase. Aquí, usamos asLowerCase pero puede cambiar esto ahora si prefiere una de las alternativas.
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toogleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  print('button pressed!');
                },
                child: Text('Next'),
              ),
            ],
          )
        ], // Observe cómo el código de Flutter hace un uso intensivo de las comas finales. Esta coma en particular no necesita estar aquí, porque children es el último (y también el único) miembro de esta lista de parámetros de columna en particular. Sin embargo, generalmente es una buena idea usar comas finales: hacen que agregar más miembros sea trivial y también sirven como una pista para que el formateador automático de Dart coloque una nueva línea allí. Para obtener más información, consulte Formato de código.
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var appState = context.watch<MyAppState>();
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites:',
            style: style,
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(
              pair.asLowerCase,
              style: style,
            ),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
