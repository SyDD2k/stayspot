import React, { useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { X, CheckCircle, Copy, Check, ArrowRight, ShieldCheck, AlertCircle } from 'lucide-react';
import { Property, Booking } from '../types';
import { useAuth } from '../context/AuthContext';
import { bookingApi } from '../services/api';

interface BookingModalProps {
  property: Property;
  onClose: () => void;
  onSuccess: (booking: Booking) => void;
}

export const BookingModal: React.FC<BookingModalProps> = ({ property, onClose, onSuccess }) => {
  const { user } = useAuth();
  const [studentName, setStudentName] = useState(user?.name || '');
  const [studentPhone, setStudentPhone] = useState(user?.phone || '');
  const [transactionRef, setTransactionRef] = useState('');
  const [copied, setCopied] = useState(false);
  const [step, setStep] = useState<'pay' | 'confirm' | 'success'>('pay');
  const [createdBooking, setCreatedBooking] = useState<Booking | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Standard NPCI UPI URI string
  const upiUri = `upi://pay?pa=${encodeURIComponent(property.upi_id)}&pn=${encodeURIComponent(
    property.name
  )}&am=${property.token}&cu=INR&tn=${encodeURIComponent(`Token Booking for ${property.name}`)}`;

  const handleCopyUpi = () => {
    navigator.clipboard.writeText(property.upi_id);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleConfirmPayment = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!studentName.trim()) {
      setError('Please provide your full name.');
      return;
    }
    if (!studentPhone.trim()) {
      setError('Please provide your contact phone number.');
      return;
    }
    if (!transactionRef.trim()) {
      setError('Please enter the 12-digit UPI Transaction Reference (UTR) ID from your payment app.');
      return;
    }

    setSubmitting(true);
    setError('');

    try {
      const booking = await bookingApi.create({
        property_id: property.id,
        property_name: property.name,
        student_name: studentName,
        student_phone: studentPhone,
        amount: property.token,
        upi_id: property.upi_id,
        transaction_ref: transactionRef.trim(),
      });
      setCreatedBooking(booking);
      setStep('success');
      onSuccess(booking);
    } catch {
      setError('Failed to record token booking. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="bg-white rounded-2xl max-w-lg w-full overflow-hidden shadow-2xl border border-slate-200 max-h-[90vh] flex flex-col">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50">
          <div>
            <h3 className="font-bold text-slate-900 text-lg">Reserve with UPI Token</h3>
            <p className="text-xs text-slate-500">{property.name}</p>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-slate-700 rounded-lg hover:bg-slate-200/50 transition"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto space-y-6">
          
          {step === 'pay' && (
            <div className="space-y-6">
              
              {/* Summary Card */}
              <div className="bg-blue-50/70 border border-blue-200/60 rounded-xl p-4 flex items-center justify-between">
                <div>
                  <span className="text-xs font-semibold text-blue-700 uppercase tracking-wider block">Token Amount</span>
                  <span className="text-2xl font-bold text-slate-900">₹{property.token.toLocaleString()}</span>
                  <span className="text-xs text-slate-500 block">Deducted from 1st month rent (₹{property.rent.toLocaleString()}/mo)</span>
                </div>
                <div className="w-12 h-12 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-xl shadow-xs">
                  ₹
                </div>
              </div>

              {/* QR Code and UPI ID */}
              <div className="flex flex-col items-center justify-center p-5 bg-slate-50 border border-slate-200 rounded-2xl text-center">
                <div className="p-3 bg-white rounded-xl shadow-sm border border-slate-200 mb-3">
                  <QRCodeSVG value={upiUri} size={180} level="M" />
                </div>
                <p className="text-xs font-medium text-slate-600 mb-2">Scan with Google Pay, PhonePe, Paytm or BHIM</p>
                
                {/* Copy VPA */}
                <div className="flex items-center gap-2 bg-white px-3 py-1.5 rounded-lg border border-slate-200 text-xs">
                  <span className="text-slate-500 font-mono">UPI ID:</span>
                  <span className="font-semibold text-slate-800 font-mono">{property.upi_id}</span>
                  <button
                    onClick={handleCopyUpi}
                    className="p-1 hover:text-blue-600 transition text-slate-400"
                    title="Copy UPI ID"
                  >
                    {copied ? <Check className="w-3.5 h-3.5 text-emerald-600" /> : <Copy className="w-3.5 h-3.5" />}
                  </button>
                </div>

                {/* Direct Mobile Deep Link */}
                <a
                  href={upiUri}
                  className="mt-3 text-xs font-semibold text-blue-600 hover:text-blue-700 underline"
                >
                  Tap here to open installed UPI app directly
                </a>
              </div>

              {/* Trust Badge */}
              <div className="flex items-center gap-2 text-xs text-emerald-700 bg-emerald-50 p-3 rounded-lg border border-emerald-200">
                <ShieldCheck className="w-4 h-4 shrink-0" />
                <span>Your token reserves your room spot. Full refund available if canceled 7 days prior to move-in.</span>
              </div>

              <button
                onClick={() => setStep('confirm')}
                className="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-sm rounded-xl shadow-md transition flex items-center justify-center gap-2"
              >
                <span>I have paid ₹{property.token} — Enter Reference</span>
                <ArrowRight className="w-4 h-4" />
              </button>

            </div>
          )}

          {step === 'confirm' && (
            <form onSubmit={handleConfirmPayment} className="space-y-4">
              
              <div className="p-3 bg-amber-50 border border-amber-200 rounded-xl text-xs text-amber-800 flex items-start gap-2">
                <AlertCircle className="w-4 h-4 shrink-0 mt-0.5 text-amber-600" />
                <span>Please enter the details of the student moving in and the 12-digit transaction ID from your UPI app receipt.</span>
              </div>

              {error && (
                <div className="p-3 bg-rose-50 border border-rose-200 rounded-xl text-xs text-rose-700 font-medium">
                  {error}
                </div>
              )}

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Student Full Name</label>
                <input
                  type="text"
                  value={studentName}
                  onChange={(e) => setStudentName(e.target.value)}
                  placeholder="e.g. Rahul Sharma"
                  required
                  className="w-full px-3.5 py-2 text-sm rounded-lg border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">Contact Phone Number</label>
                <input
                  type="tel"
                  value={studentPhone}
                  onChange={(e) => setStudentPhone(e.target.value)}
                  placeholder="+91 98765 43210"
                  required
                  className="w-full px-3.5 py-2 text-sm rounded-lg border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-slate-700 mb-1">
                  12-Digit UPI Ref / UTR / Txn Number
                </label>
                <input
                  type="text"
                  value={transactionRef}
                  onChange={(e) => setTransactionRef(e.target.value)}
                  placeholder="e.g. 429188472910"
                  required
                  className="w-full px-3.5 py-2 text-sm font-mono rounded-lg border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
                <span className="text-[11px] text-slate-400 mt-1 block">
                  Find this in your GPay/PhonePe payment details (labeled UPI Ref No. or UTR).
                </span>
              </div>

              <div className="pt-2 flex items-center gap-3">
                <button
                  type="button"
                  onClick={() => setStep('pay')}
                  className="px-4 py-2.5 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl border border-slate-300 transition"
                >
                  Back to QR
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="flex-1 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white font-semibold text-sm rounded-xl shadow-md transition disabled:opacity-50"
                >
                  {submitting ? 'Verifying...' : 'Submit & Confirm Reservation'}
                </button>
              </div>

            </form>
          )}

          {step === 'success' && createdBooking && (
            <div className="text-center py-6 space-y-4">
              <div className="w-16 h-16 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center mx-auto shadow-inner">
                <CheckCircle className="w-10 h-10" />
              </div>

              <h4 className="text-xl font-bold text-slate-900">Room Reservation Confirmed!</h4>
              <p className="text-xs text-slate-500 max-w-sm mx-auto">
                Your token deposit of <strong className="text-slate-800">₹{createdBooking.amount.toLocaleString()}</strong> has been submitted to {property.name}.
              </p>

              <div className="bg-slate-50 border border-slate-200 rounded-xl p-4 text-left text-xs space-y-2 max-w-sm mx-auto font-mono">
                <div className="flex justify-between">
                  <span className="text-slate-500">Booking ID:</span>
                  <span className="font-bold text-slate-800">{createdBooking.id}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Txn Ref ID:</span>
                  <span className="font-bold text-slate-800">{createdBooking.transaction_ref}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Student:</span>
                  <span className="text-slate-800">{createdBooking.student_name}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Owner Phone:</span>
                  <span className="text-blue-600 font-bold">{property.phone}</span>
                </div>
              </div>

              <button
                onClick={onClose}
                className="w-full max-w-sm py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold rounded-xl shadow-md transition"
              >
                Close & View Receipt
              </button>
            </div>
          )}

        </div>

      </div>
    </div>
  );
};
