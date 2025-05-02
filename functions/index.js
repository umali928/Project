const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.cleanupWishlistOnProductDelete = functions.firestore
  .document('products/{productId}')
  .onDelete(async (snap, context) => {
    const deletedProductId = context.params.productId;

    const usersSnapshot = await admin.firestore().collection('users').get();
    const batch = admin.firestore().batch();

    for (const userDoc of usersSnapshot.docs) {
      const wishlistRef = userDoc.ref.collection('wishlist');
      const wishlistItems = await wishlistRef.where('productId', '==', deletedProductId).get();

      wishlistItems.forEach(doc => {
        batch.delete(doc.ref);
      });
    }

    return batch.commit();
  });
