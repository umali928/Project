// wishlist_button.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class WishlistButton extends StatefulWidget {
  final Map<String, dynamic> data;

  const WishlistButton({Key? key, required this.data}) : super(key: key);

  static final Map<String, bool> _wishlistStates = {};
  static Function()? refreshCallback;

  static void updateWishlistState(String productId, bool value) {
    _wishlistStates[productId] = value;
    refreshCallback?.call();
  }

  @override
  _WishlistButtonState createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  bool? isWishlisted;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkIfWishlisted();
  }

  Future<void> _checkIfWishlisted() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    final productId = widget.data['productId'];

    final snapshot = await wishlistRef
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    final result = snapshot.docs.isNotEmpty;

    setState(() {
      isWishlisted = result;
      loading = false;
      WishlistButton._wishlistStates[productId] = result;
    });
  }

  void toggleWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final productId = widget.data['productId'];
    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('wishlist');

    if (isWishlisted == false) {
      await wishlistRef.add({
        'productId': productId,
        'productName': widget.data['productName'],
        'price': widget.data['price'],
        'imageUrl': widget.data['imageUrl'],
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      final snapshot =
          await wishlistRef.where('productId', isEqualTo: productId).get();

      for (var doc in snapshot.docs) {
        await wishlistRef.doc(doc.id).delete();
      }
    }

    setState(() {
      isWishlisted = !isWishlisted!;
      WishlistButton.updateWishlistState(productId, isWishlisted!);
    });
    
    // Trigger refresh across all screens
    if (WishlistButton.refreshCallback != null) {
      WishlistButton.refreshCallback!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading || isWishlisted == null) {
      return Container(
        padding: EdgeInsets.all(8),
        child: CircularProgressIndicator(),
      );
    }

    return ElevatedButton(
      onPressed: toggleWishlist,
      style: ElevatedButton.styleFrom(
        backgroundColor: isWishlisted! ? Colors.grey[300] : Color(0xFF651D32),
        foregroundColor: isWishlisted! ? Colors.black : Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isWishlisted! ? 'Remove' : 'Add',
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}