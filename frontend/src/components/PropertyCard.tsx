import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { 
  Heart, 
  MapPin, 
  Wifi, 
  Utensils, 
  ShieldCheck, 
  Star, 
  ChevronLeft, 
  ChevronRight, 
  CreditCard 
} from 'lucide-react';
import { Property } from '../types';
import { useWishlist } from '../context/WishlistContext';

interface PropertyCardProps {
  property: Property;
  onBookClick?: (property: Property) => void;
}

export const PropertyCard: React.FC<PropertyCardProps> = ({ property, onBookClick }) => {
  const { isFavorite, toggleWishlist } = useWishlist();
  const [photoIndex, setPhotoIndex] = useState(0);

  const images = property.images && property.images.length > 0
    ? property.images
    : ['https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1000&q=80'];

  const favorited = isFavorite(property.id);

  const handleNextPhoto = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setPhotoIndex((prev) => (prev + 1) % images.length);
  };

  const handlePrevPhoto = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setPhotoIndex((prev) => (prev - 1 + images.length) % images.length);
  };

  const handleWishlistToggle = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    toggleWishlist(property);
  };

  return (
    <div className="group bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-xs hover:shadow-xl transition-all duration-300 flex flex-col h-full">
      
      {/* Image Carousel & Badges */}
      <div className="relative aspect-16/10 w-full overflow-hidden bg-slate-100">
        <img
          src={images[photoIndex]}
          alt={property.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
          loading="lazy"
        />

        {/* Carousel controls */}
        {images.length > 1 && (
          <>
            <button
              onClick={handlePrevPhoto}
              className="absolute left-2 top-1/2 -translate-y-1/2 w-7 h-7 rounded-full bg-white/80 hover:bg-white text-slate-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition shadow-sm"
              title="Previous Photo"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <button
              onClick={handleNextPhoto}
              className="absolute right-2 top-1/2 -translate-y-1/2 w-7 h-7 rounded-full bg-white/80 hover:bg-white text-slate-700 flex items-center justify-center opacity-0 group-hover:opacity-100 transition shadow-sm"
              title="Next Photo"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
            {/* Dots */}
            <div className="absolute bottom-2 left-1/2 -translate-x-1/2 flex gap-1">
              {images.map((_, idx) => (
                <div
                  key={idx}
                  className={`w-1.5 h-1.5 rounded-full transition-all ${
                    idx === photoIndex ? 'bg-white w-3' : 'bg-white/60'
                  }`}
                />
              ))}
            </div>
          </>
        )}

        {/* Top Badges */}
        <div className="absolute top-3 left-3 flex gap-1.5">
          {property.is_verified && (
            <span className="flex items-center gap-1 bg-emerald-600/95 backdrop-blur-xs text-white text-[11px] font-semibold px-2.5 py-1 rounded-full shadow-xs">
              <ShieldCheck className="w-3.5 h-3.5" />
              Verified
            </span>
          )}
          <span className="capitalize bg-slate-900/80 backdrop-blur-xs text-white text-[11px] font-medium px-2 py-1 rounded-full">
            {property.category === 'boys' ? 'Boys PG' : property.category === 'girls' ? 'Girls PG' : property.property_type}
          </span>
        </div>

        {/* Wishlist Heart */}
        <button
          onClick={handleWishlistToggle}
          className="absolute top-3 right-3 w-8 h-8 rounded-full bg-white/90 hover:bg-white backdrop-blur-xs flex items-center justify-center shadow-md transition-transform hover:scale-110"
          title={favorited ? 'Remove from wishlist' : 'Save to wishlist'}
        >
          <Heart
            className={`w-4 h-4 transition-colors ${
              favorited ? 'text-rose-500 fill-rose-500' : 'text-slate-600 hover:text-rose-500'
            }`}
          />
        </button>
      </div>

      {/* Content */}
      <div className="p-4 sm:p-5 flex flex-col flex-1">
        
        {/* Rating and Distance */}
        <div className="flex items-center justify-between text-xs text-slate-500 mb-1.5">
          <div className="flex items-center gap-1">
            <Star className="w-3.5 h-3.5 text-amber-400 fill-amber-400" />
            <span className="font-semibold text-slate-800">{property.rating || 4.5}</span>
            <span>({property.review_count || 12})</span>
          </div>
          {property.distance_to_campus && (
            <span className="text-blue-600 font-medium bg-blue-50 px-2 py-0.5 rounded">
              {property.distance_to_campus}
            </span>
          )}
        </div>

        {/* Title */}
        <Link to={`/place/${property.id}`} className="group-hover:text-blue-600 transition-colors">
          <h3 className="font-semibold text-slate-900 text-base line-clamp-1">
            {property.name}
          </h3>
        </Link>

        {/* Address */}
        <p className="flex items-center gap-1 text-xs text-slate-500 mt-1 line-clamp-1">
          <MapPin className="w-3.5 h-3.5 shrink-0 text-slate-400" />
          {property.address}
        </p>

        {/* Amenities Highlights */}
        <div className="flex items-center gap-2 mt-3 text-xs text-slate-600">
          {property.food_available && (
            <span className="flex items-center gap-1 bg-slate-100 px-2 py-1 rounded-md text-[11px]">
              <Utensils className="w-3 h-3 text-slate-500" />
              Food Incl.
            </span>
          )}
          {property.wifi_available && (
            <span className="flex items-center gap-1 bg-slate-100 px-2 py-1 rounded-md text-[11px]">
              <Wifi className="w-3 h-3 text-slate-500" />
              High-Speed Wi-Fi
            </span>
          )}
          <span className={`text-[11px] px-2 py-1 rounded-md ${
            property.rooms_available ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700'
          }`}>
            {property.rooms_available ? 'Available' : 'Fast Filling'}
          </span>
        </div>

        <div className="mt-auto pt-4 border-t border-slate-100 flex items-center justify-between">
          <div>
            <div className="flex items-baseline gap-1">
              <span className="text-lg font-bold text-slate-900">
                {property.rent > 0 ? `₹${property.rent.toLocaleString()}` : 'Free/Govt'}
              </span>
              {property.rent > 0 && <span className="text-xs text-slate-500">/mo</span>}
            </div>
            <span className="text-[11px] text-slate-500 block">
              Token: ₹{property.token.toLocaleString()}
            </span>
          </div>

          <div className="flex items-center gap-2">
            {onBookClick && (
              <button
                onClick={() => onBookClick(property)}
                className="flex items-center gap-1 px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs transition"
              >
                <CreditCard className="w-3.5 h-3.5" />
                Book
              </button>
            )}
            <Link
              to={`/place/${property.id}`}
              className="px-3 py-1.5 rounded-lg text-xs font-medium border border-slate-300 hover:border-blue-600 hover:text-blue-600 text-slate-700 transition"
            >
              Details
            </Link>
          </div>
        </div>

      </div>

    </div>
  );
};
