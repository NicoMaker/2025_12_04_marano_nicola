import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:uuid/uuid.dart';

class Review {
  final String id;
  final String title;
  final String? comment;
  final int rating; 

  Review({
    required this.id,
    required this.title,
    this.comment,
    required this.rating,
  }) : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  Review copyWithFormData(Map<String, Object?> formData) {
    return Review(
      id: this.id,
      title: formData['title'] as String,
      comment: formData['comment'] as String?,
      rating: formData['rating'] as int,
    );
  }
}
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final Uuid _uuid = const Uuid();
  final List<Review> _reviews = [
    Review(id: const Uuid().v4(), title: 'Ottimo Burger!', comment: 'Patty succosa e servizio veloce.', rating: 5),
    Review(id: const Uuid().v4(), title: 'Pizza decente', comment: 'Un po\' bruciata sui bordi.', rating: 3),
  ];

  // Gestisce l'aggiunta di una nuova recensione
  void _addReview() async {
    final result = await Navigator.of(context).push<Map<String, Object?>>(
      MaterialPageRoute(
        builder: (context) => const ReviewFormScreen(),
      ),
    );

    if (result != null && mounted) {
      final newReview = Review(
        id: _uuid.v4(),
        title: result['title'] as String,
        comment: result['comment'] as String?,
        rating: result['rating'] as int,
      );

      setState(() {
        _reviews.add(newReview);
      });
    }
  }

  void _editReview(Review reviewToEdit) async {
    final result = await Navigator.of(context).push<Map<String, Object?>>(
      MaterialPageRoute(
        builder: (context) => ReviewFormScreen(review: reviewToEdit),
      ),
    );

    if (result != null && mounted) {
      final index = _reviews.indexWhere((r) => r.id == reviewToEdit.id);
      if (index != -1) {
        final updatedReview = reviewToEdit.copyWithFormData(result);
        setState(() {
          _reviews[index] = updatedReview;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFork Recensioni 🍴'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: _reviews.isEmpty
          ? const Center(child: Text('Nessuna recensione. Tocca "+" per aggiungerne una!'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: review.rating > 3 ? Colors.green : Colors.orange,
                      child: Text('${review.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: review.comment != null
                        ? Text(review.comment!, maxLines: 2, overflow: TextOverflow.ellipsis)
                        : const Text('Nessun commento.'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editReview(review),
                    ),
                  ),
                );
              },
            ),
      // Pulsante "+" per aggiungere
      floatingActionButton: FloatingActionButton(
        onPressed: _addReview,
        child: const Icon(Icons.add),
      ),
    );
  }
}



class ReviewFormScreen extends StatelessWidget {
  final Review? review; // Opzionale per la modalità Modifica

  const ReviewFormScreen({super.key, this.review});

  FormGroup buildForm() {
    return fb.group({
      // Campo Titolo: richiesto, min 3 caratteri
      'title': FormControl<String>(
        value: review?.title,
        validators: [Validators.required, Validators.minLength(3)],
      ),
      // Campo Commento: opzionale
      'comment': FormControl<String>(
        value: review?.comment,
      ),
      // Campo Rating: richiesto, intero tra 1 e 5
      'rating': FormControl<int>(
        value: review?.rating ?? 5,
        validators: [
          Validators.required,
          Validators.min(1),
          Validators.max(5),
        ],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = review != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifica Recensione' : 'Aggiungi Nuova Recensione'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ReactiveFormBuilder(
          form: buildForm,
          builder: (context, form, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Campo Titolo
                ReactiveTextField<String>(
                  formControlName: 'title',
                  decoration: const InputDecoration(
                    labelText: 'Titolo del Ristorante/Recensione *',
                    border: OutlineInputBorder(),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (error) => 'Il titolo non può essere vuoto',
                    ValidationMessage.minLength: (error) => 'Il titolo deve avere almeno 3 caratteri',
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Campo Commento
                ReactiveTextField<String>(
                  formControlName: 'comment',
                  decoration: const InputDecoration(
                    labelText: 'Commento (Opzionale)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),

                // Campo Rating (Slider)
                const Text('Valutazione (1-5) *', style: TextStyle(fontWeight: FontWeight.bold)),
                ReactiveSlider(
                  formControlName: 'rating',
                  min: 1.0,
                  max: 5.0,
                  divisions: 4,
                  // Visualizza il valore corrente accanto allo Slider
                  decoration: InputDecoration(
                    suffixIcon: ReactiveValueListenableBuilder(
                      formControlName: 'rating',
                      builder: (context, control, child) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${control.value?.round() ?? 5}/5',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return ElevatedButton.icon(
                      onPressed: form.valid ? () {
                        // Pop con la Map contenente i dati validati
                        Navigator.of(context).pop(form.value);
                      } : null, // Disabilita se il form non è valido
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: form.valid ? Theme.of(context).colorScheme.primary : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.send),
                      label: Text(isEditing ? 'Salva Modifiche' : 'Invia Recensione'),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFork App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const ReviewsScreen(),
    );
  }
}