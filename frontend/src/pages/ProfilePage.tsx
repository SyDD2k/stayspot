import React, { useState } from 'react';
import { 
  User as UserIcon, 
  Mail, 
  Phone, 
  ShieldCheck, 
  CreditCard, 
  LogOut, 
  Repeat, 
  Check, 
  Camera,
  Calendar
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { bookingApi } from '../services/api';
import { Booking } from '../types';

const AVATAR_OPTIONS = [
  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=200&q=80',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
];

export const ProfilePage: React.FC = () => {
  const { user, updateProfile, switchRole, logout } = useAuth();
  const [name, setName] = useState(user?.name || '');
  const [phone, setPhone] = useState(user?.phone || '');
  const [avatar, setAvatar] = useState(user?.avatar || AVATAR_OPTIONS[0]);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const bookings: Booking[] = bookingApi.getAll();

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    updateProfile({ name, phone, avatar });
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 3000);
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 space-y-8">
      
      {/* Header */}
      <div>
        <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900">User Profile & Account</h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">Manage your student identity and past room reservations.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        
        {/* Left Column: Avatar & Role Switch Card */}
        <div className="bg-white rounded-3xl border border-slate-200 p-6 shadow-xs flex flex-col items-center text-center space-y-4">
          
          <div className="relative">
            <img
              src={avatar}
              alt={user?.name}
              className="w-24 h-24 rounded-full object-cover border-4 border-blue-50 shadow-md"
            />
          </div>

          <div>
            <h3 className="font-bold text-slate-900 text-base">{user?.name}</h3>
            <span className="text-xs text-slate-500">{user?.email}</span>
            <div className="mt-2">
              <span className="inline-block px-3 py-1 rounded-full text-xs font-semibold bg-blue-50 text-blue-700 capitalize">
                Role: {user?.role}
              </span>
            </div>
          </div>

          {/* Quick Avatar Selector */}
          <div className="w-full pt-4 border-t border-slate-100">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block mb-2">
              Choose Avatar
            </span>
            <div className="flex justify-center gap-2">
              {AVATAR_OPTIONS.map((opt, idx) => (
                <button
                  key={idx}
                  type="button"
                  onClick={() => setAvatar(opt)}
                  className={`w-10 h-10 rounded-full overflow-hidden border-2 transition ${
                    avatar === opt ? 'border-blue-600 scale-110 shadow-sm' : 'border-transparent opacity-60 hover:opacity-100'
                  }`}
                >
                  <img src={opt} alt="" className="w-full h-full object-cover" />
                </button>
              ))}
            </div>
          </div>

          {/* Role Switcher Button */}
          <div className="w-full pt-4 border-t border-slate-100">
            <button
              onClick={() => switchRole(user?.role === 'student' ? 'owner' : 'student')}
              className="w-full py-2.5 px-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold text-xs rounded-xl transition flex items-center justify-center gap-1.5"
            >
              <Repeat className="w-3.5 h-3.5 text-blue-600" />
              <span>Switch to {user?.role === 'student' ? 'Owner / Landlord' : 'Student'} Mode</span>
            </button>
          </div>

          <button
            onClick={logout}
            className="w-full py-2 text-xs font-semibold text-rose-600 hover:bg-rose-50 rounded-xl transition flex items-center justify-center gap-1.5"
          >
            <LogOut className="w-3.5 h-3.5" />
            <span>Sign Out</span>
          </button>

        </div>

        {/* Right 2 Columns: Edit Details Form */}
        <div className="md:col-span-2 space-y-8">
          
          <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs">
            <h3 className="font-bold text-slate-900 text-base mb-6">Personal Contact Information</h3>

            <form onSubmit={handleSave} className="space-y-4 text-xs">
              
              <div>
                <label className="block font-semibold text-slate-700 mb-1">Full Legal Name</label>
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">Email Address (Read-only)</label>
                <input
                  type="email"
                  value={user?.email || ''}
                  disabled
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-200 bg-slate-50 text-slate-500 cursor-not-allowed"
                />
              </div>

              <div>
                <label className="block font-semibold text-slate-700 mb-1">Mobile Phone (for landlord inquiries)</label>
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="+91 98765 43210"
                  className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div className="pt-2 flex items-center justify-between">
                {savedSuccess ? (
                  <span className="text-emerald-600 font-semibold flex items-center gap-1 text-xs">
                    <Check className="w-4 h-4" /> Changes saved successfully!
                  </span>
                ) : <span />}

                <button
                  type="submit"
                  className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-xl shadow-md transition"
                >
                  Save Profile
                </button>
              </div>

            </form>
          </div>

          {/* Past Token Receipts Card */}
          <div className="bg-white rounded-3xl border border-slate-200 p-6 sm:p-8 shadow-xs">
            <h3 className="font-bold text-slate-900 text-base mb-4 flex items-center gap-2">
              <CreditCard className="w-5 h-5 text-emerald-600" />
              <span>Your Token Reservation Receipts</span>
            </h3>

            {bookings.length === 0 ? (
              <p className="text-xs text-slate-400">No active token reservations recorded on this account yet.</p>
            ) : (
              <div className="space-y-3">
                {bookings.map((b) => (
                  <div
                    key={b.id}
                    className="p-4 rounded-xl border border-slate-200 bg-slate-50 flex items-center justify-between text-xs"
                  >
                    <div>
                      <span className="font-bold text-slate-800 block text-sm">{b.property_name}</span>
                      <span className="text-slate-500 font-mono text-[11px]">Txn Ref: {b.transaction_ref}</span>
                      <span className="text-slate-400 text-[10px] block mt-0.5">Booking ID: {b.id}</span>
                    </div>
                    <div className="text-right">
                      <span className="font-bold text-emerald-600 text-sm block">₹{b.amount.toLocaleString()}</span>
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-100 text-emerald-800">
                        {b.payment_status}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

        </div>

      </div>

    </div>
  );
};
