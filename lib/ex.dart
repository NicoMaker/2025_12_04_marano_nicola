import 'package:flutter/material.dart';

// --- PARTE 1: LA CLASSE RINOMINATA ---
class Prodotto {
  final String nome; // Nome del Prodotto
  final double prezzo; // Prezzo del Prodotto
  // Aggiungi altre proprietà qui se servono...

  Prodotto({
    required this.nome,
    required this.prezzo,
  });
}

// --- CLASSE PRINCIPALE (Avvio App) ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esame Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Inizia dalla pagina di Login
    );
  }
}

// ===============================================
// SCHERMATA DI LOGIN
// ===============================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Logica di autenticazione (semplificata per l'esempio)
      if (_username == 'admin' && _password == '12345') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProductsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenziali errate')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci l\'username';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton( // Il tuo richiesto ElevatedButton
                  onPressed: _login,
                  child: const Text('Accedi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===============================================
// SCHERMATA DEI PRODOTTI (con Lista ed Esercizi)
// ===============================================

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // --- PARTE 2: LA LISTA DI DATI ---
  final List<Prodotto> _tuttaLaLista = [
    Prodotto(nome: "Laptop", prezzo: 1200.50),
    Prodotto(nome: "Smartphone", prezzo: 750.99),
    Prodotto(nome: "Monitor", prezzo: 320.00),
    Prodotto(nome: "Tastiera", prezzo: 55.75),
    Prodotto(nome: "Mouse", prezzo: 20.00),
    Prodotto(nome: "Webcam", prezzo: 80.00),
  ];

  late List<Prodotto> _listaVisualizzata;
  double _mediaPrezzi = 0.0;
  String _prodottoPiuCostoso = "N/A";
  double _prezzoMinimoFiltro = 0.0; // Per il filtro dinamico

  @override
  void initState() {
    super.initState();
    _listaVisualizzata = List.from(_tuttaLaLista); // Inizializza con tutti i dati
    _calcolaStatistiche(_tuttaLaLista); // Calcola subito le statistiche iniziali
  }

  // A. FILTRARE (Mostra solo quelli con prezzo superiore al filtro)
  void _applicaFiltro() {
    setState(() {
      _listaVisualizzata = _tuttaLaLista
          .where((p) => p.prezzo > _prezzoMinimoFiltro)
          .toList();
    });
  }

  // B. TROVARE IL MASSIMO e C. CALCOLARE LA MEDIA
  void _calcolaStatistiche(List<Prodotto> lista) {
    if (lista.isEmpty) {
      setState(() {
        _mediaPrezzi = 0.0;
        _prodottoPiuCostoso = "Nessun prodotto";
      });
      return;
    }

    // C. CALCOLARE LA MEDIA
    double somma = 0;
    for (var p in lista) {
      somma += p.prezzo;
    }
    double media = somma / lista.length;

    // B. TROVARE IL MASSIMO
    Prodotto ilMaggiore = lista[0];
    for (var p in lista) {
      if (p.prezzo > ilMaggiore.prezzo) {
        ilMaggiore = p;
      }
    }

    setState(() {
      _mediaPrezzi = media;
      _prodottoPiuCostoso = "${ilMaggiore.nome} (${ilMaggiore.prezzo.toStringAsFixed(2)} €)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista Prodotti e Analisi')),
      body: Column(
        children: <Widget>[
          // Blocco 1: Statistiche
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Analisi della Lista Completa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  Text('Media Prezzi: *${_mediaPrezzi.toStringAsFixed(2)} €*'),
                  Text('Prodotto più Costoso: *$_prodottoPiuCostoso*'),
                  ElevatedButton(
                    onPressed: () => _calcolaStatistiche(_tuttaLaLista), // Ricacalcola
                    child: const Text('Ricalcola Statistiche'),
                  ),
                ],
              ),
            ),
          ),
          
          // Blocco 2: Filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prezzo Minimo (€)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _prezzoMinimoFiltro = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _applicaFiltro,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtra Lista'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _listaVisualizzata = List.from(_tuttaLaLista); // Reset
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          
          // Blocco 3: Lista Visualizzata
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Text('Risultati del Filtro:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _listaVisualizzata.length,
              itemBuilder: (context, index) {
                final prodotto = _listaVisualizzata[index];
                return ListTile(
                  title: Text(prodotto.nome),
                  trailing: Text('${prodotto.prezzo.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.shopping_bag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}