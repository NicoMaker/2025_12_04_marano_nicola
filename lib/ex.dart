// --- PARTE 1: LA CLASSE ---
// Appena leggi il testo, rinomina 'Elemento' con il soggetto dell'esame (es. Gatto, Auto, Studente)
class Elemento {
  final String nome;   // CAMBIA se serve (es. marca, cognome)
  final int numero;    // CAMBIA se serve (es. età, prezzo, voto)
  // Aggiungi altre proprietà qui se servono...

  Elemento({
    required this.nome,
    required this.numero,
  });
}

void main() {
  // --- PARTE 2: LA LISTA DI DATI ---
  // Qui inserirai i dati che ti dà il prof nel testo
  List<Elemento> lista = [
    Elemento(nome: "Esempio A", numero: 10),
    Elemento(nome: "Esempio B", numero: 20),
    Elemento(nome: "Esempio C", numero: 5),
  ];

  // --- PARTE 3: GLI ESERCIZI ---

  // A. FILTRARE (Es. "Trova quelli con numero > 5")
  // Cambia la condizione dentro le parentesi dopo la freccia
  var listaFiltrata = lista.where((e) => e.numero > 5).toList();
  print("Filtrati: ${listaFiltrata.length}");


  // B. TROVARE IL MASSIMO (Es. "Il più vecchio/costoso")
  if (lista.isNotEmpty) {
    Elemento ilMaggiore = lista[0]; // Parto dal primo
    
    for (var e in lista) {
      // Cambia '>' con '<' se cerchi il MINIMO
      if (e.numero > ilMaggiore.numero) { 
        ilMaggiore = e;
      }
    }
    print("Il maggiore è: ${ilMaggiore.nome}");
  }


  // C. CALCOLARE LA MEDIA
  if (lista.isNotEmpty) {
    double somma = 0;
    
    for (var e in lista) {
      somma = somma + e.numero;
    }
    
    double media = somma / lista.length;
    print("La media è: $media");
    }
}