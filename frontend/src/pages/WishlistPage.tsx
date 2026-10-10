import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Heart, Building, ArrowRight, Trash2 } from 'lucide-react';
import { useWishlist } from '../context/WishlistContext';
import { PropertyCard } from '../components/PropertyCard';
import { BookingModal } from '../components/BookingModal';
import { Property } from '../types';

export const WishlistPage: React.FC = () => {
  const { wishlist, removeFromWishlist } = useWishlist();
  const [selectedBookingProperty, setSelectedBookingProperty] = useState<Property | null>(null);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900 flex items-center gap-2.5">
            <Heart className="w-7 h-7 text-rose-500 fill-rose-500" />
            Saved Wishlist
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Properties you've bookmarked for your upcoming college semester.
          </p>
        </div>

        {wishlist.length > 0 && (
          <span className="text-xs font-semibold text-slate-600 bg-slate-100 px-3 py-1 rounded-full">
            {wishlist.length} {wishlist.length === 1 ? 'Stay' : 'Stays'} Saved
          </span>
        )}
      </div>

      {wishlist.length === 0 ? (
        <div className="bg-white rounded-3xl border border-slate-200 p-12 text-center max-w-md mx-auto my-12 shadow-xs">
          <div className="w-16 h-16 rounded-full bg-rose-50 text-rose-500 flex items-center justify-center mx-auto mb-4">
            <Heart className="w-8 h-8" />
          </div>
          <h3 className="font-bold text-slate-900 text-lg mb-1">Your wishlist is empty</h3>
          <p className="text-xs text-slate-500 mb-6 leading-relaxed">
            Click the heart icon on any accommodation card while browsing to save your favorite rooms here.
          </p>
          <Link
            to="/"
            className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-xl shadow-md transition"
          >
            <span>Explore Accommodations</span>
            <ArrowRight className="w-4 h-4" />
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {wishlist.map((property) => (
            <PropertyCard
              key={property.id}
              property={property}
              onBookClick={(p) => setSelectedBookingProperty(p)}
            />
          ))}
        </div>
      )}

      {selectedBookingProperty && (
        <BookingModal
          property={selectedBookingProperty}
          onClose={() => setSelectedBookingProperty(null)}
          onSuccess={(b) => {
            setSelectedBookingProperty(null);
            alert(`Token payment submitted! Booking ID: ${b.id}`);
          }}
        />
      )}

    </div>
  );
};
