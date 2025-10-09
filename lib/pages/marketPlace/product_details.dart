import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/marketPlace/models/product-model.dart';
import 'package:new_oppsfarm/pages/marketPlace/sellers_need/achat.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final DataModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  bool isAvailable(int quantity) {
    return quantity > 20;
  }

  bool isMature(int maturationDays) {
    return maturationDays > 40;
  }

  int _calculateDaysDifference(DataModel product) {
    final DateTime today = DateTime.now();
    DateTime endDate;
    try {
      endDate = product.project.endDate is String
          ? DateTime.parse(product.project.endDate as String)
          : product.project.endDate as DateTime;
    } catch (e) {
      endDate = today; // Fallback to today if parsing fails
      print('Error parsing endDate: $e');
    }
    return endDate.difference(today).inDays;
  }

  void _showBottomSheet(BuildContext context) {
    final locale = ref.read(localeProvider).languageCode;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      builder: (BuildContext context) {
        TextEditingController messageController = TextEditingController();

        return Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation('exchange_messages', locale),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocales.getTranslation('enter_message', locale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        print(
                            AppLocales.getTranslation('message_sent', locale) +
                                ": ${messageController.text}");
                        messageController.clear();
                        Navigator.pop(
                            context); // Close bottom sheet after sending
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider).languageCode;
    final int daysDifference = _calculateDaysDifference(widget.product);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final textColor = isDarkMode ? Colors.white : black;
    final iconColor = isDarkMode ? Colors.white : black;
    final buttonColor = isDarkMode ? Colors.grey[900]! : green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          widget.product.project.nom ?? 'Product',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              print('Share button pressed');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.product.project.imageUrl ?? '',
                    fit: BoxFit.cover,
                    height: 250,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/projectDefautlPng.png',
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product.project.crop.nom ?? 'Unknown Crop',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        AppLocales.getTranslation(
                                'days_before_maturity', locale) +
                            ': ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                      Text(
                        '$daysDifference ' +
                            AppLocales.getTranslation('days', locale),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isAvailable(int.tryParse(widget.product.project
                                    .estimatedQuantityProduced ??
                                '0') ??
                            0)
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: isAvailable(int.tryParse(widget.product.project
                                    .estimatedQuantityProduced ??
                                '0') ??
                            0)
                        ? green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAvailable(int.tryParse(widget.product.project
                                    .estimatedQuantityProduced ??
                                '0') ??
                            0)
                        ? AppLocales.getTranslation('available', locale)
                        : AppLocales.getTranslation('unavailable', locale),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable(int.tryParse(widget.product.project
                                      .estimatedQuantityProduced ??
                                  '0') ??
                              0)
                          ? green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.inventory,
                    color: green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocales.getTranslation('available_quantity', locale) +
                        ': ${widget.product.project.estimatedQuantityProduced ?? '0'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocales.getTranslation('description', locale),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.project.description ??
                    'No description available',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Achat(
                            product:
                                widget.product, // Fixed: Use widget.product
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      AppLocales.getTranslation('buy_now', locale),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: buttonColor,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}
