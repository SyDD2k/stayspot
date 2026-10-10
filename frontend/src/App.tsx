import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { WishlistProvider } from './context/WishlistContext';
import { Navbar } from './components/Navbar';
import { Footer } from './components/Footer';
import { ChatbotWidget } from './components/ChatbotWidget';
import { HomePage } from './pages/HomePage';
import { PropertyDetailPage } from './pages/PropertyDetailPage';
import { OwnerDashboardPage } from './pages/OwnerDashboardPage';
import { AddPropertyPage } from './pages/AddPropertyPage';
import { ChatPage } from './pages/ChatPage';
import { FAQPage } from './pages/FAQPage';
import { WishlistPage } from './pages/WishlistPage';
import { ProfilePage } from './pages/ProfilePage';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';

export function App() {
  return (
    <AuthProvider>
      <WishlistProvider>
        <Router>
          <div className="min-h-screen flex flex-col bg-slate-50 text-slate-800 antialiased selection:bg-blue-600 selection:text-white">
            <Navbar />
            <main className="flex-1">
              <Routes>
                <Route path="/" element={<HomePage />} />
                <Route path="/place/:id" element={<PropertyDetailPage />} />
                <Route path="/wishlist" element={<WishlistPage />} />
                <Route path="/owner" element={<OwnerDashboardPage />} />
                <Route path="/owner/add-property" element={<AddPropertyPage />} />
                <Route path="/chat" element={<ChatPage />} />
                <Route path="/faq" element={<FAQPage />} />
                <Route path="/profile" element={<ProfilePage />} />
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </main>
            <Footer />
            <ChatbotWidget />
          </div>
        </Router>
      </WishlistProvider>
    </AuthProvider>
  );
}

export default App;
