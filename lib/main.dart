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
      rating: (formData['rating'] as double).round(),
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
    Review(id: const Uuid().v4(), title: 'Deliziosa Pizza', comment: 'Piatto delizioso e servizio impeccabile.', rating: 4),
  ];

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
        rating: (result['rating'] as double).round(),
      );

      setState(() {
        _reviews.add(newReview);
      });
    }
  }


  void _editReview(Review reviewToEdit) async {
    // Naviga verso ReviewFormScreen passando la recensione da modificare
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
  

  void _deleteReview(Review reviewToDelete) {
    setState(() {
      _reviews.removeWhere((r) => r.id == reviewToDelete.id);
    });
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
                  child: Dismissible( 
                    key: ValueKey(review.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white, size: 30),
                    ),
                    onDismissed: (direction) {
                      _deleteReview(review);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Recensione "${review.title}" eliminata.')),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: review.rating > 3 ? Colors.green : (review.rating == 3 ? Colors.amber : Colors.red),
                        child: Text('${review.rating}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(review.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: review.comment != null && review.comment!.isNotEmpty
                          ? Text(review.comment!, maxLines: 2, overflow: TextOverflow.ellipsis)
                          : const Text('Nessun commento.'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editReview(review),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReview,
        child: const Icon(Icons.add),
      ),
    );
  }
}


class ReviewFormScreen extends StatelessWidget {
  final Review? review; 

  const ReviewFormScreen({super.key, this.review});

  FormGroup buildForm() {
    return fb.group({
      'title': FormControl<String>(
        value: review?.title,
        validators: [Validators.required, Validators.minLength(3)],
      ),
      'comment': FormControl<String>(
        value: review?.comment,
      ),
      'rating': FormControl<double>(
        value: review?.rating.toDouble() ?? 5.0, 
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
                const Text('Valutazione (1-5) *', style: TextStyle(fontWeight: FontWeight.bold)),
                ReactiveSlider(
                  formControlName: 'rating',
                  min: 1.0,
                  max: 5.0,
                  divisions: 4, 
                  decoration: InputDecoration(
                    suffixIcon: ReactiveValueListenableBuilder(
                      formControlName: 'rating',
                      builder: (context, control, child) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${control.value?.round() ?? 5}/5',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: control.value == 5 
                                ? Colors.green 
                                : (control.value == 1 ? Colors.red : Colors.orange),
                            ),
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
                        Navigator.of(context).pop(form.value);
                      } : null, 
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

// Classe principale dell'App
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