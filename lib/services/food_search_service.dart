import 'package:openfoodfacts/openfoodfacts.dart';

class FoodSearchService {
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    final configuration = ProductSearchQueryConfiguration(
      parametersList: [
        SearchTerms(terms: [query]),
      ],
      version: ProductQueryVersion.v3,
    );

    try {
      final result = await OpenFoodAPIClient.searchProducts(
        User(userId: '', password: ''), // Anonymous user
        configuration,
      );

      return result.products ?? [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    if (barcode.isEmpty) return null;

    final configuration = ProductQueryConfiguration(
      barcode,
      version: ProductQueryVersion.v3,
    );

    try {
      final result = await OpenFoodAPIClient.getProductV3(configuration);
      return result.product;
    } catch (e) {
      print('Error fetching product by barcode: $e');
      return null;
    }
  }
}
