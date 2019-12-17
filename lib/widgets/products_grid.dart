import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../items/product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {

  final bool showFavs;

  ProductsGrid(this.showFavs);


  @override
  Widget build(BuildContext context) {
    final productsData =
        Provider.of<ProductsProvider>(context); //this is the listner
    final products = showFavs ? productsData.favoritesProducts : productsData.products;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: products[index],
          child: ProductItem(),
        );
      },
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3 / 2,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
    );
  }
}
