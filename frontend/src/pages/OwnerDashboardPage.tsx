import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { 
  Building2, 
  PlusCircle, 
  Trash2, 
  ExternalLink, 
  Users, 
  IndianRupee, 
  ShieldCheck, 
  Eye, 
  AlertCircle,
  CheckCircle,
  X
} from 'lucide-react';
import { Property, Booking } from '../types';
import { propertyApi, bookingApi } from '../services/api';
import { useAuth } from '../context/AuthContext';

export const OwnerDashboardPage: React.FC = () => {
  const { user } = useAuth();
  const [properties, setProperties] = useState<Property[]>([]);
  const [bookings, setBookings] = useState<Booking[]>([]);
  const [loading, setLoading] = useState(true);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      const allProps = await propertyApi.getAll();
      setProperties(allProps);
      const allBookings = bookingApi.getAll();
      setBookings(allBookings);
      setLoading(false);
    };
    loadData();
  }, []);

  const handleDelete = async (id: string | number) => {
    if (window.confirm('Are you sure you want to delete this property listing?')) {
      await propertyApi.delete(id);
      setProperties(properties.filter((p) => String(p.id) !== String(id)));
      setActionSuccess('Property deleted successfully.');
      setTimeout(() => setActionSuccess(null), 3000);
    }
  };

  const totalTokensCollected = bookings.reduce((sum, b) => sum + (b.amount || 0), 0);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      
      {/* Toast */}
      {actionSuccess && (
        <div className="fixed top-20 right-6 z-50 bg-emerald-600 text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-3">
          <CheckCircle className="w-5 h-5 shrink-0" />
          <span className="text-sm font-medium">{actionSuccess}</span>
          <button onClick={() => setActionSuccess(null)} className="p-1 hover:bg-emerald-700 rounded-lg">
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Dashboard Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="text-xs font-semibold uppercase tracking-wider text-indigo-600 bg-indigo-50 px-2.5 py-0.5 rounded-full">
              Owner Management Portal
            </span>
          </div>
          <h1 className="text-2xl sm:text-3xl font-extrabold text-slate-900">
            Welcome back, {user?.name || 'Landlord'}
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Manage your student accommodations, track token receipts, and answer student inquiries.
          </p>
        </div>

        <Link
          to="/owner/add-property"
          className="inline-flex items-center justify-center gap-2 px-5 py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold text-sm rounded-xl shadow-md transition"
        >
          <PlusCircle className="w-4 h-4" />
          <span>Add New Accommodation</span>
        </Link>
      </div>

      {/* Stats Cards Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-10">
        
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-slate-500 block mb-1">Active Listings</span>
            <span className="text-2xl font-bold text-slate-900">{properties.length}</span>
            <span className="text-[11px] text-emerald-600 block mt-1">All verified & live</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
            <Building2 className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-slate-500 block mb-1">Tokens Received</span>
            <span className="text-2xl font-bold text-slate-900">₹{totalTokensCollected.toLocaleString()}</span>
            <span className="text-[11px] text-emerald-600 block mt-1">{bookings.length} reservations</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
            <IndianRupee className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-slate-500 block mb-1">Student Inquiries</span>
            <span className="text-2xl font-bold text-slate-900">18</span>
            <span className="text-[11px] text-blue-600 block mt-1">4 unread messages</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
            <Users className="w-6 h-6" />
          </div>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-xs flex items-center justify-between">
          <div>
            <span className="text-xs font-semibold text-slate-500 block mb-1">Total Profile Views</span>
            <span className="text-2xl font-bold text-slate-900">1,420</span>
            <span className="text-[11px] text-slate-400 block mt-1">Last 30 days</span>
          </div>
          <div className="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
            <Eye className="w-6 h-6" />
          </div>
        </div>

      </div>

      {/* Properties Table / Grid */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden mb-12">
        <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/70">
          <h3 className="font-bold text-slate-900 text-base">Your Listed Accommodations</h3>
          <span className="text-xs text-slate-500 font-semibold">{properties.length} Listings</span>
        </div>

        {loading ? (
          <div className="p-8 text-center text-slate-400 text-sm">Loading properties...</div>
        ) : properties.length === 0 ? (
          <div className="p-12 text-center text-slate-500 text-sm space-y-3">
            <AlertCircle className="w-8 h-8 text-slate-400 mx-auto" />
            <p>You haven't listed any properties yet.</p>
            <Link
              to="/owner/add-property"
              className="inline-block px-4 py-2 bg-indigo-600 text-white rounded-xl text-xs font-semibold"
            >
              Add First Listing
            </Link>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 text-slate-500 uppercase tracking-wider text-[11px] border-b border-slate-100">
                <tr>
                  <th className="px-6 py-3.5">Property</th>
                  <th className="px-6 py-3.5">Type & Category</th>
                  <th className="px-6 py-3.5">Rent / Month</th>
                  <th className="px-6 py-3.5">Token Deposit</th>
                  <th className="px-6 py-3.5">Receiving UPI ID</th>
                  <th className="px-6 py-3.5">Status</th>
                  <th className="px-6 py-3.5 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {properties.map((p) => (
                  <tr key={p.id} className="hover:bg-slate-50/80 transition">
                    <td className="px-6 py-4 font-semibold text-slate-800">
                      <div className="flex items-center gap-3">
                        <img
                          src={p.images[0] || 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=100&q=80'}
                          alt=""
                          className="w-10 h-10 rounded-lg object-cover border border-slate-200"
                        />
                        <div>
                          <span className="block font-bold text-slate-900">{p.name}</span>
                          <span className="text-[11px] text-slate-400">{p.address}</span>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 capitalize text-slate-600">
                      {p.category} ({p.property_type})
                    </td>
                    <td className="px-6 py-4 font-bold text-slate-900">
                      ₹{p.rent.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 text-emerald-600 font-semibold">
                      ₹{p.token.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 font-mono text-slate-600">
                      {p.upi_id}
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
                        Active & Verified
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex items-center justify-end gap-2">
                        <Link
                          to={`/place/${p.id}`}
                          className="p-1.5 text-slate-400 hover:text-blue-600 rounded-lg hover:bg-slate-100"
                          title="View Live Listing"
                        >
                          <ExternalLink className="w-4 h-4" />
                        </Link>
                        <button
                          onClick={() => handleDelete(p.id)}
                          className="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-rose-50"
                          title="Delete Listing"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Recent Student Bookings Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-xs overflow-hidden">
        <div className="px-6 py-4 border-b border-slate-100 bg-slate-50/70 flex items-center justify-between">
          <h3 className="font-bold text-slate-900 text-base">Recent Student Token Reservations</h3>
          <span className="text-xs text-slate-500 font-semibold">{bookings.length} Bookings</span>
        </div>

        {bookings.length === 0 ? (
          <div className="p-8 text-center text-slate-400 text-xs">
            No student token bookings recorded yet.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-slate-50 text-slate-500 uppercase tracking-wider text-[11px] border-b border-slate-100">
                <tr>
                  <th className="px-6 py-3">Student Name</th>
                  <th className="px-6 py-3">Phone</th>
                  <th className="px-6 py-3">Property Reserved</th>
                  <th className="px-6 py-3">Token Paid</th>
                  <th className="px-6 py-3">UPI Txn Ref</th>
                  <th className="px-6 py-3">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {bookings.map((b) => (
                  <tr key={b.id} className="hover:bg-slate-50/80">
                    <td className="px-6 py-3.5 font-bold text-slate-900">{b.student_name}</td>
                    <td className="px-6 py-3.5 text-slate-600">{b.student_phone}</td>
                    <td className="px-6 py-3.5 font-medium text-slate-800">{b.property_name}</td>
                    <td className="px-6 py-3.5 font-bold text-emerald-600">₹{b.amount.toLocaleString()}</td>
                    <td className="px-6 py-3.5 font-mono text-slate-500">{b.transaction_ref}</td>
                    <td className="px-6 py-3.5">
                      <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-100 text-emerald-800">
                        {b.payment_status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

    </div>
  );
};
