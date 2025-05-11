import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SellerOrderdetails.dart';

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

  runApp(DashboardApp());
}

class DashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null
          ? Center(child: Text('Please log in'))
          : DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    // ignore: unused_local_variable
    final screenWidth = MediaQuery.of(context).size.width;

    if (userId == null) {
      return Center(child: Text("User not logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: custom.NavigationDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              "Seller-Dashboard",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Spacer(),
            Text(
              "LSPUMART",
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(userId)
            .collection('sellerInfo')
            .limit(1)
            .snapshots(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!sellerSnapshot.hasData || sellerSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("No seller info found."));
          }

          final sellerId = sellerSnapshot.data!.docs.first.id;
          print("Current seller ID: $sellerId");

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Home / Dashboard",
                      style: GoogleFonts.poppins(color: Colors.black54)),
                  SizedBox(height: 10),

                  // Dashboard cards with real data
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('orders').snapshots(),
                    builder: (context, orderSnapshot) {
                      if (orderSnapshot.hasError) {
                        return Center(child: Text("Error loading orders"));
                      }
                      if (orderSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      // Filter orders locally to find those containing items from this seller
                      final filteredOrders =
                          orderSnapshot.data!.docs.where((order) {
                        final items = (order.data()
                            as Map<String, dynamic>)['items'] as List;
                        return items
                            .any((item) => item['sellerId'] == sellerId);
                      }).toList();

                      // Calculate total orders and sales
                      int totalOrders = filteredOrders.length;
                      double totalSales =
                          filteredOrders.fold(0.0, (sum, order) {
                        final items = (order.data()
                            as Map<String, dynamic>)['items'] as List;
                        final sellerItems =
                            items.where((item) => item['sellerId'] == sellerId);
                        return sum +
                            sellerItems.fold(0.0, (itemSum, item) {
                              return itemSum +
                                  (item['price'] * item['quantity']);
                            });
                      });

                      return Column(
                        children: [
                          DashboardCard(
                              title: "Total Orders",
                              value: "$totalOrders",
                              icon: Icons.shopping_bag,
                              color: Colors.green),
                          DashboardCard(
                              title: "Total Sell",
                              value: "₱${totalSales.toStringAsFixed(2)}",
                              icon: Icons.account_balance_wallet,
                              color: Colors.redAccent),
                        ],
                      );
                    },
                  ),

                  // Total Products card
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('products')
                        .where('sellerId', isEqualTo: sellerId)
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      int totalProducts = 0;
                      if (productSnapshot.hasData) {
                        totalProducts = productSnapshot.data!.docs.length;
                      }

                      return DashboardCard(
                          title: "Total Products",
                          value: "$totalProducts",
                          icon: Icons.category,
                          color: Colors.purple);
                    },
                  ),

                  SizedBox(height: 20),
                  OrderSummary(sellerId: sellerId),
                  ReviewOrders(sellerId: sellerId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(value,
                      style: GoogleFonts.roboto(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  final String sellerId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrderSummary({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders').snapshots(),
      builder: (context, orderSnapshot) {
        if (orderSnapshot.hasError) {
          return Center(child: Text("Error loading orders"));
        }
        if (orderSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Filter orders for this seller
        final filteredOrders = orderSnapshot.data!.docs.where((order) {
          final items = (order.data() as Map<String, dynamic>)['items'] as List;
          return items.any((item) => item['sellerId'] == sellerId);
        }).toList();

        // Calculate status counts
        int pending = 0;
        int shipped = 0;
        int delivered = 0;
        int total = filteredOrders.length;

        for (var order in filteredOrders) {
          final items = (order.data() as Map<String, dynamic>)['items'] as List;
          for (var item in items) {
            if (item['sellerId'] == sellerId) {
              switch (item['status']) {
                case 'Pending':
                  pending++;
                  break;
                case 'Shipped':
                  shipped++;
                  break;
                case 'Delivered':
                  delivered++;
                  break;
              }
            }
          }
        }

        return Card(
          elevation: 3,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order Summary",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                OrderProgress(
                    title: "Pending Orders",
                    percent: total > 0 ? pending / total : 0,
                    color: Colors.orange,
                    orders: "$pending/$total Orders"),
                OrderProgress(
                    title: "Shipped Orders",
                    percent: total > 0 ? shipped / total : 0,
                    color: Colors.purple,
                    orders: "$shipped/$total Orders"),
                OrderProgress(
                    title: "Delivered Orders",
                    percent: total > 0 ? delivered / total : 0,
                    color: Colors.green,
                    orders: "$delivered/$total Orders"),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OrderProgress extends StatelessWidget {
  final String title;
  final double percent;
  final Color color;
  final String orders;

  OrderProgress({
    required this.title,
    required this.percent,
    required this.color,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                  value: percent,
                  color: color,
                  backgroundColor: Colors.grey[300]),
              SizedBox(height: 4),
              Text(orders,
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}

class ReviewOrders extends StatelessWidget {
  final String sellerId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReviewOrders({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, orderSnapshot) {
        if (orderSnapshot.hasError) {
          return Center(child: Text("Error loading orders"));
        }
        if (orderSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Filter orders for this seller and limit to 5
        final filteredOrders = orderSnapshot.data!.docs
            .where((order) {
              final items =
                  (order.data() as Map<String, dynamic>)['items'] as List;
              return items.any((item) => item['sellerId'] == sellerId);
            })
            .take(5)
            .toList();

        if (filteredOrders.isEmpty) {
          return Center(child: Text("No recent orders found"));
        }

        return Card(
          color: Colors.white,
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Recent Orders",
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...filteredOrders.map((orderDoc) {
                  final order = orderDoc.data() as Map<String, dynamic>;
                  final items = order['items'] as List;
                  final sellerItems = items
                      .where((item) => item['sellerId'] == sellerId)
                      .toList();
                  final firstItem = sellerItems.first;
                  final orderDate = order['orderDate'] as Timestamp?;
                  final formattedDate = orderDate != null
                      ? "${orderDate.toDate().month}/${orderDate.toDate().day}/${orderDate.toDate().year}"
                      : "No date";

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsPage(
                            orderId: orderDoc.id,
                            sellerId: sellerId,
                            orderData: order,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              formattedDate,
                              style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.035),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Text(
                              firstItem['productName'] ?? 'No product name',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(firstItem['status'])
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              firstItem['status'],
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(firstItem['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Shipped':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
