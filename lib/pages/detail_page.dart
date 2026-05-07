import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:resep_masakan/models/meal.dart';
import 'package:resep_masakan/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailPage extends StatefulWidget {
  final String mealId;

  const DetailPage({super.key, required this.mealId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Meal? _meal;
  bool _isLoading = true;
  bool _isFavorite = false;
  late final Box _favoritesBox;

  @override
  void initState() {
    super.initState();
    _favoritesBox = Hive.box('favorites');
    _loadMealDetail();
    _checkFavorite();
  }

  Future<void> _loadMealDetail() async {
    setState(() => _isLoading = true);
    final meal = await ApiService.getMealById(widget.mealId);
    setState(() {
      _meal = meal;
      _isLoading = false;
    });
  }

  void _checkFavorite() {
    setState(() {
      _isFavorite = _favoritesBox.containsKey(widget.mealId);
    });
  }

  void _toggleFavorite() {
    if (_isFavorite) {
      _favoritesBox.delete(widget.mealId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dihapus dari favorit')),
      );
    } else if (_meal != null) {
      final favoriteData = {
        'id': _meal!.id,
        'name': _meal!.name,
        'category': _meal!.category,
        'area': _meal!.area,
        'instructions': _meal!.instructions,
        'thumbnail': _meal!.thumbnail,
        'tags': _meal!.tags,
      };
      _favoritesBox.put(widget.mealId, favoriteData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ditambahkan ke favorit')),
      );
    }
    _checkFavorite();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_meal?.name ?? 'Detail Resep'),
        backgroundColor: Colors.orange,
        actions: [
          if (_meal != null)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meal == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Gagal memuat detail resep'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: _meal!.thumbnail,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _meal!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        children: [
                          if (_meal!.category != null)
                            Chip(
                              label: Text(_meal!.category!),
                              avatar: const Icon(Icons.category, size: 18),
                              backgroundColor: Colors.orange[100],
                            ),
                          if (_meal!.area != null)
                            Chip(
                              label: Text(_meal!.area!),
                              avatar: const Icon(Icons.location_on, size: 18),
                              backgroundColor: Colors.green[100],
                            ),
                          if (_meal!.tags != null && _meal!.tags!.isNotEmpty)
                            Chip(
                              label: Text(_meal!.tags!.split(',').first),
                              avatar: const Icon(Icons.local_offer, size: 18),
                              backgroundColor: Colors.purple[100],
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Bahan-bahan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _meal!.ingredients.map((ingredient) {
                              final measure = (ingredient.measure != null && ingredient.measure.isNotEmpty) ? ' — ${ingredient.measure}' : '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${ingredient.name}$measure',
                                        style: const TextStyle(fontSize: 16, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Cara Memasak',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _meal!.instructions ?? 'Instruksi tidak tersedia',
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}