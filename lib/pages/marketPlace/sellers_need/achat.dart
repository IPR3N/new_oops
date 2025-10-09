import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/pages/marketPlace/models/product-model.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';

class Achat extends ConsumerStatefulWidget {
  final DataModel product;

  const Achat({super.key, required this.product});

  @override
  ConsumerState<Achat> createState() => _AchatState();
}

class _AchatState extends ConsumerState<Achat> {
  final TextEditingController _quantityController = TextEditingController();
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _quantityController.text = '1'; // Default quantity
    _updateTotalPrice();
    _quantityController.addListener(_updateTotalPrice);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateTotalPrice() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final basePrice = double.tryParse(widget.product.project.basePrice) ?? 0.0;
    setState(() {
      _totalPrice = quantity * basePrice;
    });
  }

  void _incrementQuantity() {
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    _quantityController.text = (currentQuantity + 1).toString();
  }

  void _decrementQuantity() {
    final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
    if (currentQuantity > 1) {
      _quantityController.text = (currentQuantity - 1).toString();
    }
  }

  void _confirmPurchase() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final locale = ref.read(localeProvider).languageCode;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocales.getTranslation('invalid_quantity', locale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Placeholder for purchase API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocales.getTranslation('purchase_initiated', locale)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final locale = ref.read(localeProvider).languageCode;
    final cropName = widget.product.project.crop.nom ?? 'Unknown Crop';
    final basePrice = double.tryParse(widget.product.project.basePrice) ?? 0.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          AppLocales.getTranslation('purchase', locale),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                widget.product.project.crop.photos,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: Image.asset(
                    'assets/images/projectDefautlPng.png',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 16),
            // Product Name
            Text(
              cropName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            // Price per kg
            Text(
              '\$${basePrice.toStringAsFixed(2)} / kg',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Quantity Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocales.getTranslation('quantity', locale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    ),
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: _incrementQuantity,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.green),
                      onPressed: _decrementQuantity,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Total Price
            Text(
              AppLocales.getTranslation('total_price', locale,
                  placeholders: {'price': _totalPrice.toStringAsFixed(2)}),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            // Confirm Purchase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  AppLocales.getTranslation('confirm_purchase', locale),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:new_oppsfarm/core/color.dart';
// import 'package:new_oppsfarm/locales.dart';
// import 'package:new_oppsfarm/pages/marketPlace/models/product-model.dart';
// import 'package:new_oppsfarm/providers/locale_provider.dart';

// class Achat extends ConsumerStatefulWidget {
//   final DataModel product;

//   const Achat({super.key, required this.product});

//   @override
//   ConsumerState<Achat> createState() => _AchatState();
// }

// class _AchatState extends ConsumerState<Achat> {
//   final TextEditingController _quantityController = TextEditingController();
//   double _totalPrice = 0.0;
//   double _basePrice = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize basePrice and log for debugging
//     _basePrice =
//         double.tryParse(widget.product.project.basePrice ?? '0.0') ?? 0.0;
//     print('Product: ${widget.product.project}');
//     print('Base Price: $_basePrice');
//     _quantityController.text = '1'; // Default quantity
//     _updateTotalPrice();
//     _quantityController.addListener(_updateTotalPrice);
//   }

//   @override
//   void dispose() {
//     _quantityController.removeListener(_updateTotalPrice);
//     _quantityController.dispose();
//     super.dispose();
//   }

//   void _updateTotalPrice() {
//     final quantity = int.tryParse(_quantityController.text) ?? 0;
//     setState(() {
//       _totalPrice = quantity * _basePrice;
//     });
//   }

//   void _incrementQuantity() {
//     final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
//     _quantityController.text = (currentQuantity + 1).toString();
//   }

//   void _decrementQuantity() {
//     final currentQuantity = int.tryParse(_quantityController.text) ?? 0;
//     if (currentQuantity > 1) {
//       _quantityController.text = (currentQuantity - 1).toString();
//     }
//   }

//   void _confirmPurchase() {
//     final quantity = int.tryParse(_quantityController.text) ?? 0;
//     final locale = ref.read(localeProvider).languageCode;
//     if (quantity <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(AppLocales.getTranslation('invalid_quantity', locale)),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Placeholder for purchase API call
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(AppLocales.getTranslation('purchase_initiated', locale)),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
//     final textColor = isDarkMode ? Colors.white : Colors.black;
//     final locale = ref.read(localeProvider).languageCode;
//     final cropName = widget.product.project.crop.nom ?? 'Unknown Crop';

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         backgroundColor: backgroundColor,
//         elevation: 0,
//         title: Text(
//           AppLocales.getTranslation('purchase', locale),
//           style: TextStyle(
//             color: textColor,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: textColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(15),
//               child: Image.network(
//                 widget.product.project.crop.photos,
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   height: 200,
//                   color: Colors.grey.shade300,
//                   child: Image.asset(
//                     'assets/images/projectDefautlPng.png',
//                     fit: BoxFit.cover,
//                     height: 200,
//                     width: double.infinity,
//                   ),
//                 ),
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return const Center(child: CircularProgressIndicator());
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Product Name
//             Text(
//               cropName,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Price per kg
//             Text(
//               _basePrice > 0
//                   ? '\$${_basePrice.toStringAsFixed(2)} / kg'
//                   : AppLocales.getTranslation('price_unavailable', locale),
//               style: TextStyle(
//                 fontSize: 18,
//                 color: _basePrice > 0 ? Colors.green : Colors.red,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Quantity Input
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _quantityController,
//                     keyboardType: TextInputType.number,
//                     decoration: InputDecoration(
//                       labelText: AppLocales.getTranslation('quantity', locale),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       filled: true,
//                       fillColor:
//                           isDarkMode ? Colors.grey[800] : Colors.grey[200],
//                     ),
//                     style: TextStyle(color: textColor),
//                     onChanged: (value) {
//                       // Ensure non-negative input
//                       if (value.isEmpty || int.tryParse(value) == null) {
//                         _quantityController.text = '1';
//                         _quantityController.selection =
//                             TextSelection.fromPosition(
//                           TextPosition(offset: _quantityController.text.length),
//                         );
//                       }
//                       _updateTotalPrice();
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Column(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.add, color: Colors.green),
//                       onPressed: _incrementQuantity,
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.remove, color: Colors.green),
//                       onPressed: _decrementQuantity,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Total Price
//             Text(
//               _basePrice > 0
//                   ? AppLocales.getTranslation('total_price', locale,
//                       placeholders: {'price': _totalPrice.toStringAsFixed(2)})
//                   : AppLocales.getTranslation(
//                       'total_price_unavailable', locale),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: _basePrice > 0 ? textColor : Colors.red,
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Confirm Purchase Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _basePrice > 0 ? _confirmPurchase : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 child: Text(
//                   AppLocales.getTranslation('confirm_purchase', locale),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
