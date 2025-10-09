import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/core/color.dart';
import 'package:new_oppsfarm/locales.dart';
import 'package:new_oppsfarm/main.dart';
import 'package:new_oppsfarm/pages/auth/login.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';
import 'package:new_oppsfarm/pages/marketPlace/influence_factors.dart';
import 'package:new_oppsfarm/pages/marketPlace/marketService/marketHttpService.dart';
import 'package:new_oppsfarm/pages/marketPlace/models/product-model.dart';
import 'package:new_oppsfarm/pages/marketPlace/product_details.dart';
import 'package:new_oppsfarm/pages/marketPlace/sellers_need/achat.dart';
import 'package:new_oppsfarm/pages/marketPlace/sellers_need/addSellers_need.dart';
import 'package:new_oppsfarm/pages/projets/projet.dart';
import 'package:new_oppsfarm/pages/projets/services/httpService.dart';
import 'package:new_oppsfarm/providers/locale_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:new_oppsfarm/reusableComponent/drawer.dart';

class MarketState with EquatableMixin {
  final List<DataModel> products;
  final bool isLoading;
  final dynamic connectedUser;
  final String searchQuery;

  const MarketState({
    required this.products,
    required this.isLoading,
    this.connectedUser,
    required this.searchQuery,
  });

  factory MarketState.initial() => const MarketState(
        products: [],
        isLoading: false,
        connectedUser: null,
        searchQuery: '',
      );

  MarketState copyWith({
    List<DataModel>? products,
    bool? isLoading,
    dynamic connectedUser,
    String? searchQuery,
  }) {
    return MarketState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      connectedUser: connectedUser ?? this.connectedUser,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [products, isLoading, connectedUser, searchQuery];
}

class MarketNotifier extends StateNotifier<MarketState> {
  final MarketHttpService _marketHttpService;
  final AuthService _authService;
  final Ref _ref;

  MarketNotifier(this._marketHttpService, this._authService, this._ref)
      : super(MarketState.initial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _connectUser();
    await _fetchMarketProducts();
  }

  Future<void> _connectUser() async {
    state = state.copyWith(isLoading: true);
    try {
      String? token = await _authService.readToken();
      if (token != null) {
        state = state.copyWith(connectedUser: JwtDecoder.decode(token));
      } else {
        AppLocales.debugPrint(
            'debug_no_token', _ref.read(localeProvider).languageCode);
      }
    } catch (e) {
      AppLocales.debugPrint(
          'debug_user_connection_error', _ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _fetchMarketProducts() async {
    state = state.copyWith(isLoading: true);
    try {
      final List<dynamic> products = await _marketHttpService.getMarketItems();
      List<DataModel> marketItems = products.map((product) {
        if (product != null && product is Map<String, dynamic>) {
          return DataModel.fromJson(product);
        } else {
          throw Exception("Produit invalide : $product");
        }
      }).toList();
      state = state.copyWith(products: marketItems);
      AppLocales.debugPrint(
          'debug_products_loaded', _ref.read(localeProvider).languageCode);
    } catch (e) {
      AppLocales.debugPrint(
          'debug_products_error', _ref.read(localeProvider).languageCode,
          placeholders: {'error': e.toString()});
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final marketProvider =
    StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  final marketHttpService = MarketHttpService();
  final authService = AuthService();
  return MarketNotifier(marketHttpService, authService, ref);
});

class ECommerceHomePage extends ConsumerStatefulWidget {
  const ECommerceHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ECommerceHomePage> createState() => _ECommerceHomePageState();
}

class _ECommerceHomePageState extends ConsumerState<ECommerceHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketHttpService _marketHttpService = MarketHttpService();
  List<dynamic> _sellersNeeds = [];
  bool _isNeedsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchSellerNeeds();

    _tabController.addListener(() {
      setState(() {}); // Refresh UI to show/hide FAB
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchSellerNeeds() async {
    setState(() {
      _isNeedsLoading = true;
    });

    try {
      final needs = await _marketHttpService.getSellerNeeds();
      setState(() {
        _sellersNeeds = needs;
      });
    } catch (e) {
      AppLocales.debugPrint(
        'debug_seller_needs_error',
        ref.read(localeProvider).languageCode,
        placeholders: {'error': e.toString()},
      );
    } finally {
      setState(() {
        _isNeedsLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    // await ref.read(projectProvider.notifier)._authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation(
                    'choose_theme', ref.read(localeProvider).languageCode),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: Text(AppLocales.getTranslation(
                    'system_theme', ref.read(localeProvider).languageCode)),
                value: themeMode == ThemeMode.system,
                onChanged: (value) {
                  final newMode = value ? ThemeMode.system : ThemeMode.light;
                  ref.read(themeProvider.notifier).setThemeMode(newMode);
                },
                secondary: const Icon(Icons.phone_android),
              ),
              if (themeMode != ThemeMode.system)
                SwitchListTile(
                  title: Text(themeMode == ThemeMode.dark
                      ? AppLocales.getTranslation(
                          'dark_mode', ref.read(localeProvider).languageCode)
                      : AppLocales.getTranslation(
                          'light_mode', ref.read(localeProvider).languageCode)),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    final newMode = value ? ThemeMode.dark : ThemeMode.light;
                    ref.read(themeProvider.notifier).setThemeMode(newMode);
                  },
                  secondary: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocales.getTranslation(
                    'close',
                    ref.read(localeProvider).languageCode,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.getTranslation(
                    'choose_language', ref.read(localeProvider).languageCode),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Français'),
                leading: Radio<String>(
                  value: 'fr',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: currentLocale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocales.getTranslation(
                    'close', ref.read(localeProvider).languageCode)),
              ),
            ],
          ),
        );
      },
    );
  }

  DateTime calculateMaturityDate(DateTime startDate, int daysToGerminate,
      int daysToCroissant, int daysToMaturity,
      {double weatherAdjustment = 1.0}) {
    final totalDays = (daysToGerminate + daysToCroissant + daysToMaturity) *
        weatherAdjustment;
    return startDate.add(Duration(days: totalDays.ceil()));
  }

  double calculateUpdatedPrice(
      double basePrice, DateTime maturityDate, int daysSinceMaturity) {
    double demandFactor = InfluenceFactors.getDemandFactor(maturityDate);
    double supplyFactor = InfluenceFactors.getSupplyFactor(maturityDate);
    double productionCostFactor =
        InfluenceFactors.getProductionCostFactor(maturityDate);
    double weatherFactor = InfluenceFactors.getWeatherFactor(maturityDate);
    double decayFactor = daysSinceMaturity > 0
        ? (1 - (daysSinceMaturity / 30).clamp(0, 0.5))
        : 1.0;

    double updatedPrice = basePrice;
    updatedPrice *= demandFactor;
    updatedPrice *= supplyFactor;
    updatedPrice *= productionCostFactor;
    updatedPrice *= weatherFactor;
    updatedPrice *= decayFactor;

    return updatedPrice.clamp(basePrice * 0.5, basePrice * 2.0);
  }

  List<DataModel> _filteredProducts(
      List<DataModel> products, String searchQuery) {
    if (searchQuery.isEmpty) return products;
    return products
        .where((product) => product.project.crop.nom
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  Map<String, dynamic> _calculateMaturityStatus(DataModel product) {
    final DateTime now = DateTime.now();
    final DateTime startDate = product.project.startDate ?? now;
    final int daysToGerminate = product.project.cropVariety.daysToGerminate;
    final int daysToCroissant = product.project.cropVariety.daysToCroissant;
    final int daysToMaturity = product.project.cropVariety.daysToMaturity;
    final totalDaysToMaturity =
        daysToGerminate + daysToCroissant + daysToMaturity;

    final double weatherAdjustment = InfluenceFactors.getWeatherFactor(now);
    final DateTime calculatedMaturityDate = calculateMaturityDate(
      startDate,
      daysToGerminate,
      daysToCroissant,
      daysToMaturity,
      weatherAdjustment: weatherAdjustment,
    );

    final DateTime maturityDate = product.project.endDate != null &&
            product.project.endDate!.isAfter(startDate)
        ? product.project.endDate!
        : calculatedMaturityDate;

    final int daysUntilMaturity = maturityDate.difference(now).inDays;
    final int daysSinceMaturity = now.difference(maturityDate).inDays;
    final int gracePeriodDays = (totalDaysToMaturity * 0.1).ceil();

    final int daysElapsed = now.difference(startDate).inDays;
    String phase;
    Color maturityColor;
    if (daysElapsed < daysToGerminate) {
      phase = 'germinating';
      maturityColor = Colors.blue;
    } else if (daysElapsed < daysToGerminate + daysToCroissant) {
      phase = 'growing';
      maturityColor = Colors.orange;
    } else if (daysUntilMaturity > 0) {
      phase = 'maturing';
      maturityColor = Colors.yellow;
    } else {
      phase = 'mature';
      maturityColor = Colors.green;
    }

    final double demandFactor = InfluenceFactors.getDemandFactor(maturityDate);
    final bool isVisible =
        (daysUntilMaturity >= 0 || daysSinceMaturity <= gracePeriodDays) &&
            demandFactor > 0.5;

    String maturityText;
    if (daysUntilMaturity > 0) {
      maturityText = AppLocales.getTranslation(
        phase,
        ref.read(localeProvider).languageCode,
        placeholders: {'days': daysUntilMaturity.toString()},
      );
    } else {
      maturityText = AppLocales.getTranslation(
        'mature',
        ref.read(localeProvider).languageCode,
        placeholders: {'days': daysSinceMaturity.toString()},
      );
    }

    AppLocales.debugPrint(
      'debug_maturity_status',
      ref.read(localeProvider).languageCode,
      placeholders: {
        'product': product.project.nom,
        'phase': phase,
        'daysUntilMaturity': daysUntilMaturity.toString(),
        'gracePeriodDays': gracePeriodDays.toString(),
        'isVisible': isVisible.toString(),
      },
    );

    return {
      'isVisible': isVisible,
      'maturityText': maturityText,
      'maturityColor': maturityColor,
      'maturityDate': maturityDate,
      'daysSinceMaturity': daysSinceMaturity.clamp(0, double.infinity).toInt(),
      'phase': phase,
    };
  }

  Widget _buildProductGrid(BuildContext context, MarketState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : black;
    final cardColor = isDarkMode ? Colors.grey[900] : white;
    final filteredProducts =
        _filteredProducts(state.products, state.searchQuery)
            .where((product) => _calculateMaturityStatus(product)['isVisible'])
            .toList();
    final locale = ref.watch(localeProvider).languageCode;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Adjusted to fit button
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final maturityStatus = _calculateMaturityStatus(product);

        final updatedPrice = calculateUpdatedPrice(
          double.tryParse(product.project.basePrice) ?? 0.0,
          maturityStatus['maturityDate'],
          maturityStatus['daysSinceMaturity'],
        );

        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailsPage(product: product),
                ),
              );
            },
            child: Card(
              elevation: 1.5,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Stack(
                      children: [
                        Image.network(
                          product.project.crop.photos,
                          fit: BoxFit.cover,
                          height: 100,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 100,
                            color: Colors.grey.shade300,
                            child: Image.asset(
                              'assets/images/projectDefautlPng.png',
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              maturityStatus['maturityText'],
                              style: TextStyle(
                                color: maturityStatus['maturityColor'],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.project.crop.nom,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${updatedPrice.toStringAsFixed(2)} / kg',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Achat(
                              product: product,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      child: Text(
                        AppLocales.getTranslation('buy_now', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;
    final borderColor = isDarkMode ? Colors.grey[700]! : green;
    final locale = ref.watch(localeProvider).languageCode;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: AppLocales.getTranslation('search_product', locale),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: backgroundColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Colors.white,
              width: 0.8,
            ),
          ),
        ),
        onChanged: (value) {
          ref.read(marketProvider.notifier).updateSearchQuery(value);
        },
      ),
    );
  }

  final projectProvider =
      StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
    final httpService = HttpService();
    final authService = AuthService();
    return ProjectNotifier(httpService, authService, ref);
  });

  Widget _buildNeedsList() {
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : white;

    if (_isNeedsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sellersNeeds.isEmpty) {
      return Center(
        child: Text(
          AppLocales.getTranslation('no_seller_needs', locale),
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _sellersNeeds.length,
      itemBuilder: (context, index) {
        final sellerNeed = _sellersNeeds[index];
        final cropName = sellerNeed['crop']['nom'] ?? 'Unknown Crop';
        final quantity = sellerNeed['quantity']?.toString() ?? '0';
        final createdAt =
            DateTime.tryParse(sellerNeed['createdAt'] ?? '') ?? DateTime.now();
        final requestDelay = sellerNeed['requestDelay'] ?? 7;
        final expirationDate = createdAt.add(Duration(days: requestDelay));
        final now = DateTime.now();
        final daysLeft = expirationDate.difference(now).inDays;

        if (daysLeft <= 0) return const SizedBox.shrink();

        return Card(
          elevation: 3,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  cropName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                AppLocales.getTranslation('days_left', locale,
                    placeholders: {'days': daysLeft.toString()}),
                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppLocales.getTranslation('units', locale,
                      placeholders: {'quantity': quantity}),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => Achat(product: produc,),
              //         ),
              //       );
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.green,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       padding: const EdgeInsets.symmetric(vertical: 10),
              //     ),
              //     child: Text(
              //       AppLocales.getTranslation('buy_now', locale),
              //       style: const TextStyle(
              //         color: Colors.white,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(projectProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black87 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final tabColor = isDarkMode ? Colors.white : Colors.green;
    final marketState = ref.watch(marketProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppLocales.getTranslation('market_place', locale),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: green,
          indicatorColor: green,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: AppLocales.getTranslation('products', locale),
              icon: const Icon(Icons.grid_view),
            ),
            Tab(
              text: AppLocales.getTranslation('needs', locale),
              icon: const Icon(Icons.category),
            ),
          ],
        ),
      ),
      drawer: CustomDrawer(
        connectedUser: projectState.connectedUser,
        backgroundColor: backgroundColor,
        textColor: textColor,
        isDarkMode: isDarkMode,
        onLogout: _logout,
        onShowThemeBottomSheet: _showThemeBottomSheet,
        onShowLanguageBottomSheet: _showLanguageBottomSheet,
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              backgroundColor: lightGreen,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddsellersNeed(),
                  ),
                ).then((_) => _fetchSellerNeeds());
              },
              child: const Icon(
                Icons.add,
                color: green,
              ),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: marketState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProductGrid(context, marketState),
              ),
            ],
          ),
          _buildNeedsList(),
        ],
      ),
    );
  }
}
