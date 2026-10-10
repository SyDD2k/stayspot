import React, { useState, useRef, useEffect } from 'react';
import { Bot, X, Send, Sparkles, MessageSquare, ArrowUpRight } from 'lucide-react';
import { Link } from 'react-router-dom';

interface Message {
  id: string;
  sender: 'bot' | 'user';
  text: string;
  time: string;
  link?: string;
  linkText?: string;
}

export const ChatbotWidget: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [input, setInput] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      sender: 'bot',
      text: 'Hi there! 👋 I am SpotBot, your StaySpot student accommodation assistant. How can I help you today?',
      time: 'Just now',
    },
  ]);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isOpen]);

  const quickPrompts = [
    'How does token payment work?',
    'What PGs are near VVCE College?',
    'Are food and WiFi included?',
    'How do I cancel my booking?',
  ];

  const handleSend = (textToSend?: string) => {
    const query = textToSend || input;
    if (!query.trim()) return;

    const userMsg: Message = {
      id: Date.now().toString(),
      sender: 'user',
      text: query,
      time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    if (!textToSend) setInput('');
    setIsTyping(true);

    setTimeout(() => {
      let reply = "I'm here to help with all questions about PGs, hostels, deposits, and verification.";
      let link: string | undefined = undefined;
      let linkText: string | undefined = undefined;

      const lower = query.toLowerCase();
      if (lower.includes('token') || lower.includes('payment') || lower.includes('upi')) {
        reply = 'You can reserve a room by paying a token amount (typically ₹1,000–₹2,000) directly to the verified owner via UPI. The token confirms your reservation until your move-in date.';
        link = '/faq';
        linkText = 'Read Payment FAQs';
      } else if (lower.includes('vvce') || lower.includes('bogadi') || lower.includes('college')) {
        reply = 'We have 6+ verified student accommodations in Bogadi 2nd Stage within 500m of VVCE (e.g. Annapoorneshwari Boys PG, Akshaya Girls PG, Roy Boys PG).';
        link = '/';
        linkText = 'Browse PGs near VVCE';
      } else if (lower.includes('food') || lower.includes('wifi')) {
        reply = 'Most PGs on StaySpot include 3 daily meals (South & North Indian menu) and 100 Mbps fiber Wi-Fi. Check the green "Food Incl." and "Wi-Fi" tags on each listing!';
      } else if (lower.includes('cancel') || lower.includes('refund')) {
        reply = 'Full refunds are available if canceled at least 7 days before your move-in date. Contact the owner or student support for assistance.';
        link = '/faq';
        linkText = 'View Refund Policy';
      } else if (lower.includes('owner') || lower.includes('list')) {
        reply = 'Are you a PG or hostel owner? You can list your property, upload trade certificates, and receive student inquiries via our Owner Portal.';
        link = '/owner/add-property';
        linkText = 'List Your Property';
      } else {
        reply = `Thanks for asking about "${query}". You can also check our FAQ knowledgebase or message owners directly!`;
        link = '/faq';
        linkText = 'Search FAQ database';
      }

      const botMsg: Message = {
        id: (Date.now() + 1).toString(),
        sender: 'bot',
        text: reply,
        time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        link,
        linkText,
      };

      setMessages((prev) => [...prev, botMsg]);
      setIsTyping(false);
    }, 600);
  };

  return (
    <div className="fixed bottom-6 right-6 z-50">
      
      {/* Floating Toggle Button */}
      {!isOpen && (
        <button
          onClick={() => setIsOpen(true)}
          className="group relative flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-3.5 rounded-full shadow-xl hover:shadow-2xl transition-all duration-300 hover:scale-105"
        >
          <Bot className="w-6 h-6 animate-pulse" />
          <span className="font-semibold text-sm pr-1 hidden sm:inline-block">SpotBot Help</span>
          <span className="absolute -top-1 -right-1 w-3.5 h-3.5 bg-emerald-400 border-2 border-white rounded-full" />
        </button>
      )}

      {/* Chat Window */}
      {isOpen && (
        <div className="bg-white rounded-2xl w-80 sm:w-96 h-[500px] shadow-2xl border border-slate-200 flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
          
          {/* Header */}
          <div className="px-4 py-3.5 bg-gradient-to-r from-blue-600 to-indigo-600 text-white flex items-center justify-between">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-lg bg-white/20 backdrop-blur-xs flex items-center justify-center">
                <Bot className="w-5 h-5 text-white" />
              </div>
              <div>
                <h4 className="font-semibold text-sm flex items-center gap-1.5">
                  SpotBot Assistant
                  <Sparkles className="w-3.5 h-3.5 text-amber-300" />
                </h4>
                <span className="text-[11px] text-blue-100 flex items-center gap-1">
                  <span className="w-1.5 h-1.5 bg-emerald-400 rounded-full" />
                  Online • Powered by StaySpot AI
                </span>
              </div>
            </div>
            <button
              onClick={() => setIsOpen(false)}
              className="p-1 rounded-lg hover:bg-white/20 transition text-white/80 hover:text-white"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Messages Area */}
          <div className="flex-1 p-4 overflow-y-auto space-y-3 bg-slate-50 text-xs">
            {messages.map((m) => (
              <div
                key={m.id}
                className={`flex flex-col ${m.sender === 'user' ? 'items-end' : 'items-start'}`}
              >
                <div
                  className={`max-w-[85%] rounded-2xl px-3.5 py-2.5 shadow-xs leading-relaxed ${
                    m.sender === 'user'
                      ? 'bg-blue-600 text-white rounded-br-xs'
                      : 'bg-white border border-slate-200 text-slate-800 rounded-bl-xs'
                  }`}
                >
                  <p>{m.text}</p>
                  {m.link && (
                    <Link
                      to={m.link}
                      onClick={() => setIsOpen(false)}
                      className="mt-2 inline-flex items-center gap-1 text-[11px] font-semibold text-blue-600 hover:underline bg-blue-50 px-2 py-1 rounded"
                    >
                      {m.linkText || 'Learn more'}
                      <ArrowUpRight className="w-3 h-3" />
                    </Link>
                  )}
                </div>
                <span className="text-[10px] text-slate-400 mt-1 px-1">{m.time}</span>
              </div>
            ))}

            {isTyping && (
              <div className="flex items-center gap-1 bg-white border border-slate-200 px-3 py-2 rounded-2xl w-fit">
                <span className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce" />
                <span className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce [animation-delay:0.2s]" />
                <span className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce [animation-delay:0.4s]" />
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Quick Prompts */}
          <div className="px-3 py-2 bg-white border-t border-slate-100 flex gap-1.5 overflow-x-auto whitespace-nowrap scrollbar-none">
            {quickPrompts.map((p, idx) => (
              <button
                key={idx}
                onClick={() => handleSend(p)}
                className="text-[11px] bg-slate-100 hover:bg-blue-50 hover:text-blue-600 text-slate-700 px-2.5 py-1 rounded-full transition shrink-0"
              >
                {p}
              </button>
            ))}
          </div>

          {/* Input Bar */}
          <form
            onSubmit={(e) => {
              e.preventDefault();
              handleSend();
            }}
            className="p-3 bg-white border-t border-slate-200 flex items-center gap-2"
          >
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              placeholder="Ask anything about hostels & PGs..."
              className="flex-1 px-3 py-2 text-xs rounded-xl border border-slate-300 focus:outline-hidden focus:ring-2 focus:ring-blue-500"
            />
            <button
              type="submit"
              disabled={!input.trim()}
              className="p-2 bg-blue-600 hover:bg-blue-700 disabled:opacity-40 text-white rounded-xl shadow-xs transition"
            >
              <Send className="w-4 h-4" />
            </button>
          </form>

        </div>
      )}

    </div>
  );
};
