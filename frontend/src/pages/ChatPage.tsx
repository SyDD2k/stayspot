import React, { useState, useEffect, useRef } from 'react';
import { useSearchParams } from 'react-router-dom';
import { 
  Send, 
  MessageSquare, 
  Building2, 
  User as UserIcon, 
  CheckCheck, 
  ShieldCheck, 
  Sparkles,
  Phone
} from 'lucide-react';
import { ChatMessage, ChatRoom, Property } from '../types';
import { chatApi, propertyApi } from '../services/api';
import { useAuth } from '../context/AuthContext';

export const ChatPage: React.FC = () => {
  const { user } = useAuth();
  const [searchParams] = useSearchParams();
  const propertyIdParam = searchParams.get('propertyId');

  const [rooms, setRooms] = useState<ChatRoom[]>([]);
  const [activeRoomId, setActiveRoomId] = useState<string | number>('room_1');
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState('');
  const [activeProperty, setActiveProperty] = useState<Property | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const allRooms = chatApi.getRooms();
    setRooms(allRooms);

    // If propertyId parameter is passed, ensure room exists or select it
    if (propertyIdParam) {
      propertyApi.getById(propertyIdParam).then((p) => {
        if (p) {
          setActiveProperty(p);
          const existingRoom = allRooms.find((r) => String(r.property_id) === String(propertyIdParam));
          if (existingRoom) {
            setActiveRoomId(existingRoom.id);
          } else {
            const newRoom: ChatRoom = {
              id: `room_${Date.now()}`,
              property_id: p.id,
              property_name: p.name,
              property_address: p.address,
              owner_name: p.owner_name || 'Owner',
              student_name: user?.name || 'Student',
              last_message: 'Inquiring about this accommodation',
              updated_at: 'Just now',
            };
            setRooms([newRoom, ...allRooms]);
            setActiveRoomId(newRoom.id);
          }
        }
      });
    } else {
      setActiveRoomId(allRooms[0]?.id || 'room_1');
    }
  }, [propertyIdParam, user]);

  useEffect(() => {
    if (activeRoomId) {
      const msgs = chatApi.getMessages(activeRoomId);
      setMessages(msgs);
    }
  }, [activeRoomId]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const activeRoom = rooms.find((r) => r.id === activeRoomId) || rooms[0];

  const handleSendMessage = (textToSend?: string) => {
    const text = textToSend || inputText;
    if (!text.trim() || !activeRoomId) return;

    const newMsg = chatApi.sendMessage(activeRoomId, {
      chat_room_id: activeRoomId,
      sender_name: user?.name || 'You',
      sender_role: user?.role || 'student',
      content: text.trim(),
    });

    setMessages((prev) => [...prev, newMsg]);
    if (!textToSend) setInputText('');

    // Simulate realistic owner auto-reply after 1.2 seconds if sent as student
    if (user?.role === 'student') {
      setTimeout(() => {
        const replies = [
          'Yes, we currently have 2 sharing rooms available! You are welcome to visit any day between 10 AM and 6 PM.',
          'Food is prepared 3 times daily (vegetarian and non-veg on Wednesdays and Sundays). Wi-Fi is 100 Mbps fiber.',
          'You can reserve the room using the UPI token button on our listing page. The token will be deducted from your first month rent.',
          'Yes, gate curfew is 10:00 PM on weekdays and 10:30 PM on weekends for student safety.',
        ];
        const randomReply = replies[Math.floor(Math.random() * replies.length)];
        const ownerReply = chatApi.sendMessage(activeRoomId, {
          chat_room_id: activeRoomId,
          sender_name: activeRoom?.owner_name || 'Owner',
          sender_role: 'owner',
          content: randomReply,
        });
        setMessages((prev) => [...prev, ownerReply]);
      }, 1200);
    }
  };

  const quickQuestions = [
    'Is double sharing room available?',
    'What are the gate curfew timings?',
    'Is food included on weekends?',
    'Can I come for an in-person visit tomorrow?',
  ];

  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-slate-900">Direct Inquiries & Messaging</h1>
        <p className="text-xs text-slate-500">Communicate directly with verified landlords and hostel wardens.</p>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200 shadow-xl overflow-hidden grid grid-cols-1 md:grid-cols-3 h-[680px]">
        
        {/* Left Col: Conversation Threads */}
        <div className="border-r border-slate-200 flex flex-col bg-slate-50/50">
          <div className="p-4 border-b border-slate-200 bg-white">
            <span className="text-xs font-bold text-slate-700 uppercase tracking-wider block">
              Active Conversations
            </span>
          </div>

          <div className="flex-1 overflow-y-auto divide-y divide-slate-100">
            {rooms.map((room) => (
              <button
                key={room.id}
                onClick={() => setActiveRoomId(room.id)}
                className={`w-full p-4 text-left transition flex items-start gap-3 ${
                  activeRoomId === room.id
                    ? 'bg-blue-50/80 border-l-4 border-blue-600'
                    : 'hover:bg-slate-100/70 bg-white'
                }`}
              >
                <div className="w-10 h-10 rounded-xl bg-indigo-100 text-indigo-700 flex items-center justify-center shrink-0">
                  <Building2 className="w-5 h-5" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-0.5">
                    <span className="font-bold text-slate-900 text-xs truncate">
                      {room.property_name}
                    </span>
                    <span className="text-[10px] text-slate-400 shrink-0">{room.updated_at}</span>
                  </div>
                  <span className="text-[11px] text-slate-500 block truncate">
                    {user?.role === 'owner' ? `Student: ${room.student_name}` : `Owner: ${room.owner_name}`}
                  </span>
                  <p className="text-[11px] text-slate-400 truncate mt-1">
                    {room.last_message}
                  </p>
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Right Col: Active Chat Window */}
        <div className="md:col-span-2 flex flex-col bg-white">
          
          {/* Room Header */}
          {activeRoom && (
            <div className="px-6 py-4 border-b border-slate-200 flex items-center justify-between bg-slate-50/60">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-blue-600 text-white flex items-center justify-center font-bold text-sm shadow-xs">
                  <Building2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">{activeRoom.property_name}</h3>
                  <div className="flex items-center gap-2 text-[11px] text-slate-500">
                    <span>Landlord: {activeRoom.owner_name}</span>
                    <span className="w-1 h-1 bg-slate-300 rounded-full" />
                    <span className="text-emerald-600 font-semibold flex items-center gap-0.5">
                      <ShieldCheck className="w-3 h-3" />
                      Verified
                    </span>
                  </div>
                </div>
              </div>

              <span className="text-xs bg-slate-100 text-slate-700 px-3 py-1 rounded-full font-medium">
                {activeRoom.property_address}
              </span>
            </div>
          )}

          {/* Messages Stream */}
          <div className="flex-1 p-6 overflow-y-auto space-y-4 bg-slate-50/30">
            {messages.map((m) => {
              const isMe = m.sender_name === (user?.name || 'You') || m.sender_role === user?.role;
              return (
                <div
                  key={m.id}
                  className={`flex flex-col ${isMe ? 'items-end' : 'items-start'}`}
                >
                  <span className="text-[10px] text-slate-400 mb-1 px-1">
                    {m.sender_name} ({m.sender_role})
                  </span>
                  <div
                    className={`max-w-[75%] rounded-2xl px-4 py-3 shadow-xs text-xs leading-relaxed ${
                      isMe
                        ? 'bg-blue-600 text-white rounded-br-xs'
                        : 'bg-white border border-slate-200 text-slate-800 rounded-bl-xs'
                    }`}
                  >
                    <p>{m.content}</p>
                  </div>
                  <div className="flex items-center gap-1 text-[10px] text-slate-400 mt-1 px-1">
                    <span>{m.timestamp}</span>
                    {isMe && <CheckCheck className="w-3 h-3 text-blue-500" />}
                  </div>
                </div>
              );
            })}
            <div ref={messagesEndRef} />
          </div>

          {/* Quick Question Chips */}
          <div className="px-4 py-2 bg-white border-t border-slate-100 flex gap-2 overflow-x-auto scrollbar-none">
            {quickQuestions.map((q, idx) => (
              <button
                key={idx}
                onClick={() => handleSendMessage(q)}
                className="text-[11px] bg-slate-100 hover:bg-blue-50 hover:text-blue-600 text-slate-600 px-3 py-1 rounded-full shrink-0 transition"
              >
                {q}
              </button>
            ))}
          </div>

          {/* Input Bar */}
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleSendMessage();
            }}
            className="p-4 bg-white border-t border-slate-200 flex items-center gap-3"
          >
            <input
              type="text"
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="Type your inquiry message to the owner..."
              className="flex-1 px-4 py-2.5 text-xs sm:text-sm rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
            />
            <button
              type="submit"
              disabled={!inputText.trim()}
              className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 disabled:opacity-40 text-white font-semibold text-xs sm:text-sm rounded-xl shadow-md transition flex items-center gap-1.5"
            >
              <Send className="w-4 h-4" />
              <span>Send</span>
            </button>
          </form>

        </div>

      </div>

    </div>
  );
};
