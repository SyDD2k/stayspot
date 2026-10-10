import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { 
  Building2, 
  Heart, 
  MessageSquare, 
  HelpCircle, 
  User as UserIcon, 
  Menu, 
  X, 
  PlusCircle, 
  LogOut, 
  Home, 
  ShieldCheck,
  Repeat
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useWishlist } from '../context/WishlistContext';

export const Navbar: React.FC = () => {
  const { user, isAuthenticated, logout, switchRole } = useAuth();
  const { wishlist } = useWishlist();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const handleRoleToggle = () => {
    if (user) {
      const nextRole = user.role === 'student' ? 'owner' : 'student';
      switchRole(nextRole);
      if (nextRole === 'owner') {
        navigate('/owner');
      } else {
        navigate('/');
      }
    }
  };

  const isActive = (path: string) => location.pathname === path;

  return (
    <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-slate-200 shadow-xs">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 group">
            <div className="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-md group-hover:scale-105 transition-transform">
              <Building2 className="w-6 h-6" />
            </div>
            <div>
              <span className="text-xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                StaySpot
              </span>
              <span className="hidden sm:inline-block text-[10px] uppercase font-semibold tracking-wider text-slate-500 ml-2 px-1.5 py-0.5 bg-slate-100 rounded">
                Verified Stays
              </span>
            </div>
          </Link>

          {/* Desktop Nav Links */}
          <nav className="hidden md:flex items-center gap-1">
            <Link
              to="/"
              className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                isActive('/') ? 'text-blue-600 bg-blue-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
              }`}
            >
              <Home className="w-4 h-4" />
              Explore PGs
            </Link>

            <Link
              to="/wishlist"
              className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors relative ${
                isActive('/wishlist') ? 'text-blue-600 bg-blue-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
              }`}
            >
              <Heart className="w-4 h-4" />
              Wishlist
              {wishlist.length > 0 && (
                <span className="ml-1 px-1.5 py-0.2 bg-rose-500 text-white text-xs font-bold rounded-full">
                  {wishlist.length}
                </span>
              )}
            </Link>

            <Link
              to="/chat"
              className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                isActive('/chat') ? 'text-blue-600 bg-blue-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
              }`}
            >
              <MessageSquare className="w-4 h-4" />
              Chats
            </Link>

            <Link
              to="/faq"
              className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                isActive('/faq') ? 'text-blue-600 bg-blue-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
              }`}
            >
              <HelpCircle className="w-4 h-4" />
              FAQs
            </Link>

            {user?.role === 'owner' && (
              <Link
                to="/owner"
                className={`flex items-center gap-1.5 px-3 py-2 rounded-lg text-sm font-semibold transition-colors ${
                  location.pathname.startsWith('/owner') ? 'text-indigo-600 bg-indigo-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'
                }`}
              >
                <ShieldCheck className="w-4 h-4 text-indigo-600" />
                Owner Portal
              </Link>
            )}
          </nav>

          {/* Right Action Controls */}
          <div className="hidden md:flex items-center gap-3">
            {isAuthenticated ? (
              <>
                {/* Role Toggle Pill */}
                <button
                  onClick={handleRoleToggle}
                  title="Switch between Student & Owner views"
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-semibold border border-slate-300 hover:border-slate-400 bg-slate-50 text-slate-700 transition"
                >
                  <Repeat className="w-3.5 h-3.5 text-blue-600" />
                  Mode: <span className="capitalize font-bold text-blue-600">{user?.role}</span>
                </button>

                {user?.role === 'owner' ? (
                  <Link
                    to="/owner/add-property"
                    className="flex items-center gap-1.5 px-3.5 py-1.5 rounded-lg text-sm font-semibold text-white bg-indigo-600 hover:bg-indigo-700 shadow-xs transition"
                  >
                    <PlusCircle className="w-4 h-4" />
                    List Property
                  </Link>
                ) : (
                  <Link
                    to="/profile"
                    className="flex items-center gap-2 p-1.5 rounded-full hover:bg-slate-100 transition"
                  >
                    <img
                      src={user?.avatar || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80'}
                      alt={user?.name}
                      className="w-8 h-8 rounded-full object-cover border border-slate-300"
                    />
                    <span className="text-sm font-medium text-slate-700">{user?.name}</span>
                  </Link>
                )}

                <button
                  onClick={logout}
                  title="Sign Out"
                  className="p-2 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100 transition"
                >
                  <LogOut className="w-4 h-4" />
                </button>
              </>
            ) : (
              <div className="flex items-center gap-2">
                <Link
                  to="/login"
                  className="px-4 py-2 text-sm font-medium text-slate-700 hover:text-blue-600 transition"
                >
                  Sign In
                </Link>
                <Link
                  to="/register"
                  className="px-4 py-2 text-sm font-semibold text-white bg-blue-600 hover:bg-blue-700 rounded-lg shadow-xs transition"
                >
                  Join StaySpot
                </Link>
              </div>
            )}
          </div>

          {/* Mobile Menu Button */}
          <div className="flex md:hidden items-center gap-2">
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 text-slate-600 hover:text-slate-900 rounded-lg focus:outline-hidden"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>

        </div>
      </div>

      {/* Mobile Drawer */}
      {mobileMenuOpen && (
        <div className="md:hidden border-t border-slate-200 bg-white px-4 pt-2 pb-6 space-y-3">
          <Link
            to="/"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            <Home className="w-4 h-4" />
            Explore PGs
          </Link>
          <Link
            to="/wishlist"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center justify-between px-3 py-2 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            <span className="flex items-center gap-2">
              <Heart className="w-4 h-4 text-rose-500" />
              Wishlist
            </span>
            {wishlist.length > 0 && (
              <span className="px-2 py-0.5 bg-rose-500 text-white text-xs font-bold rounded-full">
                {wishlist.length}
              </span>
            )}
          </Link>
          <Link
            to="/chat"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            <MessageSquare className="w-4 h-4" />
            Chat Inquiries
          </Link>
          <Link
            to="/faq"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            <HelpCircle className="w-4 h-4" />
            FAQs & Support
          </Link>

          {user?.role === 'owner' && (
            <Link
              to="/owner"
              onClick={() => setMobileMenuOpen(false)}
              className="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-semibold text-indigo-600 bg-indigo-50"
            >
              <ShieldCheck className="w-4 h-4" />
              Owner Dashboard
            </Link>
          )}

          <div className="pt-3 border-t border-slate-100 flex items-center justify-between">
            {isAuthenticated ? (
              <>
                <button
                  onClick={handleRoleToggle}
                  className="px-3 py-1.5 text-xs font-semibold bg-slate-100 rounded-lg text-slate-700"
                >
                  Mode: <span className="capitalize text-blue-600">{user?.role}</span>
                </button>
                <Link
                  to="/profile"
                  onClick={() => setMobileMenuOpen(false)}
                  className="text-sm font-medium text-slate-700 flex items-center gap-1"
                >
                  <UserIcon className="w-4 h-4" />
                  Profile
                </Link>
                <button
                  onClick={() => {
                    logout();
                    setMobileMenuOpen(false);
                  }}
                  className="text-sm text-red-600 font-medium"
                >
                  Sign Out
                </button>
              </>
            ) : (
              <div className="flex gap-2 w-full">
                <Link
                  to="/login"
                  onClick={() => setMobileMenuOpen(false)}
                  className="flex-1 text-center py-2 text-sm font-medium border border-slate-300 rounded-lg text-slate-700"
                >
                  Sign In
                </Link>
                <Link
                  to="/register"
                  onClick={() => setMobileMenuOpen(false)}
                  className="flex-1 text-center py-2 text-sm font-semibold bg-blue-600 text-white rounded-lg"
                >
                  Register
                </Link>
              </div>
            )}
          </div>
        </div>
      )}
    </header>
  );
};
