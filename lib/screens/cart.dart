import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:casucal/models/cart.dart';
import 'package:casucal/models/item.dart';
import 'package:casucal/screens/casu_cal_icons.dart';

class MyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CasuCal',
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            CartTotal(),
            Expanded(
              child: CartList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddItemButton(),
    );
  }
}

class CartTotal extends StatefulWidget {
  @override
  _CartTotal createState() => _CartTotal();
}

class _CartTotal extends State<CartTotal> {
  @override
  Widget build(BuildContext context) {
    var cart = context.watch<CartModel>();
    final double rowHeight = 60.0;

//    String hexString = "45a3df"; //color code
    var priceFormatter = NumberFormat('#,###');

    return Container(
      color: Colors.pinkAccent[100],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: rowHeight,
            child: Center(
              child: Text(
                'Total: ¥${priceFormatter.format(cart.sumDiscountedPrice).toString()}-',
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartList extends StatefulWidget {
  @override
  _CartList createState() => _CartList();
}

class _CartList extends State<CartList> {
  @override
  void initState() {
    super.initState();
    // var cart = context.read<CartModel>();
    // cart.add(
    //   Item(
    //     category: "other",
    //     price: 0,
    //     discount: 0,
    //     discount2: 0,
    //     isPicked: true,
    //     priceController: TextEditingController(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    // CartModelの現在の状態を取得し、CartModelの状態が変化したら
    // このWidgetをリビルドするようFlutterに伝える。
    var cart = context.watch<CartModel>();

    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ObjectKey(cart.items[index]),
          onDismissed: (direction) {
            cart.del(index);
          },
          background: Container(color: Colors.pink),
          child: _ItemRowStatefullWidget(context: context, index: index),
        );
      },
    );
  }
}

class _AddItemButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cart = context.read<CartModel>();

    return FloatingActionButton(
      backgroundColor: Colors.pink[500],
      onPressed: () {
        cart.add(
          Item(
            category: "other",
            price: 0,
            discount: 0,
            discount2: 0,
            isPicked: true,
            priceController: TextEditingController(),
          ),
        );
      },
      child: Icon(
        Icons.add_shopping_cart_rounded,
        size: 30,
      ),
    );
  }
}

class _ItemRowStatefullWidget extends StatefulWidget {
  final BuildContext context;
  final int index;

  _ItemRowStatefullWidget({
    required this.context,
    required this.index,
  });

  @override
  _ItemRow createState() => _ItemRow(
        context: context,
        index: index,
      );
}

class _ItemRow extends State<_ItemRowStatefullWidget> {
  final int index;
  final BuildContext context;
  List<DropdownMenuItem<int>> _discountList = [];

  _ItemRow({
    required this.context,
    required this.index,
  });

  @override
  void initState() {
    super.initState();
    setDiscountList();
  }

  @override
  Widget build(BuildContext context) {
    var cart = context.read<CartModel>();
    final Size size = MediaQuery.of(context).size;
    final double rowHeight = 50.0;
    double fontSize = 20.0;

    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 0.1 * size.width,
            height: rowHeight,
            child: IconButton(
              icon: Icon(iconMap[cart.items[index].category]),
              onPressed: () {
                cart.changeItemCategory(context, cart.items[index]);
              },
            ),
          ),
          Container(
            width: 0.36 * size.width,
            height: rowHeight,
            child: TextFormField(
              controller: cart.items[index].priceController,
              enabled: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                ThousandsFormatter(),
              ],
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
              ),
              decoration: InputDecoration(
                prefixText: '¥',
                suffixText: '-',
                border: OutlineInputBorder(),
              ),
              onChanged: (price) {
                cart.setItemPrice(cart.items[index], price);
              },
            ),
          ),
          SizedBox(
            width: 0.02 * size.width,
          ),
          Container(
            width: 0.2 * size.width,
            height: rowHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.grey.shade500,
                style: BorderStyle.solid,
                width:1,
              ),
            ),
            child: DropdownButtonFormField<int>(
              value: cart.items[index].discount,
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 36,
              elevation: 4,
              style: TextStyle(
                color: Colors.red,
              ),
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
              ),
              onChanged: (discount) {
                cart.setItemDiscount(cart.items[index], discount);
              },
              items: _discountList,
            ),
          ),
          SizedBox(
            width: 0.02 * size.width,
          ),
          Container(
            width: 0.2 * size.width,
            height: rowHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.grey.shade500,
                style: BorderStyle.solid,
                width:1,
              ),
            ),
            child: DropdownButtonFormField<int>(
              value: cart.items[index].discount2,
              // icon: const Icon(Icons.arrow_drop_down),
              iconSize: 36,
              elevation: 4,
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
              ),
              style: TextStyle(
                color: Colors.red,
              ),
              onChanged: (discount) {
                cart.setItemDiscount2(cart.items[index], discount);
              },
              items: _discountList,
            ),
          ),
          Container(
            width: 0.1 * size.width,
            height: rowHeight,
            child: IconButton(
              icon: Icon(
                cart.items[index].isPicked
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    cart.items[index].isPicked ? Colors.pinkAccent[100] : null,
              ),
              onPressed: () {
                cart.changePickUp(cart.items[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void setDiscountList() {
    double fontSize = 20.0;
    var _font = 'Lobster';
    _discountList
      ..add(DropdownMenuItem(
        child: Text('0% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 0,
      ))
      ..add(DropdownMenuItem(
        child: Text('10% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 10,
      ))
      ..add(DropdownMenuItem(
        child: Text('15% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 15,
      ))
      ..add(DropdownMenuItem(
        child: Text('20% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 20,
      ))
      ..add(DropdownMenuItem(
        child: Text('30% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 30,
      ))
      ..add(DropdownMenuItem(
        child: Text('40% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 40,
      ))
      ..add(DropdownMenuItem(
        child: Text('50% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 50,
      ))
      ..add(DropdownMenuItem(
        child: Text('60% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 60,
      ))
      ..add(DropdownMenuItem(
        child: Text('70% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 70,
      ))
      ..add(DropdownMenuItem(
        child: Text('80% OFF',
            style: TextStyle(fontFamily: _font, fontSize: fontSize)),
        value: 80,
      ));
  }

  static const iconMap = {
    'tops': CasuCal.tops,
    'pants': CasuCal.pants,
    'skirt': CasuCal.skirt,
    'dress': CasuCal.dress,
    'outer': CasuCal.outer,
    'inner': CasuCal.inner,
    'suite': CasuCal.suite,
    'shoes': CasuCal.shoes,
    'other': Icons.card_giftcard_rounded,
  };
}
