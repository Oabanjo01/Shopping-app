import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isLoading = false;
  // @override
  // void initState() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   context.read<Products>().getAndSetProducts().then((value) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
    // Here they said most times, context does not work in init state(altough it does for me sha), so there ae two methods of going over this
    // Using Future.delayed(Duration.zero).then(() {
    //  context.read<Products>().getAndSetProducts();
    // })
    // Future.delayed makes the widget to run initially before calling this fxn, does this insanely fast too
    // kind of a hack
    // Using didChangedependencies (will run after the widget has ben fully initialised), runs more often
    @override
    void didChangeDependencies() {
      setState(() {
      _isLoading = true;
    });
    context.read<Products>().getAndSetProducts().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
      super.didChangeDependencies();
    }
  //   super.initState();
  // }
  var _showOnlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text('Only Favorites'),
                    value: FilterOptions.Favorites,
                  ),
                  PopupMenuItem(
                    child: Text('Show All'),
                    value: FilterOptions.All,
                  ),
                ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
                  child: ch,
                  value: cart.itemCount.toString(),
                ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading == true ? Center(child: CircularProgressIndicator()) : ProductsGrid(_showOnlyFavorites),
    );
  }
}
