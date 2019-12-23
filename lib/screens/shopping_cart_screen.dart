import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart' show Cart;
import '../items/cart_item.dart';
import '../models/order.dart';

class ShoppingCartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _ShoppingCartScreenState createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartProvider.totalAmount}',
                      style: TextStyle(
                          color:
                              Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartProvider: cartProvider),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) => CartItem(
                cartProvider.items.values.toList()[index].id,
                cartProvider.items.keys.toList()[index],
                cartProvider.items.values.toList()[index].price,
                cartProvider.items.values.toList()[index].quantity,
                cartProvider.items.values.toList()[index].title,
              ),
              itemCount: cartProvider.itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartProvider,
  }) : super(key: key);

  final Cart cartProvider;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return  FlatButton(
      child: _isLoading ? CircularProgressIndicator() : const Text('Place Order'),
      textColor: Theme.of(context).primaryColor,
      onPressed: widget.cartProvider.totalAmount <= 0 || _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Order>(context, listen: false).addOrder(
                  widget.cartProvider.items.values.toList(),
                  widget.cartProvider.totalAmount);
              setState(() {
                _isLoading = false;
              });
              widget.cartProvider.clear();
            },
    );
  }
}
