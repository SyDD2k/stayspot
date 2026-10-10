import React, { createContext, useContext, useState, useEffect } from 'react';
import { User, UserRole } from '../types';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, role?: UserRole) => Promise<void>;
  register: (name: string, email: string, role: UserRole, phone?: string) => Promise<void>;
  logout: () => void;
  switchRole: (role: UserRole) => void;
  updateProfile: (updated: Partial<User>) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const STORAGE_KEY = 'stayspot_current_user';

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // ignore
      }
    }
    // Default demo student user so recruiters/visitors have an active session right away!
    return {
      id: 'demo_user_1',
      name: 'Aditya Rao',
      email: 'aditya.student@vvce.ac.in',
      phone: '+91 98765 43210',
      role: 'student',
      avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    };
  });

  useEffect(() => {
    if (user) {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(user));
    } else {
      localStorage.removeItem(STORAGE_KEY);
    }
  }, [user]);

  const login = async (email: string, role: UserRole = 'student') => {
    const newUser: User = {
      id: `user_${Date.now()}`,
      name: email.split('@')[0].replace(/[._]/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase()),
      email,
      role,
      phone: '+91 98765 43210',
      avatar: role === 'owner'
        ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80'
        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    };
    setUser(newUser);
  };

  const register = async (name: string, email: string, role: UserRole, phone?: string) => {
    const newUser: User = {
      id: `user_${Date.now()}`,
      name,
      email,
      phone: phone || '+91 99887 76655',
      role,
      avatar: role === 'owner'
        ? 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80'
        : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=200&q=80',
    };
    setUser(newUser);
  };

  const logout = () => {
    setUser(null);
  };

  const switchRole = (newRole: UserRole) => {
    if (user) {
      setUser({ ...user, role: newRole });
    }
  };

  const updateProfile = (updated: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...updated });
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        login,
        register,
        logout,
        switchRole,
        updateProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
