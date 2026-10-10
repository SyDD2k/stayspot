import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Building2, Mail, Lock, ArrowRight, ShieldCheck, Sparkles, UserCheck } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState<'student' | 'owner'>('student');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;

    setLoading(true);
    await login(email.trim(), role);
    setLoading(false);

    if (role === 'owner') {
      navigate('/owner');
    } else {
      navigate('/');
    }
  };

  const handleDemoLogin = async (demoRole: 'student' | 'owner') => {
    setLoading(true);
    const demoEmail = demoRole === 'student' ? 'aditya.student@vvce.ac.in' : 'ramesh.landlord@stayspot.in';
    await login(demoEmail, demoRole);
    setLoading(false);
    if (demoRole === 'owner') {
      navigate('/owner');
    } else {
      navigate('/');
    }
  };

  return (
    <div className="min-h-[85vh] flex items-center justify-center px-4 py-12">
      <div className="bg-white rounded-3xl border border-slate-200 shadow-2xl max-w-md w-full overflow-hidden">
        
        {/* Card Header */}
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 p-8 text-white text-center">
          <div className="w-12 h-12 rounded-2xl bg-white/20 backdrop-blur-xs flex items-center justify-center mx-auto mb-3 shadow-sm">
            <Building2 className="w-7 h-7" />
          </div>
          <h2 className="text-2xl font-extrabold">Sign In to StaySpot</h2>
          <p className="text-xs text-blue-100 mt-1">Access verified student accommodations across Mysore</p>
        </div>

        {/* Card Body */}
        <div className="p-8 space-y-6">
          
          {/* Role Toggle Selector */}
          <div>
            <span className="text-[11px] font-semibold text-slate-500 uppercase tracking-wider block mb-2">
              Sign In As:
            </span>
            <div className="grid grid-cols-2 gap-2 bg-slate-100 p-1 rounded-xl">
              <button
                type="button"
                onClick={() => setRole('student')}
                className={`py-2 rounded-lg text-xs font-bold transition ${
                  role === 'student' ? 'bg-white text-blue-600 shadow-xs' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                🎓 Student
              </button>
              <button
                type="button"
                onClick={() => setRole('owner')}
                className={`py-2 rounded-lg text-xs font-bold transition ${
                  role === 'owner' ? 'bg-white text-indigo-600 shadow-xs' : 'text-slate-600 hover:text-slate-900'
                }`}
              >
                🏢 Property Owner
              </button>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4 text-xs">
            <div>
              <label className="block font-semibold text-slate-700 mb-1">Email Address</label>
              <div className="relative">
                <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="student@vvce.ac.in"
                  required
                  className="w-full pl-10 pr-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <div>
              <label className="block font-semibold text-slate-700 mb-1">Password</label>
              <div className="relative">
                <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  className="w-full pl-10 pr-3.5 py-2.5 text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm rounded-xl shadow-md transition disabled:opacity-50"
            >
              {loading ? 'Authenticating...' : `Sign In as ${role === 'student' ? 'Student' : 'Owner'}`}
            </button>
          </form>

          {/* Quick Demo Logins for GitHub Reviewers */}
          <div className="pt-4 border-t border-slate-100">
            <span className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider block text-center mb-2.5">
              Instant 1-Click Demo Logins
            </span>
            <div className="grid grid-cols-2 gap-2">
              <button
                type="button"
                onClick={() => handleDemoLogin('student')}
                className="py-2 px-3 text-xs font-semibold bg-emerald-50 hover:bg-emerald-100 text-emerald-800 border border-emerald-200 rounded-xl transition flex items-center justify-center gap-1"
              >
                <UserCheck className="w-3.5 h-3.5" />
                Demo Student
              </button>
              <button
                type="button"
                onClick={() => handleDemoLogin('owner')}
                className="py-2 px-3 text-xs font-semibold bg-indigo-50 hover:bg-indigo-100 text-indigo-800 border border-indigo-200 rounded-xl transition flex items-center justify-center gap-1"
              >
                <ShieldCheck className="w-3.5 h-3.5" />
                Demo Owner
              </button>
            </div>
          </div>

          <div className="text-center text-xs text-slate-500">
            <span>Don't have an account yet? </span>
            <Link to="/register" className="font-semibold text-blue-600 hover:underline">
              Register here
            </Link>
          </div>

        </div>

      </div>
    </div>
  );
};
