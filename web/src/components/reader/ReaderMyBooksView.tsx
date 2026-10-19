import React, { useState } from 'react';
import {
  BookOpen,
  Clock,
  AlertTriangle,
  CheckCircle2,
  Search,
  Filter,
  ArrowRight,
  ChevronLeft,
  ChevronRight,
  Lightbulb,
  RotateCcw
} from 'lucide-react';
import { BorrowRecord } from '../../types';
import { BookCover } from '../common/BookCover';
import { CategoryBadge } from '../common/Badges';

interface ReaderMyBooksViewProps {
  borrowedBooks: BorrowRecord[];
  historyBooks: BorrowRecord[];
  onRenewBook: (recordId: string) => void;
  onExploreRecommendations: () => void;
}

export const ReaderMyBooksView: React.FC<ReaderMyBooksViewProps> = ({
  borrowedBooks,
  historyBooks,
  onRenewBook,
  onExploreRecommendations
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [renewedId, setRenewedId] = useState<string | null>(null);
  const [historyPage, setHistoryPage] = useState(1);

  const handleRenew = (recordId: string) => {
    onRenewBook(recordId);
    setRenewedId(recordId);
    setTimeout(() => setRenewedId(null), 3000);
  };

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      {/* Toast */}
      {renewedId && (
        <div className="fixed top-20 right-8 z-50 bg-[#1877F2] text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in fade-in duration-200">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">Book renewed successfully! Due date extended by 14 days.</span>
        </div>
      )}

      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">My Books</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Manage your borrowed books, due dates, and reading history.
        </p>
      </div>

      {/* Search & Filter Bar */}
      <div className="flex gap-3">
        <div className="relative flex-1">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search my books..."
            className="w-full pl-10 pr-4 py-2 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 placeholder-slate-400 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          />
        </div>
        <button className="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-semibold text-slate-700 hover:bg-slate-50 shadow-sm flex items-center gap-2 shrink-0">
          <Filter className="w-4 h-4 text-slate-500" />
          <span>Filter & Sort</span>
        </button>
      </div>

      {/* 4 Stat Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
            <BookOpen className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Currently Borrowed</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">3</div>
            <div className="text-[11px] text-slate-400">Books</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-amber-600 shrink-0">
            <Clock className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Due Soon</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">1</div>
            <div className="text-[11px] text-slate-400">Book</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-rose-100 flex items-center justify-center text-rose-600 shrink-0">
            <AlertTriangle className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Overdue</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">0</div>
            <div className="text-[11px] text-slate-400">Books</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Completed</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">8</div>
            <div className="text-[11px] text-slate-400">Books</div>
          </div>
        </div>
      </div>

      {/* Main Grid: Currently Borrowed & History (8 cols) + Progress & Recent (4 cols) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column (8 cols) */}
        <div className="lg:col-span-8 space-y-6">
          {/* Section 1: Currently Borrowed */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-base">Currently Borrowed</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-4">
              {/* Book 1: Atomic Habits */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                <div className="flex items-center gap-4">
                  <BookCover title="Atomic Habits" coverTheme="atomic-habits" size="sm" />
                  <div>
                    <h4 className="font-bold text-sm text-slate-900">Atomic Habits</h4>
                    <p className="text-xs text-slate-500">James Clear</p>
                    <div className="mt-1">
                      <CategoryBadge category="Self-Help" />
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600">
                  <div>
                    <span className="text-[11px] text-slate-400 block">Borrowed</span>
                    <span className="font-mono text-slate-700">Oct 2, 2026</span>
                  </div>
                  <div>
                    <span className="text-[11px] text-slate-400 block">Due</span>
                    <span className="font-mono text-slate-700">Oct 10, 2026</span>
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                    Due in 2 days
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-xs rounded-lg shadow-2xs">
                    View Details
                  </button>
                  <button
                    onClick={() => handleRenew('br-1')}
                    className="px-3.5 py-1.5 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-semibold text-xs rounded-lg shadow-2xs"
                  >
                    Renew
                  </button>
                </div>
              </div>

              {/* Book 2: Dune */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                <div className="flex items-center gap-4">
                  <BookCover
                    title="Dune"
                    coverImage="/web/src/assets/images/book_cover_dune_1791886211742.jpg"
                    size="sm"
                  />
                  <div>
                    <h4 className="font-bold text-sm text-slate-900">Dune</h4>
                    <p className="text-xs text-slate-500">Frank Herbert</p>
                    <div className="mt-1">
                      <CategoryBadge category="Science Fiction" />
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600">
                  <div>
                    <span className="text-[11px] text-slate-400 block">Borrowed</span>
                    <span className="font-mono text-slate-700">Sep 28, 2026</span>
                  </div>
                  <div>
                    <span className="text-[11px] text-slate-400 block">Due</span>
                    <span className="font-mono text-slate-700">Oct 13, 2026</span>
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                    Due in 5 days
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-xs rounded-lg shadow-2xs">
                    View Details
                  </button>
                  <button
                    onClick={() => handleRenew('br-2')}
                    className="px-3.5 py-1.5 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-semibold text-xs rounded-lg shadow-2xs"
                  >
                    Renew
                  </button>
                </div>
              </div>

              {/* Book 3: The Great Gatsby */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-slate-50 transition-colors">
                <div className="flex items-center gap-4">
                  <BookCover
                    title="The Great Gatsby"
                    coverImage="/web/src/assets/images/book_cover_gatsby_1791886212070.jpg"
                    size="sm"
                  />
                  <div>
                    <h4 className="font-bold text-sm text-slate-900">The Great Gatsby</h4>
                    <p className="text-xs text-slate-500">F. Scott Fitzgerald</p>
                    <div className="mt-1">
                      <CategoryBadge category="Fiction" />
                    </div>
                  </div>
                </div>

                <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600">
                  <div>
                    <span className="text-[11px] text-slate-400 block">Borrowed</span>
                    <span className="font-mono text-slate-700">Sep 25, 2026</span>
                  </div>
                  <div>
                    <span className="text-[11px] text-slate-400 block">Due</span>
                    <span className="font-mono text-slate-700">Oct 15, 2026</span>
                  </div>
                  <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                    Due in 7 days
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button className="px-3 py-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-xs rounded-lg shadow-2xs">
                    View Details
                  </button>
                  <button
                    onClick={() => handleRenew('br-3')}
                    className="px-3.5 py-1.5 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-semibold text-xs rounded-lg shadow-2xs"
                  >
                    Renew
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* Section 2: Borrowing History */}
          <div className="bg-white rounded-xl border border-slate-200/80 shadow-sm overflow-hidden">
            <div className="p-4 px-6 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <RotateCcw className="w-5 h-5 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-base">Borrowing History</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All History <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="bg-slate-50/70 border-b border-slate-200 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
                    <th className="py-3 px-4">Book Title</th>
                    <th className="py-3 px-4">Borrowed Date</th>
                    <th className="py-3 px-4">Returned / Due Date</th>
                    <th className="py-3 px-4">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-slate-700">
                  {historyBooks.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50/50 transition-colors">
                      <td className="py-3.5 px-4 font-semibold text-slate-900">
                        {item.bookTitle}
                      </td>
                      <td className="py-3.5 px-4 font-mono text-slate-600 text-[11px]">
                        {item.borrowDate}
                      </td>
                      <td className="py-3.5 px-4 font-mono text-slate-600 text-[11px]">
                        {item.returnDate || item.dueDate}
                      </td>
                      <td className="py-3.5 px-4">
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-100 text-emerald-700">
                          Returned
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="p-3 px-6 border-t border-slate-100 flex items-center justify-center gap-1 text-xs">
              <button
                disabled={historyPage <= 1}
                onClick={() => setHistoryPage((p) => Math.max(1, p - 1))}
                className="w-7 h-7 flex items-center justify-center rounded border border-slate-200 text-slate-600 disabled:opacity-40"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
              {[1, 2, 3].map((p) => (
                <button
                  key={p}
                  onClick={() => setHistoryPage(p)}
                  className={`w-7 h-7 flex items-center justify-center rounded text-xs font-semibold ${
                    historyPage === p
                      ? 'bg-[#1877F2] text-white'
                      : 'border border-slate-200 text-slate-700 hover:bg-slate-50'
                  }`}
                >
                  {p}
                </button>
              ))}
              <button
                disabled={historyPage >= 3}
                onClick={() => setHistoryPage((p) => Math.min(3, p + 1))}
                className="w-7 h-7 flex items-center justify-center rounded border border-slate-200 text-slate-600"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Right Column (4 cols) */}
        <div className="lg:col-span-4 space-y-6">
          {/* Reading Progress Card */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
              <span className="text-blue-600 font-bold">📈</span>
              <h3 className="font-bold text-slate-900 text-sm">Reading Progress</h3>
            </div>

            <div className="flex items-center gap-5">
              {/* Circular SVG gauge */}
              <div className="relative w-24 h-24 shrink-0 flex items-center justify-center">
                <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    fill="transparent"
                    stroke="#E2E8F0"
                    strokeWidth="10"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="40"
                    fill="transparent"
                    stroke="#1877F2"
                    strokeWidth="10"
                    strokeDasharray="251.32"
                    strokeDashoffset="83.77" // 8/12 = 66.6%
                    strokeLinecap="round"
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                  <span className="text-2xl font-black text-[#1877F2] leading-none tabular-nums">
                    8
                  </span>
                  <span className="text-[11px] text-slate-400 font-bold">/12</span>
                </div>
              </div>

              <div className="text-xs space-y-1">
                <div className="font-bold text-slate-900">
                  Books completed this month
                </div>
                <p className="text-[11px] text-slate-500 leading-tight">
                  Keep going, Abiye! You're on a great pace.
                </p>
              </div>
            </div>

            <button
              onClick={() => {}}
              className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1 pt-1"
            >
              View Reading History <ArrowRight className="w-3 h-3" />
            </button>
          </div>

          {/* Recently Returned List */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Clock className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Recently Returned</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3.5">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover
                    title="Clean Code"
                    coverImage="/web/src/assets/images/book_cover_cleancode_1791886211255.jpg"
                    size="xs"
                  />
                  <div>
                    <div className="text-xs font-bold text-slate-900">Clean Code</div>
                    <div className="text-[10px] text-slate-500">Robert C. Martin</div>
                  </div>
                </div>
                <div className="text-right text-[10px] text-slate-400">
                  <span>Returned</span>
                  <div className="font-mono text-slate-600">Oct 1, 2026</div>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover title="Sapiens" coverTheme="sapiens" size="xs" />
                  <div>
                    <div className="text-xs font-bold text-slate-900">Sapiens</div>
                    <div className="text-[10px] text-slate-500">Yuval Noah Harari</div>
                  </div>
                </div>
                <div className="text-right text-[10px] text-slate-400">
                  <span>Returned</span>
                  <div className="font-mono text-slate-600">Sep 27, 2026</div>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover title="1984" coverTheme="1984" size="xs" />
                  <div>
                    <div className="text-xs font-bold text-slate-900">1984</div>
                    <div className="text-[10px] text-slate-500">George Orwell</div>
                  </div>
                </div>
                <div className="text-right text-[10px] text-slate-400">
                  <span>Returned</span>
                  <div className="font-mono text-slate-600">Sep 20, 2026</div>
                </div>
              </div>
            </div>
          </div>

          {/* Book Recommendation CTA */}
          <div className="p-5 bg-blue-50/50 border border-blue-100 rounded-xl space-y-3">
            <div className="w-9 h-9 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
              <Lightbulb className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-slate-900">Need a book recommendation?</h4>
              <p className="text-xs text-slate-600 mt-0.5 leading-snug">
                Discover books tailored to your interests and reading history.
              </p>
            </div>
            <button
              onClick={onExploreRecommendations}
              className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white font-semibold text-xs rounded-lg transition-colors w-full"
            >
              Explore Recommendations
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
