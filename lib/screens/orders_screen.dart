import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart' show Order;
import '../items/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const String routeName = '/order';
  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Order>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Order>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              //Error handling
              return Center(
                child: Text('An error occured'),
              );
            } else {
              return Consumer<Order>(
                builder: (ctx, orderData, child) => orderData.orders.isEmpty
                    ? Center(
                        child: Text('Place some order now!'),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, index) =>
                            OrderItem(orderData.orders[index]),
                        itemCount: orderData.orders.length,
                      ),
              );
            }
          }
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
