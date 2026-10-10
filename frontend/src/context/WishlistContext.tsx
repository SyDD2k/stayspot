import React, { createContext, useContext, useState, useEffect } from 'react';
import { Property } from '../types';

interface WishlistContextType {
  wishlist: Property[];
  addToWishlist: (property: Property) => void;
  removeFromWishlist: (propertyId: string | number) => void;
  toggleWishlist: (property: Property) => void;
  isFavorite: (propertyId: string | number) => boolean;
}

const WishlistContext = createContext<WishlistContextType | undefined>(undefined);

const STORAGE_KEY = 'stayspot_wishlist';

export const WishlistProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [wishlist, setWishlist] = useState<Property[]>(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch {
        // ignore
      }
    }
    return [];
  });

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(wishlist));
  }, [wishlist]);

  const addToWishlist = (property: Property) => {
    if (!wishlist.some((p) => String(p.id) === String(property.id))) {
      setWishlist([...wishlist, property]);
    }
  };

  const removeFromWishlist = (propertyId: string | number) => {
    setWishlist(wishlist.filter((p) => String(p.id) !== String(propertyId)));
  };

  const toggleWishlist = (property: Property) => {
    if (isFavorite(property.id)) {
      removeFromWishlist(property.id);
    } else {
      addToWishlist(property);
    }
  };

  const isFavorite = (propertyId: string | number) => {
    return wishlist.some((p) => String(p.id) === String(propertyId));
  };

  return (
    <WishlistContext.Provider
      value={{
        wishlist,
        addToWishlist,
        removeFromWishlist,
        toggleWishlist,
        isFavorite,
      }}
    >
      {children}
    </WishlistContext.Provider>
  );
};

export const useWishlist = () => {
  const context = useContext(WishlistContext);
  if (!context) {
    throw new Error('useWishlist must be used within a WishlistProvider');
  }
  return context;
};
