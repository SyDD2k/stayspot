import React from 'react';
import { Building2, ShieldCheck, Heart, MapPin, Mail, Phone } from 'lucide-react';
import { Link } from 'react-router-dom';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-slate-900 text-slate-400 text-sm mt-20 border-t border-slate-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          
          {/* Brand info */}
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-blue-600 flex items-center justify-center text-white">
                <Building2 className="w-5 h-5" />
              </div>
              <span className="text-xl font-bold text-white">StaySpot</span>
            </div>
            <p className="text-xs text-slate-400 leading-relaxed">
              Karnataka’s premier student accommodation and verified paying guest discovery platform. Direct owner connections, verified listings, and secure UPI token reservations.
            </p>
            <div className="flex items-center gap-2 text-xs text-emerald-400 bg-emerald-950/50 border border-emerald-800/60 px-3 py-1.5 rounded-lg w-fit">
              <ShieldCheck className="w-4 h-4 shrink-0" />
              <span>100% Verified Trade Certificates</span>
            </div>
          </div>

          {/* Student Hotspots */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-xs uppercase tracking-wider">Top Student Areas</h4>
            <ul className="space-y-2 text-xs">
              <li><span className="hover:text-white cursor-pointer transition">Bogadi 2nd Stage (VVCE)</span></li>
              <li><span className="hover:text-white cursor-pointer transition">Saraswathipuram & Maruthi Temple</span></li>
              <li><span className="hover:text-white cursor-pointer transition">Jayalakshmipuram & CFTRI Layout</span></li>
              <li><span className="hover:text-white cursor-pointer transition">Manasagangothri Campus Hub</span></li>
              <li><span className="hover:text-white cursor-pointer transition">Hebbal Industrial & College Zone</span></li>
            </ul>
          </div>

          {/* Quick Links */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-xs uppercase tracking-wider">Platform Links</h4>
            <ul className="space-y-2 text-xs">
              <li><Link to="/" className="hover:text-white transition">Browse All PGs & Hostels</Link></li>
              <li><Link to="/wishlist" className="hover:text-white transition">My Saved Wishlist</Link></li>
              <li><Link to="/owner" className="hover:text-white transition">List Your Property as Owner</Link></li>
              <li><Link to="/faq" className="hover:text-white transition">Student FAQs & Cancellation Terms</Link></li>
              <li><Link to="/chat" className="hover:text-white transition">Direct Chat Inquiries</Link></li>
            </ul>
          </div>

          {/* Contact & Support */}
          <div>
            <h4 className="text-white font-semibold mb-3 text-xs uppercase tracking-wider">Student Support</h4>
            <ul className="space-y-2.5 text-xs">
              <li className="flex items-center gap-2">
                <MapPin className="w-4 h-4 text-blue-500 shrink-0" />
                <span>Bogadi Main Road, Mysore, KA 570026</span>
              </li>
              <li className="flex items-center gap-2">
                <Mail className="w-4 h-4 text-blue-500 shrink-0" />
                <span>support@stayspot.in</span>
              </li>
              <li className="flex items-center gap-2">
                <Phone className="w-4 h-4 text-blue-500 shrink-0" />
                <span>+91 (0821) 250-STAY</span>
              </li>
            </ul>
          </div>

        </div>

        <div className="pt-8 mt-8 border-t border-slate-800 text-xs flex flex-col sm:flex-row items-center justify-between gap-4">
          <p>© {new Date().getFullYear()} StaySpot Technologies. Built with React & Django REST Framework.</p>
          <div className="flex items-center gap-1 text-slate-500">
            <span>Crafted with</span>
            <Heart className="w-3.5 h-3.5 text-rose-500 fill-rose-500" />
            <span>for university students across India</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
