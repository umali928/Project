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

    if (userId == null) {
      return Center(child: Text("User not logged in"));
    }
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Order Management",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
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
            return Center(child: CircularProgressIndicator());
          }
          if (!sellerSnapshot.hasData || sellerSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("No seller info found."));
          }

          final sellerId = sellerSnapshot.data!.docs.first.id;
          print("Current seller ID: $sellerId");

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.hasError) {
                print("Error fetching orders: ${orderSnapshot.error}");
                return Center(child: Text("Error loading orders"));
              }
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Filter orders locally to find those containing items from this seller
              final filteredOrders = orderSnapshot.data!.docs.where((order) {
                final items =
                    (order.data() as Map<String, dynamic>)['items'] as List;
                return items.any((item) => item['sellerId'] == sellerId);
              }).toList();

              if (filteredOrders.isEmpty) {
                print("No orders found for sellerId: $sellerId");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("No orders with your products found.", 
                          style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              print(
                  "Found ${filteredOrders.length} orders for seller $sellerId");

              return FutureBuilder<List<OrderInfo>>(
                future: Future.wait(filteredOrders.map((doc) async {
                  final data = doc.data() as Map<String, dynamic>;
                  print("Order data: $data");
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
                    return Center(child: CircularProgressIndicator());
                  }

                  // Sort orders by date (newest first)
                  final orders = asyncSnapshot.data!;
                  orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return Padding(
                    
                    padding: const EdgeInsets.all(16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: constraints.maxWidth),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Your Orders",
                                        style: GoogleFonts.poppins(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 10),
                                    ...orders.map((order) => InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    OrderDetailsPage(
                                                  orderId: order.orderId,
                                                  sellerId: sellerId,
                                                  orderData: filteredOrders
                                                          .firstWhere((doc) =>
                                                              doc.id ==
                                                              order.orderId)
                                                          .data()
                                                      as Map<String, dynamic>,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      order.orderId,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontSize:
                                                                  screenWidth *
                                                                      0.035),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      order.customerName,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize:
                                                            screenWidth * 0.035,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  DateBadge(
                                                      date: order.orderDate),
                                                ],
                                              )),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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

class DateBadge extends StatelessWidget {
  final String date;

  const DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        date,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
