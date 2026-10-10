export type UserRole = 'student' | 'owner';

export interface User {
  id: string;
  name: string;
  email: string;
  phone?: string;
  role: UserRole;
  avatar?: string;
  token?: string;
}

export type PropertyCategory = 'boys' | 'girls' | 'apartments' | 'govtHostels' | 'rooms';

export interface Property {
  id: string | number;
  name: string;
  address: string;
  phone: string;
  rent: number;
  token: number;
  upi_id: string;
  property_type: 'PG/Hostel' | 'Room' | 'Apartment';
  category: PropertyCategory;
  food_available: boolean;
  wifi_available: boolean;
  rooms_available: boolean;
  trade_certificate?: string;
  images: string[];
  owner_id?: string;
  owner_name?: string;
  rating?: number;
  review_count?: number;
  distance_to_campus?: string;
  description?: string;
  lat?: number;
  lng?: number;
  is_verified?: boolean;
}

export interface Booking {
  id: string;
  property_id: string | number;
  property_name: string;
  student_name: string;
  student_phone: string;
  amount: number;
  upi_id: string;
  transaction_ref: string;
  payment_status: 'SUCCESS' | 'PENDING' | 'FAILED';
  date: string;
}

export interface ChatMessage {
  id: string | number;
  chat_room_id: string | number;
  sender_name: string;
  sender_role: 'student' | 'owner';
  content: string;
  timestamp: string;
}

export interface ChatRoom {
  id: string | number;
  property_id: string | number;
  property_name: string;
  property_address: string;
  owner_name: string;
  student_name: string;
  last_message: string;
  updated_at: string;
}

export interface FAQItem {
  id: number;
  question: string;
  answer: string;
  category: string;
  likes: number;
  dislikes: number;
  user_vote?: 'like' | 'dislike';
}
