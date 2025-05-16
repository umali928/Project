import 'package:flutter/material.dart';
import 'package:lspu/navigation_drawer.dart' as custom;
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerViewSales extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Sales Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      drawer: custom.NavigationDrawer(),
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
                final items =
                    (order.data() as Map<String, dynamic>)['items'] as List;
                return items.any((item) => item['sellerId'] == sellerId);
              }).toList();

              // Calculate total sales and orders
              double totalSales = filteredOrders.fold(0.0, (sum, order) {
                final items =
                    (order.data() as Map<String, dynamic>)['items'] as List;
                final sellerItems =
                    items.where((item) => item['sellerId'] == sellerId);
                return sum +
                    sellerItems.fold(0.0, (itemSum, item) {
                      return itemSum + (item['price'] * item['quantity']);
                    });
              });

              int totalOrders = filteredOrders.length;

              // Get top products by quantity sold
              final productQuantities = <String, int>{};
              final productImages = <String, String>{};
              final productPrices = <String, double>{};

              for (var order in filteredOrders) {
                final items =
                    (order.data() as Map<String, dynamic>)['items'] as List;
                for (var item in items) {
                  if (item['sellerId'] == sellerId) {
                    final productName =
                        item['productName'] ?? 'Unknown Product';
                    final quantity = item['quantity'] as int;
                    final price = (item['price'] as num).toDouble();
                    final imageUrl =
                        item['imageUrl'] ?? 'assets/defaultprofile.jpg';

                    productQuantities.update(
                        productName, (existing) => existing + quantity,
                        ifAbsent: () => quantity);
                    productPrices[productName] = price;
                    // Update image only if not already set or if we have a new image
                    if (!productImages.containsKey(productName)) {
                      productImages[productName] = imageUrl;
                    }
                  }
                }
              }

              // Sort products by quantity sold
              final sortedProductsByQuantity = productQuantities.entries
                  .toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topProductByQuantity = sortedProductsByQuantity.isNotEmpty
                  ? sortedProductsByQuantity.first.key
                  : 'No products';

              // Prepare weekly sales data
              final now = DateTime.now();
              final weekAgo = now.subtract(Duration(days: 7));
              final dailySales = List<double>.filled(7, 0);
              final dailyQuantities = List<int>.filled(7, 0);

              for (var order in filteredOrders) {
                final orderDate = (order.data()
                    as Map<String, dynamic>)['orderDate'] as Timestamp?;
                if (orderDate != null) {
                  final date = orderDate.toDate();
                  if (date.isAfter(weekAgo)) {
                    final items =
                        (order.data() as Map<String, dynamic>)['items'] as List;
                    final sellerItems =
                        items.where((item) => item['sellerId'] == sellerId);
                    final dayIndex = date.weekday - 1; // Monday = 0, Sunday = 6

                    // Calculate sales amount
                    dailySales[dayIndex] += sellerItems.fold(0.0, (sum, item) {
                      return sum + (item['price'] * item['quantity']);
                    });

                    // Calculate quantities
                    dailyQuantities[dayIndex] +=
                        sellerItems.fold(0, (sum, item) {
                      return sum + (item['quantity'] as int);
                    });
                  }
                }
              }

              final chartData = [
                SalesData('Mon', dailySales[0], dailyQuantities[0]),
                SalesData('Tue', dailySales[1], dailyQuantities[1]),
                SalesData('Wed', dailySales[2], dailyQuantities[2]),
                SalesData('Thu', dailySales[3], dailyQuantities[3]),
                SalesData('Fri', dailySales[4], dailyQuantities[4]),
                SalesData('Sat', dailySales[5], dailyQuantities[5]),
                SalesData('Sun', dailySales[6], dailyQuantities[6]),
              ];

              final maxY = (dailySales.reduce((a, b) => a > b ? a : b) * 1.2)
                  .ceilToDouble();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWideScreen = constraints.maxWidth > 600;
                  final double graphHeight = isWideScreen ? 300 : 220;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sales Overview',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your sales performance summary',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Responsive Stats Cards
                        if (isWideScreen)
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.attach_money_rounded,
                                  iconColor: Colors.green[400],
                                  title: 'Total Sales',
                                  value: '₱${totalSales.toStringAsFixed(2)}',
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.shopping_bag_rounded,
                                  iconColor: Colors.purple[400],
                                  title: 'Total Orders',
                                  value: '$totalOrders',
                                  context: context,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.star_rounded,
                                  iconColor: Colors.amber[600],
                                  title: 'Top Product',
                                  value: topProductByQuantity,
                                  context: context,
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildStatCard(
                                icon: Icons.attach_money_rounded,
                                iconColor: Colors.green[400],
                                title: 'Total Sales',
                                value: '₱${totalSales.toStringAsFixed(2)}',
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildStatCard(
                                icon: Icons.shopping_bag_rounded,
                                iconColor: Colors.purple[400],
                                title: 'Total Orders',
                                value: '$totalOrders',
                                context: context,
                              ),
                              const SizedBox(height: 16),
                              _buildStatCard(
                                icon: Icons.star_rounded,
                                iconColor: Colors.amber[600],
                                title: 'Top Product (Qty)',
                                value: topProductByQuantity,
                                context: context,
                              ),
                            ],
                          ),
                        const SizedBox(height: 32),

                        // Sales Graph using fl_chart
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly Sales (Last 7 Days)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: graphHeight,
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: maxY > 0
                                          ? maxY
                                          : 3000, // Default to 3000 if no sales
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          tooltipPadding:
                                              const EdgeInsets.all(8.0),
                                          tooltipMargin: 8.0,
                                          getTooltipItem: (group, groupIndex,
                                              rod, rodIndex) {
                                            final day =
                                                chartData[groupIndex].day;
                                            final amount = rod.toY.toInt();
                                            final qty =
                                                chartData[groupIndex].quantity;
                                            return BarTooltipItem(
                                              '$day\n₱$amount\n$qty sold',
                                              const TextStyle(
                                                  color: Colors.white),
                                            );
                                          },
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: true,
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  chartData[value.toInt()].day,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                            reservedSize: 30,
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                '₱${value.toInt()}',
                                                style: GoogleFonts.roboto(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                            reservedSize: 40,
                                            interval:
                                                maxY > 0 ? (maxY / 5) : 1000,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      gridData: FlGridData(
                                        show: true,
                                        drawVerticalLine: false,
                                        horizontalInterval:
                                            maxY > 0 ? (maxY / 5) : 1000,
                                        getDrawingHorizontalLine: (value) {
                                          return FlLine(
                                            color: Colors.grey[200],
                                            strokeWidth: 1,
                                          );
                                        },
                                      ),
                                      borderData: FlBorderData(
                                        show: false,
                                      ),
                                      barGroups: chartData
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final data = entry.value;
                                        return BarChartGroupData(
                                          x: index,
                                          barRods: [
                                            BarChartRodData(
                                              toY: data.amount,
                                              color: Colors.blue[400],
                                              width: isWideScreen ? 24 : 16,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Sales Breakdown Section by Quantity
                        Text(
                          'Top Products by Quantity Sold',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (sortedProductsByQuantity.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No products sold yet',
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                          )
                        else
                          ...sortedProductsByQuantity
                              .take(3)
                              .map((entry) => _buildSalesItem(
                                    product: entry.key,
                                    price:
                                        '₱${(productPrices[entry.key] ?? 0).toStringAsFixed(2)}',
                                    quantity: '${entry.value} sold',
                                    image: productImages[entry.key] ??
                                        'assets/defaultprofile.jpg',
                                  )),
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

  Widget _buildStatCard({
    required IconData icon,
    required Color? iconColor,
    required String title,
    required String value,
    required BuildContext context,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesItem({
    required String product,
    required String price,
    required String quantity,
    required String image,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/defaultprofile.jpg',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              quantity,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.day, this.amount, this.quantity);
  final String day;
  final double amount;
  final int quantity;
}
