import React, { useState, useEffect } from 'react';
import { 
  HelpCircle, 
  ChevronDown, 
  ChevronUp, 
  ThumbsUp, 
  ThumbsDown, 
  Search, 
  Send, 
  Sparkles,
  CheckCircle,
  MessageSquare
} from 'lucide-react';
import { FAQItem } from '../types';
import { faqApi } from '../services/api';

export const FAQPage: React.FC = () => {
  const [faqs, setFaqs] = useState<FAQItem[]>([]);
  const [search, setSearch] = useState('');
  const [activeCategory, setActiveCategory] = useState<string>('All');
  const [expandedId, setExpandedId] = useState<number | null>(1);
  const [newQuestion, setNewQuestion] = useState('');
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    faqApi.getAll().then((data) => setFaqs(data));
  }, []);

  const handleVote = async (id: number, type: 'like' | 'dislike') => {
    await faqApi.vote(id, type);
    setFaqs((prev) =>
      prev.map((f) => {
        if (f.id === id) {
          return {
            ...f,
            likes: type === 'like' ? f.likes + 1 : f.likes,
            dislikes: type === 'dislike' ? f.dislikes + 1 : f.dislikes,
            user_vote: type,
          };
        }
        return f;
      })
    );
  };

  const categories = ['All', 'Payments', 'Safety', 'Eligibility', 'Cancellations', 'Communication'];

  const filteredFaqs = faqs.filter((f) => {
    const matchesSearch =
      f.question.toLowerCase().includes(search.toLowerCase()) ||
      f.answer.toLowerCase().includes(search.toLowerCase());
    const matchesCategory =
      activeCategory === 'All' || f.category.toLowerCase() === activeCategory.toLowerCase();
    return matchesSearch && matchesCategory;
  });

  const handleSubmitQuestion = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newQuestion.trim()) return;

    const created: FAQItem = {
      id: Date.now(),
      question: newQuestion.trim(),
      answer: 'Thank you for submitting! Our team will review and post an answer shortly.',
      category: 'General',
      likes: 1,
      dislikes: 0,
    };
    setFaqs([created, ...faqs]);
    setNewQuestion('');
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 4000);
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      
      {/* Header */}
      <div className="text-center max-w-2xl mx-auto mb-10">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-700 text-xs font-semibold mb-3">
          <HelpCircle className="w-3.5 h-3.5" />
          <span>Student Knowledgebase & Support</span>
        </div>
        <h1 className="text-3xl font-extrabold text-slate-900 mb-3">Frequently Asked Questions</h1>
        <p className="text-xs sm:text-sm text-slate-500">
          Everything you need to know about reserving rooms, verifying owners, and paying token deposits.
        </p>
      </div>

      {/* Search Input */}
      <div className="relative mb-8 max-w-xl mx-auto">
        <Search className="w-5 h-5 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2" />
        <input
          type="text"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search questions (e.g. UPI token, refund, curfew, food)..."
          className="w-full pl-12 pr-4 py-3 bg-white rounded-2xl border border-slate-300 text-sm focus:outline-hidden focus:ring-2 focus:ring-blue-500 shadow-xs"
        />
      </div>

      {/* Category Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-4 mb-6 scrollbar-none justify-center">
        {categories.map((c) => (
          <button
            key={c}
            onClick={() => setActiveCategory(c)}
            className={`px-3.5 py-1.5 rounded-xl text-xs font-semibold transition shrink-0 ${
              activeCategory === c
                ? 'bg-blue-600 text-white shadow-xs'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            {c}
          </button>
        ))}
      </div>

      {/* FAQs Accordion */}
      <div className="space-y-3 mb-12">
        {filteredFaqs.map((faq) => {
          const isOpen = expandedId === faq.id;
          return (
            <div
              key={faq.id}
              className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-xs transition"
            >
              <button
                onClick={() => setExpandedId(isOpen ? null : faq.id)}
                className="w-full px-6 py-4.5 text-left flex items-center justify-between gap-4 hover:bg-slate-50/50 transition"
              >
                <div className="flex items-center gap-3">
                  <span className="w-7 h-7 rounded-lg bg-blue-50 text-blue-600 font-bold text-xs flex items-center justify-center shrink-0">
                    Q
                  </span>
                  <span className="font-semibold text-slate-900 text-sm">{faq.question}</span>
                </div>
                {isOpen ? (
                  <ChevronUp className="w-4 h-4 text-slate-400 shrink-0" />
                ) : (
                  <ChevronDown className="w-4 h-4 text-slate-400 shrink-0" />
                )}
              </button>

              {isOpen && (
                <div className="px-6 pb-5 pt-2 text-xs text-slate-600 leading-relaxed border-t border-slate-100 bg-slate-50/30">
                  <p className="mb-4">{faq.answer}</p>

                  <div className="flex items-center justify-between pt-2 border-t border-slate-200/60 text-[11px] text-slate-500">
                    <span className="bg-slate-100 text-slate-600 px-2 py-0.5 rounded font-medium">
                      Category: {faq.category}
                    </span>

                    <div className="flex items-center gap-3">
                      <span>Was this helpful?</span>
                      <button
                        onClick={() => handleVote(faq.id, 'like')}
                        className={`flex items-center gap-1 px-2 py-1 rounded-lg border transition ${
                          faq.user_vote === 'like'
                            ? 'bg-emerald-50 text-emerald-700 border-emerald-300 font-bold'
                            : 'hover:bg-slate-100 border-slate-200'
                        }`}
                      >
                        <ThumbsUp className="w-3 h-3" />
                        <span>{faq.likes}</span>
                      </button>

                      <button
                        onClick={() => handleVote(faq.id, 'dislike')}
                        className={`flex items-center gap-1 px-2 py-1 rounded-lg border transition ${
                          faq.user_vote === 'dislike'
                            ? 'bg-rose-50 text-rose-700 border-rose-300 font-bold'
                            : 'hover:bg-slate-100 border-slate-200'
                        }`}
                      >
                        <ThumbsDown className="w-3 h-3" />
                        <span>{faq.dislikes}</span>
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Submit a Question Card */}
      <div className="bg-gradient-to-br from-indigo-50 to-blue-50 border border-blue-200/60 rounded-3xl p-6 sm:p-8">
        <div className="flex items-center gap-2 mb-2">
          <MessageSquare className="w-4 h-4 text-blue-600" />
          <h3 className="font-bold text-slate-900 text-base">Have another question?</h3>
        </div>
        <p className="text-xs text-slate-500 mb-4">
          Can't find what you're looking for? Submit your query and our team will answer it.
        </p>

        <form onSubmit={handleSubmitQuestion} className="space-y-3">
          <input
            type="text"
            value={newQuestion}
            onChange={(e) => setNewQuestion(e.target.value)}
            placeholder="Type your question here (e.g. Can parents stay overnight?)..."
            required
            className="w-full px-4 py-3 bg-white rounded-xl border border-slate-300 text-xs sm:text-sm focus:outline-hidden focus:ring-2 focus:ring-blue-500"
          />
          <div className="flex justify-end">
            <button
              type="submit"
              className="px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs rounded-xl shadow-md transition flex items-center gap-2"
            >
              <Send className="w-3.5 h-3.5" />
              <span>Submit Question</span>
            </button>
          </div>
        </form>

        {submitted && (
          <div className="mt-3 p-3 bg-emerald-100/70 text-emerald-800 text-xs rounded-xl flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-600" />
            <span>Question submitted successfully!</span>
          </div>
        )}
      </div>

    </div>
  );
};
