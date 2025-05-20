import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'SellerOrderdetails.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBbSQOdsCh7ImLhewcIhHUTcj9-1xbShQk",
        authDomain: "lspumart.firebaseapp.com",
        databaseURL:
            "https://lspumart-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "lspumart",
        storageBucket: "lspumart.firebasestorage.app",
        messagingSenderId: "533992551897",
        appId: "1:533992551897:web:d04a482ad131a0700815c8",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(OrderManagementApp());
}

class OrderManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.blue[800]),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.blue[800],
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? Center(child: Text('Please log in'))
          : OrderManagementPage(),
    );
  }
}

class OrderManagementPage extends StatelessWidget {
  const OrderManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "User not logged in",
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Management",
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      drawer: custom.NavigationDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('sellerInfo')
            .limit(1)
            .snapshots(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            );
          }
          if (!sellerSnapshot.hasData || sellerSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory_outlined,
                      size: 60, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    "No seller info found",
                    style: textTheme.titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Please complete your seller profile",
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          final sellerId = sellerSnapshot.data!.docs.first.id;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red[300]),
                      SizedBox(height: 16),
                      Text(
                        "Error loading orders",
                        style: textTheme.titleMedium
                            ?.copyWith(color: Colors.red[400]),
                      ),
                    ],
                  ),
                );
              }
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                );
              }

              // Filter orders locally to find those containing items from this seller
              final filteredOrders = orderSnapshot.data!.docs.where((order) {
                final items =
                    (order.data() as Map<String, dynamic>)['items'] as List;
                return items.any((item) => item['sellerId'] == sellerId);
              }).toList();

              if (filteredOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text(
                        "No orders yet",
                        style: textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Your products haven't been ordered yet",
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return FutureBuilder<List<OrderInfo>>(
                future: Future.wait(filteredOrders.map((doc) async {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderUserId = data['userId'];
                  String customerName = "Unknown";

                  if (orderUserId != null) {
                    final userSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(orderUserId)
                        .get();
                    if (userSnapshot.exists) {
                      customerName =
                          userSnapshot.data()!['fullName'] ?? "Unknown";
                    }
                  }

                  // Get order date (assuming it's stored as a Timestamp)
                  final orderDate = data['orderDate'] as Timestamp?;
                  final formattedDate = orderDate != null
                      ? "${orderDate.toDate().year}-${orderDate.toDate().month.toString().padLeft(2, '0')}-${orderDate.toDate().day.toString().padLeft(2, '0')}"
                      : "No date";

                  return OrderInfo(
                    orderId: doc.id,
                    customerName: customerName,
                    orderDate: formattedDate,
                    timestamp: orderDate?.toDate() ?? DateTime(0),
                  );
                }).toList()),
                builder: (context, asyncSnapshot) {
                  if (!asyncSnapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      ),
                    );
                  }

                  // Sort orders by date (newest first)
                  final orders = asyncSnapshot.data!;
                  orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Order History",
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: orders.length,
                            separatorBuilder: (context, index) => Divider(
                              height: 1,
                              color: Colors.grey[200],
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return OrderListItem(
                                order: order,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderDetailsPage(
                                        orderId: order.orderId,
                                        sellerId: sellerId,
                                        orderData: filteredOrders
                                            .firstWhere((doc) =>
                                                doc.id == order.orderId)
                                            .data() as Map<String, dynamic>,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class OrderInfo {
  final String orderId;
  final String customerName;
  final String orderDate;
  final DateTime timestamp;

  OrderInfo({
    required this.orderId,
    required this.customerName,
    required this.orderDate,
    required this.timestamp,
  });
}

class OrderListItem extends StatelessWidget {
  final OrderInfo order;
  final VoidCallback onTap;

  const OrderListItem({
    required this.order,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: theme.primaryColor,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order #${order.orderId.substring(0, 8)}",
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    order.customerName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            DateBadge(date: order.orderDate),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}

class DateBadge extends StatelessWidget {
  final String date;

  const DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        date,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
      ),
    );
  }
}
