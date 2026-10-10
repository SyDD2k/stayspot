import axios from 'axios';
import { Property, FAQItem, Booking, ChatMessage, ChatRoom } from '../types';
import { INITIAL_PROPERTIES, INITIAL_FAQS } from './mockData';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000';

const client = axios.create({
  baseURL: API_BASE_URL,
  timeout: 4000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Local state cache helpers
const STORAGE_KEYS = {
  PROPERTIES: 'stayspot_properties',
  FAQS: 'stayspot_faqs',
  BOOKINGS: 'stayspot_bookings',
  CHATS: 'stayspot_chats',
};

export const getStoredProperties = (): Property[] => {
  const saved = localStorage.getItem(STORAGE_KEYS.PROPERTIES);
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch {
      // fallback
    }
  }
  localStorage.setItem(STORAGE_KEYS.PROPERTIES, JSON.stringify(INITIAL_PROPERTIES));
  return INITIAL_PROPERTIES;
};

export const saveStoredProperties = (props: Property[]) => {
  localStorage.setItem(STORAGE_KEYS.PROPERTIES, JSON.stringify(props));
};

// API Services
export const propertyApi = {
  getAll: async (): Promise<Property[]> => {
    try {
      const res = await client.get('/users/properties/');
      if (res.data && Array.isArray(res.data) && res.data.length > 0) {
        // Map backend DRF property response to frontend interface
        return res.data.map((p: any) => ({
          id: p.id,
          name: p.name,
          address: p.address,
          phone: p.phone,
          rent: Number(p.rent) || 0,
          token: Number(p.token) || 1000,
          upi_id: p.upi_id || 'stayspot@upi',
          property_type: p.property_type || 'PG/Hostel',
          category: p.category || (p.name.toLowerCase().includes('girl') ? 'girls' : 'boys'),
          food_available: Boolean(p.food_available),
          wifi_available: Boolean(p.wifi_available),
          rooms_available: Boolean(p.rooms_available),
          images: p.images?.length ? p.images.map((img: any) => img.image) : [
            'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1000&q=80'
          ],
          owner_name: p.owner?.username || 'Verified Owner',
          rating: 4.5,
          review_count: 12,
          is_verified: true,
        }));
      }
    } catch {
      // Backend offline: gracefully return cached/mock data
    }
    return getStoredProperties();
  },

  getById: async (id: string | number): Promise<Property | undefined> => {
    try {
      const res = await client.get(`/users/properties/${id}/`);
      if (res.data) {
        const p = res.data;
        return {
          id: p.id,
          name: p.name,
          address: p.address,
          phone: p.phone,
          rent: Number(p.rent) || 0,
          token: Number(p.token) || 1000,
          upi_id: p.upi_id || 'stayspot@upi',
          property_type: p.property_type || 'PG/Hostel',
          category: p.category || 'boys',
          food_available: Boolean(p.food_available),
          wifi_available: Boolean(p.wifi_available),
          rooms_available: Boolean(p.rooms_available),
          images: p.images?.length ? p.images.map((img: any) => img.image) : [
            'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1000&q=80'
          ],
          owner_name: 'Verified Owner',
          rating: 4.6,
          review_count: 24,
          is_verified: true,
        };
      }
    } catch {
      // Fallback
    }
    const all = getStoredProperties();
    return all.find((p) => String(p.id) === String(id));
  },

  create: async (data: Partial<Property>): Promise<Property> => {
    try {
      const res = await client.post('/users/properties/', data);
      if (res.data) {
        return res.data;
      }
    } catch {
      // Fallback local persistence
    }
    const current = getStoredProperties();
    const newProperty: Property = {
      id: Date.now().toString(),
      name: data.name || 'New Property',
      address: data.address || '',
      phone: data.phone || '',
      rent: data.rent || 5000,
      token: data.token || 1000,
      upi_id: data.upi_id || 'owner@upi',
      property_type: data.property_type || 'PG/Hostel',
      category: data.category || 'boys',
      food_available: Boolean(data.food_available),
      wifi_available: Boolean(data.wifi_available),
      rooms_available: Boolean(data.rooms_available),
      images: data.images && data.images.length ? data.images : [
        'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?auto=format&fit=crop&w=1000&q=80'
      ],
      owner_name: data.owner_name || 'My Listing',
      rating: 5.0,
      review_count: 1,
      is_verified: true,
      distance_to_campus: '500m from Campus',
      description: data.description || 'Spacious student accommodation with all amenities.',
    };
    current.unshift(newProperty);
    saveStoredProperties(current);
    return newProperty;
  },

  delete: async (id: string | number): Promise<boolean> => {
    try {
      await client.delete(`/users/properties/${id}/`);
    } catch {
      // Fallback
    }
    const current = getStoredProperties();
    const updated = current.filter((p) => String(p.id) !== String(id));
    saveStoredProperties(updated);
    return true;
  },
};

// Bookings & Payments API
export const bookingApi = {
  create: async (bookingData: Omit<Booking, 'id' | 'date' | 'payment_status'>): Promise<Booking> => {
    const newBooking: Booking = {
      ...bookingData,
      id: `BK-${Date.now()}`,
      date: new Date().toISOString(),
      payment_status: 'SUCCESS',
    };
    const saved = localStorage.getItem(STORAGE_KEYS.BOOKINGS);
    const bookings: Booking[] = saved ? JSON.parse(saved) : [];
    bookings.unshift(newBooking);
    localStorage.setItem(STORAGE_KEYS.BOOKINGS, JSON.stringify(bookings));
    return newBooking;
  },

  getAll: (): Booking[] => {
    const saved = localStorage.getItem(STORAGE_KEYS.BOOKINGS);
    return saved ? JSON.parse(saved) : [];
  },
};

// FAQs API
export const faqApi = {
  getAll: async (): Promise<FAQItem[]> => {
    try {
      const res = await client.get('/faq/questions/');
      if (res.data && Array.isArray(res.data) && res.data.length > 0) {
        return res.data.map((q: any) => ({
          id: q.id,
          question: q.text,
          answer: q.answers?.[0]?.text || 'No answer provided yet.',
          category: 'General',
          likes: q.likes || 0,
          dislikes: q.dislikes || 0,
        }));
      }
    } catch {
      // fallback
    }
    const saved = localStorage.getItem(STORAGE_KEYS.FAQS);
    if (saved) return JSON.parse(saved);
    localStorage.setItem(STORAGE_KEYS.FAQS, JSON.stringify(INITIAL_FAQS));
    return INITIAL_FAQS;
  },

  vote: async (id: number, type: 'like' | 'dislike'): Promise<void> => {
    try {
      await client.post(`/faq/questions/${id}/${type}/`);
    } catch {
      // fallback
    }
    const saved = localStorage.getItem(STORAGE_KEYS.FAQS);
    const faqs: FAQItem[] = saved ? JSON.parse(saved) : INITIAL_FAQS;
    const item = faqs.find((f) => f.id === id);
    if (item) {
      if (type === 'like') item.likes += 1;
      else item.dislikes += 1;
      item.user_vote = type;
      localStorage.setItem(STORAGE_KEYS.FAQS, JSON.stringify(faqs));
    }
  },
};

// Chat API
export const chatApi = {
  getMessages: (chatRoomId: string | number): ChatMessage[] => {
    const key = `chat_messages_${chatRoomId}`;
    const saved = localStorage.getItem(key);
    if (saved) return JSON.parse(saved);

    const initial: ChatMessage[] = [
      {
        id: 1,
        chat_room_id: chatRoomId,
        sender_name: 'Owner',
        sender_role: 'owner',
        content: 'Hello! Thanks for your interest in our property. Feel free to ask any questions about rent, food, or rules.',
        timestamp: new Date(Date.now() - 3600000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      },
    ];
    localStorage.setItem(key, JSON.stringify(initial));
    return initial;
  },

  sendMessage: (chatRoomId: string | number, message: Omit<ChatMessage, 'id' | 'timestamp'>): ChatMessage => {
    const key = `chat_messages_${chatRoomId}`;
    const current = chatApi.getMessages(chatRoomId);
    const newMsg: ChatMessage = {
      ...message,
      id: Date.now(),
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };
    current.push(newMsg);
    localStorage.setItem(key, JSON.stringify(current));
    return newMsg;
  },

  getRooms: (): ChatRoom[] => {
    const saved = localStorage.getItem(STORAGE_KEYS.CHATS);
    if (saved) return JSON.parse(saved);

    const initial: ChatRoom[] = [
      {
        id: 'room_1',
        property_id: '1',
        property_name: 'Annapoorneshwari Boys PG',
        property_address: 'Bogadi 2nd Stage, Mysore',
        owner_name: 'Ramesh Gowda',
        student_name: 'Rahul Sharma',
        last_message: 'Is double sharing available from next month?',
        updated_at: '10 mins ago',
      },
      {
        id: 'room_2',
        property_id: '2',
        property_name: 'Akshaya PG for Girls',
        property_address: 'Bogadi 2nd Stage North, Mysore',
        owner_name: 'Lakshmi Narayana',
        student_name: 'Ananya S.',
        last_message: 'Can I pay the token amount today?',
        updated_at: '2 hours ago',
      },
    ];
    localStorage.setItem(STORAGE_KEYS.CHATS, JSON.stringify(initial));
    return initial;
  },
};
