import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Building2, 
  MapPin, 
  Phone, 
  IndianRupee, 
  CreditCard, 
  FileCheck, 
  Image as ImageIcon, 
  Check, 
  ArrowLeft,
  ShieldCheck,
  AlertCircle
} from 'lucide-react';
import { propertyApi } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { PropertyCategory } from '../types';

export const AddPropertyPage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuth();

  const [name, setName] = useState('');
  const [address, setAddress] = useState('');
  const [phone, setPhone] = useState(user?.phone || '+91 ');
  const [rent, setRent] = useState('');
  const [token, setToken] = useState('1500');
  const [upiId, setUpiId] = useState('');
  const [propertyType, setPropertyType] = useState<'PG/Hostel' | 'Room' | 'Apartment'>('PG/Hostel');
  const [category, setCategory] = useState<PropertyCategory>('boys');
  const [foodAvailable, setFoodAvailable] = useState(true);
  const [wifiAvailable, setWifiAvailable] = useState(true);
  const [roomsAvailable, setRoomsAvailable] = useState(true);
  const [imageUrl, setImageUrl] = useState('');
  const [images, setImages] = useState<string[]>([
    'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1000&q=80'
  ]);
  const [certificateUploaded, setCertificateUploaded] = useState(false);
  const [description, setDescription] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleAddImage = () => {
    if (imageUrl.trim()) {
      setImages([...images, imageUrl.trim()]);
      setImageUrl('');
    }
  };

  const handleRemoveImage = (index: number) => {
    setImages(images.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !address.trim() || !upiId.trim() || !rent) {
      setError('Please fill in all required fields (Name, Address, Rent, and receiving UPI ID).');
      return;
    }

    setSubmitting(true);
    setError('');

    try {
      const newProp = await propertyApi.create({
        name: name.trim(),
        address: address.trim(),
        phone: phone.trim(),
        rent: Number(rent),
        token: Number(token) || 1000,
        upi_id: upiId.trim(),
        property_type: propertyType,
        category,
        food_available: foodAvailable,
        wifi_available: wifiAvailable,
        rooms_available: roomsAvailable,
        images,
        owner_name: user?.name || 'Verified Owner',
        description,
        is_verified: certificateUploaded,
      });

      navigate(`/place/${newProp.id}`);
    } catch {
      setError('Failed to create listing. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      
      <button
        onClick={() => navigate('/owner')}
        className="inline-flex items-center gap-1 text-xs font-semibold text-slate-500 hover:text-slate-800 mb-6 transition"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Dashboard
      </button>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xl overflow-hidden">
        
        {/* Header */}
        <div className="bg-gradient-to-r from-indigo-700 to-blue-700 p-6 sm:p-8 text-white">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs font-semibold uppercase tracking-wider text-indigo-200 bg-white/10 px-2.5 py-0.5 rounded-full">
              Owner Listing Form
            </span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold">List Your Student Accommodation</h1>
          <p className="text-xs sm:text-sm text-indigo-100 mt-1 max-w-xl">
            Reach thousands of college students in Mysore. Verified listings receive direct token reservations and zero brokerage fees.
          </p>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="p-6 sm:p-8 space-y-8">
          
          {error && (
            <div className="p-4 bg-rose-50 border border-rose-200 rounded-xl text-xs text-rose-700 flex items-center gap-2 font-medium">
              <AlertCircle className="w-4 h-4 shrink-0 text-rose-600" />
              <span>{error}</span>
            </div>
          )}

          {/* Section 1: Basic Info */}
          <div>
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-2">
              <Building2 className="w-4 h-4 text-indigo-600" />
              1. Basic Accommodation Information
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              
              <div className="sm:col-span-2">
                <label className="block font-semibold text-slate-700 mb-1">
                  Accommodation / PG Name <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g. Annapoorneshwari Boys PG"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div className="sm:col-span-2">
                <label className="block font-semibold text-slate-700 mb-1">
                  Complete Address (with landmark) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="e.g. Bogadi 2nd Stage, Opp. Bank of Baroda, Mysore"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Contact Phone Number <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+91 98451 23456"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Property Classification
                </label>
                <select
                  value={propertyType}
                  onChange={(e) => setPropertyType(e.target.value as any)}
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500 bg-white"
                >
                  <option value="PG/Hostel">Paying Guest (PG) / Hostel</option>
                  <option value="Room">Private Single/Shared Room</option>
                  <option value="Apartment">Student Flat / Apartment</option>
                </select>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Category / Resident Type
                </label>
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value as any)}
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500 bg-white"
                >
                  <option value="boys">Boys Only</option>
                  <option value="girls">Girls Only</option>
                  <option value="apartments">Student Apartment (Co-living)</option>
                  <option value="rooms">Private Room</option>
                  <option value="govtHostels">Govt Subsidized Hostel</option>
                </select>
              </div>

            </div>
          </div>

          {/* Section 2: Pricing & Receiving UPI */}
          <div className="pt-6 border-t border-slate-100">
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-2">
              <IndianRupee className="w-4 h-4 text-emerald-600" />
              2. Monthly Rent & Token Deposit Configuration
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-xs">
              
              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Monthly Rent (₹) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="number"
                  value={rent}
                  onChange={(e) => setRent(e.target.value)}
                  placeholder="e.g. 6500"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500 font-bold"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Reservation Token Deposit (₹)
                </label>
                <input
                  type="number"
                  value={token}
                  onChange={(e) => setToken(e.target.value)}
                  placeholder="e.g. 1500"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500 font-bold text-emerald-600"
                />
                <span className="text-[11px] text-slate-400 mt-1 block">
                  Paid by student to lock the room.
                </span>
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">
                  Your Receiving UPI ID (VPA) <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  value={upiId}
                  onChange={(e) => setUpiId(e.target.value)}
                  placeholder="e.g. ownername@oksbi"
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500 font-mono"
                />
                <span className="text-[11px] text-slate-400 mt-1 block">
                  Where student token transfers arrive.
                </span>
              </div>

            </div>
          </div>

          {/* Section 3: Amenities & Verification */}
          <div className="pt-6 border-t border-slate-100">
            <h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-2">
              <ShieldCheck className="w-4 h-4 text-blue-600" />
              3. Amenities, Images & Verification
            </h3>

            {/* Checkboxes */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-6 text-xs">
              
              <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 cursor-pointer hover:bg-slate-50 transition">
                <input
                  type="checkbox"
                  checked={foodAvailable}
                  onChange={(e) => setFoodAvailable(e.target.checked)}
                  className="w-4 h-4 text-indigo-600 rounded"
                />
                <span className="font-medium text-slate-800">Daily Food / Meals Included</span>
              </label>

              <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 cursor-pointer hover:bg-slate-50 transition">
                <input
                  type="checkbox"
                  checked={wifiAvailable}
                  onChange={(e) => setWifiAvailable(e.target.checked)}
                  className="w-4 h-4 text-indigo-600 rounded"
                />
                <span className="font-medium text-slate-800">High-Speed Wi-Fi Included</span>
              </label>

              <label className="flex items-center gap-2.5 p-3 rounded-xl border border-slate-200 cursor-pointer hover:bg-slate-50 transition">
                <input
                  type="checkbox"
                  checked={roomsAvailable}
                  onChange={(e) => setRoomsAvailable(e.target.checked)}
                  className="w-4 h-4 text-indigo-600 rounded"
                />
                <span className="font-medium text-slate-800">Rooms Currently Available</span>
              </label>

            </div>

            {/* Description */}
            <div className="mb-6 text-xs">
              <label className="block font-semibold text-slate-700 mb-1">
                Property Description & Student Guidelines
              </label>
              <textarea
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Explain food menu, room sharing types (1, 2, or 3 sharing), gate timings, washing machine availability..."
                rows={3}
                className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            {/* Photos adder */}
            <div className="space-y-3 mb-6 text-xs">
              <label className="block font-semibold text-slate-700">Property Photos</label>
              <div className="flex gap-2">
                <input
                  type="url"
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                  placeholder="Paste image URL (e.g. Unsplash or hosted photo link)..."
                  className="flex-1 px-3.5 py-2 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-indigo-500"
                />
                <button
                  type="button"
                  onClick={handleAddImage}
                  className="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-xl font-semibold transition"
                >
                  Add Image
                </button>
              </div>

              {/* Photos preview */}
              <div className="flex flex-wrap gap-3 pt-2">
                {images.map((img, idx) => (
                  <div key={idx} className="relative w-24 h-18 rounded-xl overflow-hidden border border-slate-200 group">
                    <img src={img} alt="" className="w-full h-full object-cover" />
                    <button
                      type="button"
                      onClick={() => handleRemoveImage(idx)}
                      className="absolute inset-0 bg-red-600/80 text-white flex items-center justify-center opacity-0 group-hover:opacity-100 transition text-xs font-bold"
                    >
                      Remove
                    </button>
                  </div>
                ))}
              </div>
            </div>

            {/* Trade Certificate Upload */}
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-2xl flex items-center justify-between text-xs">
              <div className="flex items-center gap-3">
                <FileCheck className="w-6 h-6 text-indigo-600 shrink-0" />
                <div>
                  <span className="font-bold text-slate-800 block">Municipality Trade Certificate Verification</span>
                  <span className="text-slate-500 text-[11px]">Upload certificate to earn the green Verified badge.</span>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setCertificateUploaded(!certificateUploaded)}
                className={`px-3.5 py-1.5 rounded-xl font-semibold border transition ${
                  certificateUploaded
                    ? 'bg-emerald-100 border-emerald-300 text-emerald-800'
                    : 'bg-white border-slate-300 text-slate-700 hover:bg-slate-100'
                }`}
              >
                {certificateUploaded ? '✓ Certificate Verified' : 'Simulate Upload'}
              </button>
            </div>

          </div>

          {/* Submit Button */}
          <div className="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button
              type="button"
              onClick={() => navigate('/owner')}
              className="px-5 py-3 rounded-xl border border-slate-300 text-slate-700 text-sm font-semibold hover:bg-slate-50 transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="px-8 py-3 bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-bold rounded-xl shadow-lg hover:shadow-xl transition disabled:opacity-50"
            >
              {submitting ? 'Publishing Listing...' : 'Publish Listing to StaySpot'}
            </button>
          </div>

        </form>

      </div>

    </div>
  );
};
