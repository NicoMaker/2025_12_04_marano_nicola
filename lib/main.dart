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

  factory Review.fromFormData(String id, Map<String, Object?> formData) {
    return Review(
      id: id,
      title: formData['title'] as String,
      comment: formData['comment'] as String?,
      rating: (formData['rating'] as double).round(),
    );
  }

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
    Review(
      id: const Uuid().v4(),
      title: 'Ottimo Burger! ',
      comment:
          'Patty succosa e servizio veloce. Peccato per le patatine fredde.',
      rating: 5,
    ),
    Review(
      id: const Uuid().v4(),
      title: 'Pizza decente ',
      comment: 'Un po\' bruciata sui bordi e ingredienti scarsi.',
      rating: 3,
    ),
    Review(
      id: const Uuid().v4(),
      title: 'Cena deliziosa ',
      comment:
          'Piatto di pasta delizioso e servizio impeccabile. Molto consigliato.',
      rating: 4,
    ),
  ];

  void _addReview() async {
    final result = await Navigator.of(context).push<Map<String, Object?>>(
      MaterialPageRoute(builder: (context) => const ReviewFormScreen()),
    );

    if (result != null && mounted) {
      final newReview = Review.fromFormData(_uuid.v4(), result);
      setState(() {
        _reviews.add(newReview);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recensione "${newReview.title}" aggiunta.')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recensione "${updatedReview.title}" modificata.'),
          ),
        );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFork Recensioni '),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: _reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 80,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nessuna recensione. Tocca "+" per aggiungerne una!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final ratingColor = review.rating > 3
                    ? Colors.green
                    : (review.rating == 3 ? Colors.amber[700] : Colors.red);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Dismissible(
                    key: ValueKey(review.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteReview(review);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Recensione "${review.title}" eliminata.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: ratingColor,
                        child: Text(
                          '${review.rating}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        review.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle:
                          review.comment != null && review.comment!.isNotEmpty
                          ? Text(
                              review.comment!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          : const Text(
                              'Nessun commento.',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: colorScheme.secondary),
                        onPressed: () => _editReview(review),
                        tooltip: 'Modifica recensione',
                      ),
                      onTap: () => _editReview(
                        review,
                      ), // Rende l'intera riga cliccabile per la modifica
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReview,
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
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
      'comment': FormControl<String>(value: review?.comment),
      'rating': FormControl<double>(
        value: review?.rating.toDouble() ?? 5.0,
        validators: [Validators.required, Validators.min(1), Validators.max(5)],
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = review != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Modifica Recensione' : 'Aggiungi Nuova Recensione',
        ),
        backgroundColor: colorScheme.secondaryContainer,
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
                    prefixIcon: Icon(Icons.short_text),
                  ),
                  validationMessages: {
                    ValidationMessage.required: (error) =>
                        'Il titolo non può essere vuoto',
                    ValidationMessage.minLength: (error) =>
                        'Il titolo deve avere almeno 3 caratteri',
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                ReactiveTextField<String>(
                  formControlName: 'comment',
                  decoration: const InputDecoration(
                    labelText: 'Commento (Opzionale)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.comment_outlined),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                const Text(
                  'Valutazione (1-5) *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ReactiveSlider(
                            formControlName: 'rating',
                            min: 1.0,
                            max: 5.0,
                            divisions: 4,
                            activeColor: colorScheme.primary,
                          ),
                        ),
                        ReactiveValueListenableBuilder(
                          formControlName: 'rating',
                          builder: (context, control, child) {
                            final ratingValue = control.value as double;
                            final valueColor = ratingValue > 3
                                ? Colors.green
                                : (ratingValue == 3
                                      ? Colors.amber[700]
                                      : Colors.red);

                            return SizedBox(
                              width: 50,
                              child: Text(
                                '$ratingValue/5',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: valueColor,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return ElevatedButton.icon(
                      onPressed: form.valid
                          ? () {
                              Navigator.of(context).pop(form.value);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: form.valid
                            ? colorScheme.primary
                            : Colors.grey[400],
                        foregroundColor: form.valid
                            ? colorScheme.onPrimary
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.send, size: 24),
                      label: Text(
                        isEditing ? 'Salva Modifiche' : 'Invia Recensione',
                        style: const TextStyle(fontSize: 18),
                      ),
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
      title: 'MyFork Recensioni App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      home: const ReviewsScreen(),
    );
  }
}
