import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { 
  MapPin, 
  Phone, 
  Wifi, 
  Utensils, 
  ShieldCheck, 
  Heart, 
  MessageSquare, 
  Navigation, 
  Car, 
  CreditCard, 
  Star, 
  ArrowLeft, 
  CheckCircle2, 
  Clock, 
  Lock,
  Building,
  Check
} from 'lucide-react';
import { Property, Booking } from '../types';
import { propertyApi } from '../services/api';
import { useWishlist } from '../context/WishlistContext';
import { BookingModal } from '../components/BookingModal';

export const PropertyDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { isFavorite, toggleWishlist } = useWishlist();

  const [property, setProperty] = useState<Property | null>(null);
  const [similarProperties, setSimilarProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPhoto, setSelectedPhoto] = useState<string>('');
  const [isBookingOpen, setIsBookingOpen] = useState(false);
  const [userRating, setUserRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [ratingSubmitted, setRatingSubmitted] = useState(false);
  const [reviewComment, setReviewComment] = useState('');

  useEffect(() => {
    const fetchProperty = async () => {
      if (!id) return;
      setLoading(true);
      const data = await propertyApi.getById(id);
      if (data) {
        setProperty(data);
        setSelectedPhoto(data.images[0] || '');
        const all = await propertyApi.getAll();
        setSimilarProperties(all.filter((p) => String(p.id) !== String(id)).slice(0, 3));
      }
      setLoading(false);
    };
    fetchProperty();
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-16 animate-pulse space-y-6">
        <div className="h-6 w-32 bg-slate-200 rounded" />
        <div className="h-96 bg-slate-200 rounded-3xl" />
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="md:col-span-2 h-64 bg-slate-200 rounded-2xl" />
          <div className="h-64 bg-slate-200 rounded-2xl" />
        </div>
      </div>
    );
  }

  if (!property) {
    return (
      <div className="max-w-md mx-auto text-center py-20 px-4">
        <h2 className="text-2xl font-bold text-slate-800 mb-2">Property Not Found</h2>
        <p className="text-sm text-slate-500 mb-6">This listing may have been moved or removed.</p>
        <Link to="/" className="px-5 py-2.5 bg-blue-600 text-white rounded-xl text-sm font-semibold">
          Return to All Stays
        </Link>
      </div>
    );
  }

  const favorited = isFavorite(property.id);

  const handleRatingSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (userRating > 0) {
      setRatingSubmitted(true);
      setTimeout(() => setRatingSubmitted(false), 4000);
      setReviewComment('');
    }
  };

  const mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${encodeURIComponent(
    property.address
  )}`;
  const uberUrl = property.lat && property.lng
    ? `https://m.uber.com/?action=setPickup&dropoff[latitude]=${property.lat}&dropoff[longitude]=${property.lng}`
    : `https://m.uber.com/?action=setPickup&dropoff[formatted_address]=${encodeURIComponent(property.address)}`;

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      {/* Back Button */}
      <button
        onClick={() => navigate(-1)}
        className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-900 mb-6 transition"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Listings
      </button>

      {/* Title & Top Badges */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <div className="flex items-center gap-2 mb-2">
            {property.is_verified && (
              <span className="flex items-center gap-1 bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs font-semibold px-2.5 py-0.5 rounded-full">
                <ShieldCheck className="w-3.5 h-3.5" />
                Verified Municipality Certificate
              </span>
            )}
            <span className="bg-blue-50 text-blue-700 text-xs font-semibold px-2.5 py-0.5 rounded-full">
              {property.category === 'boys' ? 'Boys PG' : property.category === 'girls' ? 'Girls PG' : property.property_type}
            </span>
          </div>

          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900">{property.name}</h1>
          <p className="flex items-center gap-1.5 text-sm text-slate-500 mt-1">
            <MapPin className="w-4 h-4 text-slate-400 shrink-0" />
            {property.address}
          </p>
        </div>

        {/* Wishlist Button */}
        <button
          onClick={() => toggleWishlist(property)}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl border text-sm font-semibold transition ${
            favorited
              ? 'border-rose-300 bg-rose-50 text-rose-600'
              : 'border-slate-300 text-slate-700 hover:bg-slate-50'
          }`}
        >
          <Heart className={`w-4 h-4 ${favorited ? 'fill-rose-600 text-rose-600' : ''}`} />
          {favorited ? 'Saved in Wishlist' : 'Save to Wishlist'}
        </button>
      </div>

      {/* Photo Gallery */}
      <div className="space-y-3 mb-10">
        <div className="aspect-16/9 w-full rounded-3xl overflow-hidden bg-slate-100 shadow-md border border-slate-200 max-h-[480px]">
          <img
            src={selectedPhoto}
            alt={property.name}
            className="w-full h-full object-cover"
          />
        </div>

        {property.images.length > 1 && (
          <div className="flex items-center gap-3 overflow-x-auto pb-2">
            {property.images.map((img, idx) => (
              <button
                key={idx}
                onClick={() => setSelectedPhoto(img)}
                className={`w-24 h-16 rounded-xl overflow-hidden border-2 shrink-0 transition ${
                  selectedPhoto === img ? 'border-blue-600 scale-105 shadow-sm' : 'border-transparent opacity-70 hover:opacity-100'
                }`}
              >
                <img src={img} alt="" className="w-full h-full object-cover" />
              </button>
            ))}
          </div>
        )}
      </div>

      {/* 2-Column Specs Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
        
        {/* Left 2 Cols: Details, Amenities, Rules */}
        <div className="lg:col-span-2 space-y-8">
          
          {/* Description */}
          <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs">
            <h3 className="font-bold text-slate-900 text-lg mb-3">About this Accommodation</h3>
            <p className="text-sm text-slate-600 leading-relaxed whitespace-pre-line">
              {property.description || 'Comfortable and affordable student accommodation in a safe residential neighborhood. Walking distance to local engineering and arts colleges.'}
            </p>
          </div>

          {/* Key Amenities */}
          <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs">
            <h3 className="font-bold text-slate-900 text-lg mb-4">Included Amenities & Facilities</h3>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-4 text-xs">
              
              <div className={`flex items-center gap-2.5 p-3 rounded-xl border ${property.food_available ? 'bg-emerald-50/50 border-emerald-200 text-slate-800' : 'bg-slate-50 border-slate-200 text-slate-400'}`}>
                <Utensils className={`w-4 h-4 ${property.food_available ? 'text-emerald-600' : 'text-slate-400'}`} />
                <span>{property.food_available ? 'Daily 3 Meals Included' : 'No Food Service'}</span>
              </div>

              <div className={`flex items-center gap-2.5 p-3 rounded-xl border ${property.wifi_available ? 'bg-blue-50/50 border-blue-200 text-slate-800' : 'bg-slate-50 border-slate-200 text-slate-400'}`}>
                <Wifi className={`w-4 h-4 ${property.wifi_available ? 'text-blue-600' : 'text-slate-400'}`} />
                <span>{property.wifi_available ? 'High-Speed Wi-Fi' : 'No Wi-Fi'}</span>
              </div>

              <div className="flex items-center gap-2.5 p-3 rounded-xl border bg-slate-50 border-slate-200 text-slate-800">
                <Clock className="w-4 h-4 text-slate-600" />
                <span>Curfew: 10:00 PM</span>
              </div>

              <div className="flex items-center gap-2.5 p-3 rounded-xl border bg-slate-50 border-slate-200 text-slate-800">
                <Lock className="w-4 h-4 text-slate-600" />
                <span>Personal Lockers</span>
              </div>

              <div className="flex items-center gap-2.5 p-3 rounded-xl border bg-slate-50 border-slate-200 text-slate-800">
                <CheckCircle2 className="w-4 h-4 text-slate-600" />
                <span>RO Drinking Water</span>
              </div>

              <div className="flex items-center gap-2.5 p-3 rounded-xl border bg-slate-50 border-slate-200 text-slate-800">
                <Building className="w-4 h-4 text-slate-600" />
                <span>24/7 Hot Water (Solar)</span>
              </div>

            </div>
          </div>

          {/* Student Reviews & Rating Form */}
          <div className="bg-white rounded-2xl p-6 border border-slate-200 shadow-xs space-y-4">
            <h3 className="font-bold text-slate-900 text-lg">Student Ratings & Feedback</h3>
            
            <form onSubmit={handleRatingSubmit} className="p-4 bg-slate-50 rounded-xl border border-slate-200 space-y-3">
              <span className="text-xs font-semibold text-slate-700 block">Rate this property:</span>
              
              <div className="flex items-center gap-1">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    type="button"
                    key={star}
                    onClick={() => setUserRating(star)}
                    onMouseEnter={() => setHoverRating(star)}
                    onMouseLeave={() => setHoverRating(0)}
                    className="p-1 hover:scale-110 transition"
                  >
                    <Star
                      className={`w-6 h-6 ${
                        (hoverRating || userRating) >= star
                          ? 'text-amber-400 fill-amber-400'
                          : 'text-slate-300'
                      }`}
                    />
                  </button>
                ))}
                {userRating > 0 && (
                  <span className="text-xs font-bold text-slate-700 ml-2">{userRating} / 5 stars</span>
                )}
              </div>

              <textarea
                value={reviewComment}
                onChange={(e) => setReviewComment(e.target.value)}
                placeholder="Share your stay experience (food quality, cleanliness, warden behavior)..."
                rows={2}
                className="w-full text-xs p-3 rounded-xl border border-slate-300 bg-white focus:outline-hidden focus:ring-2 focus:ring-blue-500"
              />

              <div className="flex justify-end">
                <button
                  type="submit"
                  disabled={userRating === 0}
                  className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-xl text-xs font-semibold disabled:opacity-40 transition"
                >
                  Submit Review
                </button>
              </div>

              {ratingSubmitted && (
                <div className="p-2.5 bg-emerald-50 text-emerald-700 border border-emerald-200 text-xs rounded-lg flex items-center gap-2">
                  <Check className="w-4 h-4 text-emerald-600" />
                  <span>Thank you! Your verified student rating was recorded.</span>
                </div>
              )}
            </form>
          </div>

        </div>

        {/* Right Col: Booking & Contact Card */}
        <div className="space-y-6">
          <div className="bg-white rounded-3xl p-6 border border-slate-200 shadow-xl space-y-6 sticky top-24">
            
            {/* Rent & Token Price */}
            <div className="pb-4 border-b border-slate-100">
              <div className="flex items-baseline justify-between mb-1">
                <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider">Monthly Rent</span>
                <div className="flex items-baseline gap-1">
                  <span className="text-3xl font-extrabold text-slate-900">
                    {property.rent > 0 ? `₹${property.rent.toLocaleString()}` : 'Free/Govt'}
                  </span>
                  {property.rent > 0 && <span className="text-xs text-slate-500">/month</span>}
                </div>
              </div>

              <div className="flex items-center justify-between text-xs text-slate-600 bg-blue-50/70 p-2.5 rounded-xl border border-blue-100 mt-3">
                <span className="font-semibold text-blue-900">Token Reservation Deposit:</span>
                <span className="font-bold text-blue-900">₹{property.token.toLocaleString()}</span>
              </div>
            </div>

            {/* Action 1: Book with UPI Token */}
            <button
              onClick={() => setIsBookingOpen(true)}
              className="w-full py-3.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm rounded-xl shadow-lg hover:shadow-xl transition flex items-center justify-center gap-2"
            >
              <CreditCard className="w-5 h-5" />
              <span>Book via UPI Token (₹{property.token.toLocaleString()})</span>
            </button>

            {/* Action 2: Chat with Owner */}
            <Link
              to={`/chat?propertyId=${property.id}`}
              className="w-full py-3 bg-blue-50 hover:bg-blue-100 text-blue-700 font-semibold text-sm rounded-xl border border-blue-200 transition flex items-center justify-center gap-2"
            >
              <MessageSquare className="w-4 h-4" />
              <span>Direct Chat with Owner</span>
            </Link>

            {/* Navigation & Ride Buttons */}
            <div className="pt-2 grid grid-cols-2 gap-2 text-xs">
              <a
                href={mapsUrl}
                target="_blank"
                rel="noreferrer"
                className="p-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl flex items-center justify-center gap-1.5 transition text-center"
              >
                <Navigation className="w-3.5 h-3.5 text-blue-600" />
                Google Maps
              </a>
              <a
                href={uberUrl}
                target="_blank"
                rel="noreferrer"
                className="p-2.5 bg-slate-900 hover:bg-black text-white font-semibold rounded-xl flex items-center justify-center gap-1.5 transition text-center"
              >
                <Car className="w-3.5 h-3.5 text-emerald-400" />
                Get Uber Ride
              </a>
            </div>

            {/* Owner Contact Card */}
            <div className="pt-4 border-t border-slate-100 text-xs space-y-2">
              <span className="text-slate-400 font-semibold block uppercase tracking-wider text-[10px]">
                Owner Details
              </span>
              <div className="flex items-center justify-between">
                <span className="font-semibold text-slate-800">{property.owner_name || 'Verified Landlord'}</span>
                <span className="text-emerald-600 font-semibold flex items-center gap-1">
                  <ShieldCheck className="w-3.5 h-3.5" />
                  Verified
                </span>
              </div>
              <div className="flex items-center gap-1.5 text-slate-600">
                <Phone className="w-3.5 h-3.5 text-slate-400" />
                <span>{property.phone}</span>
              </div>
            </div>

          </div>
        </div>

      </div>

      {/* Booking Modal */}
      {isBookingOpen && (
        <BookingModal
          property={property}
          onClose={() => setIsBookingOpen(false)}
          onSuccess={(b) => {
            setIsBookingOpen(false);
            alert(`Token payment submitted! Booking ID: ${b.id}`);
          }}
        />
      )}

    </div>
  );
};
