import React, { useState, useEffect } from 'react';
import { 
  Search, 
  MapPin, 
  Filter, 
  Sparkles, 
  SlidersHorizontal, 
  Building, 
  GraduationCap, 
  ShieldCheck, 
  X,
  CreditCard
} from 'lucide-react';
import { Property, PropertyCategory, Booking } from '../types';
import { propertyApi } from '../services/api';
import { PropertyCard } from '../components/PropertyCard';
import { BookingModal } from '../components/BookingModal';

const CATEGORIES: { id: PropertyCategory | 'all'; label: string }[] = [
  { id: 'all', label: 'All Accommodations' },
  { id: 'boys', label: 'Boys PGs' },
  { id: 'girls', label: 'Girls PGs' },
  { id: 'apartments', label: 'Student Flats' },
  { id: 'rooms', label: 'Private Rooms' },
  { id: 'govtHostels', label: 'Govt Hostels' },
];

const POPULAR_LOCATIONS = [
  'Bogadi 2nd Stage (Near VVCE)',
  'Saraswathipuram',
  'Jayalakshmipuram',
  'CFTRI Layout',
  'Manasagangothri Campus',
  'Hebbal 1st Stage',
];

export const HomePage: React.FC = () => {
  const [properties, setProperties] = useState<Property[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<PropertyCategory | 'all'>('all');
  const [foodFilter, setFoodFilter] = useState(false);
  const [wifiFilter, setWifiFilter] = useState(false);
  const [maxRent, setMaxRent] = useState<number>(20000);
  const [showLocationDropdown, setShowLocationDropdown] = useState(false);
  const [selectedBookingProperty, setSelectedBookingProperty] = useState<Property | null>(null);
  const [successToast, setSuccessToast] = useState<string | null>(null);

  useEffect(() => {
    const fetchProps = async () => {
      setLoading(true);
      const data = await propertyApi.getAll();
      setProperties(data);
      setLoading(false);
    };
    fetchProps();
  }, []);

  const filteredProperties = properties.filter((p) => {
    // Search match
    const matchesSearch =
      p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      p.address.toLowerCase().includes(searchTerm.toLowerCase());

    // Category match
    const matchesCategory =
      selectedCategory === 'all' || p.category === selectedCategory;

    // Amenities
    const matchesFood = !foodFilter || p.food_available;
    const matchesWifi = !wifiFilter || p.wifi_available;

    // Price
    const matchesRent = p.rent <= maxRent;

    return matchesSearch && matchesCategory && matchesFood && matchesWifi && matchesRent;
  });

  const handleBookingSuccess = (booking: Booking) => {
    setSelectedBookingProperty(null);
    setSuccessToast(`🎉 Success! Room reserved at ${booking.property_name} (Booking Ref: ${booking.id})`);
    setTimeout(() => setSuccessToast(null), 5000);
  };

  return (
    <div className="min-h-screen pb-16">
      
      {/* Toast Notification */}
      {successToast && (
        <div className="fixed top-20 right-6 z-50 bg-emerald-600 text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-3 animate-in fade-in slide-in-from-top-4 duration-300">
          <ShieldCheck className="w-5 h-5 shrink-0" />
          <span className="text-sm font-medium">{successToast}</span>
          <button onClick={() => setSuccessToast(null)} className="p-1 hover:bg-emerald-700 rounded-lg">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-blue-900 via-indigo-900 to-slate-900 text-white py-16 lg:py-24 px-4 sm:px-6 lg:px-8 overflow-hidden">
        
        {/* Glow ambient effects */}
        <div className="absolute -top-24 -left-24 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-24 -right-24 w-96 h-96 bg-indigo-500/20 rounded-full blur-3xl pointer-events-none" />

        <div className="max-w-4xl mx-auto text-center relative z-10">
          
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-white/10 backdrop-blur-md border border-white/15 text-blue-200 text-xs font-semibold mb-6">
            <Sparkles className="w-3.5 h-3.5 text-amber-300" />
            <span>Discover 100+ Verified Student PGs & Hostels in Mysore</span>
          </div>

          <h1 className="text-3xl sm:text-5xl font-extrabold tracking-tight text-white mb-4 leading-tight">
            Find Your Safe Student Stay,{' '}
            <span className="bg-gradient-to-r from-blue-400 to-teal-300 bg-clip-text text-transparent">
              Direct with Verified Owners
            </span>
          </h1>

          <p className="text-sm sm:text-base text-slate-300 max-w-2xl mx-auto mb-8 leading-relaxed">
            No broker commissions. Search verified PGs, compare meal plans & amenities, and reserve instantly with UPI token guarantee.
          </p>

          {/* Interactive Search Bar */}
          <div className="relative max-w-2xl mx-auto bg-white rounded-2xl p-2 shadow-2xl flex flex-col sm:flex-row items-center gap-2 border border-slate-100">
            <div className="flex items-center gap-2 flex-1 w-full px-3 py-2 text-slate-700">
              <Search className="w-5 h-5 text-blue-600 shrink-0" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => {
                  setSearchTerm(e.target.value);
                  setShowLocationDropdown(true);
                }}
                onFocus={() => setShowLocationDropdown(true)}
                placeholder="Search college, area (e.g. Bogadi, VVCE, Saraswathipuram)..."
                className="w-full text-sm text-slate-900 placeholder-slate-400 focus:outline-hidden"
              />
              {searchTerm && (
                <button
                  onClick={() => setSearchTerm('')}
                  className="p-1 text-slate-400 hover:text-slate-600"
                >
                  <X className="w-4 h-4" />
                </button>
              )}
            </div>

            <button
              onClick={() => setShowLocationDropdown(false)}
              className="w-full sm:w-auto px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm rounded-xl transition shadow-md flex items-center justify-center gap-2"
            >
              <Search className="w-4 h-4" />
              <span>Explore Stays</span>
            </button>

            {/* Quick Autocomplete Suggestions Dropdown */}
            {showLocationDropdown && (
              <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl shadow-2xl border border-slate-200 py-2 z-30 text-left">
                <div className="px-3 py-1.5 text-[11px] font-semibold text-slate-400 uppercase tracking-wider flex items-center gap-1.5">
                  <MapPin className="w-3.5 h-3.5 text-blue-600" />
                  Popular Student Hubs
                </div>
                {POPULAR_LOCATIONS.map((loc, idx) => (
                  <button
                    key={idx}
                    onClick={() => {
                      setSearchTerm(loc.split(' (')[0]);
                      setShowLocationDropdown(false);
                    }}
                    className="w-full px-4 py-2 text-xs text-slate-700 hover:bg-blue-50 hover:text-blue-600 flex items-center gap-2 text-left transition"
                  >
                    <MapPin className="w-3.5 h-3.5 text-slate-400 shrink-0" />
                    <span>{loc}</span>
                  </button>
                ))}
              </div>
            )}
          </div>

        </div>

      </section>

      {/* Main Container */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-10">
        
        {/* Category Pills Header */}
        <div className="flex items-center gap-2 overflow-x-auto pb-4 scrollbar-none border-b border-slate-200 mb-8">
          {CATEGORIES.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`px-4 py-2 rounded-xl text-xs sm:text-sm font-semibold transition shrink-0 ${
                selectedCategory === cat.id
                  ? 'bg-blue-600 text-white shadow-md'
                  : 'bg-white text-slate-600 border border-slate-200 hover:border-slate-300 hover:bg-slate-50'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Secondary Filter Bar */}
        <div className="bg-white p-4 rounded-2xl border border-slate-200 shadow-xs mb-8 flex flex-wrap items-center justify-between gap-4">
          <div className="flex flex-wrap items-center gap-3">
            <span className="text-xs font-semibold text-slate-500 uppercase tracking-wider flex items-center gap-1">
              <SlidersHorizontal className="w-3.5 h-3.5 text-slate-400" />
              Filters:
            </span>

            {/* Food Included Toggle */}
            <button
              onClick={() => setFoodFilter(!foodFilter)}
              className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition ${
                foodFilter
                  ? 'bg-emerald-50 border-emerald-500 text-emerald-700 font-semibold'
                  : 'border-slate-200 text-slate-600 hover:bg-slate-50'
              }`}
            >
              🍲 Food Included
            </button>

            {/* Wi-Fi Toggle */}
            <button
              onClick={() => setWifiFilter(!wifiFilter)}
              className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition ${
                wifiFilter
                  ? 'bg-blue-50 border-blue-500 text-blue-700 font-semibold'
                  : 'border-slate-200 text-slate-600 hover:bg-slate-50'
              }`}
            >
              📶 Wi-Fi Provided
            </button>
          </div>

          {/* Max Rent Slider */}
          <div className="flex items-center gap-3 text-xs text-slate-600">
            <span>Budget: Max ₹{maxRent.toLocaleString()}</span>
            <input
              type="range"
              min="3000"
              max="20000"
              step="500"
              value={maxRent}
              onChange={(e) => setMaxRent(Number(e.target.value))}
              className="accent-blue-600 cursor-pointer w-28 sm:w-36"
            />
          </div>
        </div>

        {/* Results Header */}
        <div className="flex items-center justify-between mb-6">
          <p className="text-sm font-semibold text-slate-700">
            Showing <span className="text-blue-600">{filteredProperties.length}</span> accommodations
            {searchTerm && ` for "${searchTerm}"`}
          </p>
        </div>

        {/* Properties Grid */}
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {[1, 2, 3, 4, 5, 6].map((i) => (
              <div key={i} className="bg-white rounded-2xl border border-slate-200 p-4 h-80 animate-pulse flex flex-col justify-between">
                <div className="w-full h-44 bg-slate-200 rounded-xl" />
                <div className="h-4 bg-slate-200 rounded w-3/4" />
                <div className="h-3 bg-slate-200 rounded w-1/2" />
                <div className="h-8 bg-slate-200 rounded" />
              </div>
            ))}
          </div>
        ) : filteredProperties.length > 0 ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredProperties.map((property) => (
              <PropertyCard
                key={property.id}
                property={property}
                onBookClick={(p) => setSelectedBookingProperty(p)}
              />
            ))}
          </div>
        ) : (
          <div className="bg-white rounded-2xl border border-slate-200 p-12 text-center max-w-md mx-auto my-12">
            <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mx-auto text-slate-400 mb-4">
              <Building className="w-8 h-8" />
            </div>
            <h3 className="font-bold text-slate-800 text-lg mb-1">No Accommodations Found</h3>
            <p className="text-xs text-slate-500 mb-6">
              We couldn't find any stays matching your current search and filter settings.
            </p>
            <button
              onClick={() => {
                setSearchTerm('');
                setSelectedCategory('all');
                setFoodFilter(false);
                setWifiFilter(false);
                setMaxRent(20000);
              }}
              className="px-4 py-2 bg-blue-600 text-white rounded-xl text-xs font-semibold hover:bg-blue-700 transition"
            >
              Reset All Filters
            </button>
          </div>
        )}

      </div>

      {/* Booking Modal */}
      {selectedBookingProperty && (
        <BookingModal
          property={selectedBookingProperty}
          onClose={() => setSelectedBookingProperty(null)}
          onSuccess={handleBookingSuccess}
        />
      )}

    </div>
  );
};
