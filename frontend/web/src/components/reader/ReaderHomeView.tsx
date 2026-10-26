import React, { useState } from 'react';
import {
  Search,
  BookOpen,
  Clock,
  Calendar,
  Bell,
  ArrowRight,
  Sparkles,
  CheckCircle2,
  Info
} from 'lucide-react';
import { Book } from '../../types';
import { BookCover } from '../common/BookCover';
import { CategoryBadge } from '../common/Badges';

interface ReaderHomeViewProps {
  books: Book[];
  onReserveBook: (book: Book) => void;
  onNavigate: (navId: string) => void;
}

export const ReaderHomeView: React.FC<ReaderHomeViewProps> = ({
  books,
  onReserveBook,
  onNavigate
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [reservedTitle, setReservedTitle] = useState<string | null>(null);

  const recommendedBooks = books.slice(0, 5);

  const handleReserve = (book: Book) => {
    onReserveBook(book);
    setReservedTitle(book.title);
    setTimeout(() => setReservedTitle(null), 3000);
  };

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      {/* Toast */}
      {reservedTitle && (
        <div className="fixed top-20 right-8 z-50 bg-[#1877F2] text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in fade-in duration-200">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">
            Reserved "{reservedTitle}"! You'll be notified when it's ready.
          </span>
        </div>
      )}

      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Welcome back, Abiye!</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Discover new books, continue your reading journey, and explore the library's resources.
        </p>
      </div>

      {/* Main Grid: Reader Catalog (8 cols) + Reader Sidebar (4 cols) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column (8 cols) */}
        <div className="lg:col-span-8 space-y-6">
          {/* Search bar */}
          <div className="flex gap-2">
            <div className="relative flex-1">
              <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="Search for books, authors, or genres..."
                className="w-full pl-10 pr-4 py-2.5 text-sm bg-white border border-slate-200/90 rounded-xl text-slate-800 placeholder-slate-400 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
              />
            </div>
            <button className="px-6 py-2.5 bg-[#1877F2] hover:bg-blue-600 text-white font-semibold text-sm rounded-xl shadow-sm flex items-center gap-2 transition-colors shrink-0">
              <Search className="w-4 h-4" />
              <span>Search</span>
            </button>
          </div>

          {/* Hero Banner with library study background */}
          <div className="relative rounded-2xl overflow-hidden shadow-md min-h-[220px] flex items-center p-8 border border-slate-200/60">
            {/* Background image */}
            <img
              src="/web/src/assets/images/reader_hero_library_study_1791886210314.jpg"
              alt="Library Study Space"
              referrerPolicy="no-referrer"
              className="absolute inset-0 w-full h-full object-cover"
              onError={(e) => {
                (e.target as HTMLElement).style.display = 'none';
              }}
            />
            {/* Semi-transparent dark/blue gradient scrim for contrast */}
            <div className="absolute inset-0 bg-gradient-to-r from-blue-950/85 via-blue-900/60 to-transparent"></div>

            <div className="relative z-10 max-w-lg text-white space-y-3">
              <h2 className="text-3xl font-extrabold tracking-tight leading-tight text-white drop-shadow">
                Good Books<br />Build Better Futures
              </h2>
              <p className="text-sm text-blue-100 font-medium leading-relaxed drop-shadow-sm">
                Explore new worlds, gain new perspectives, and keep reading!
              </p>
            </div>
          </div>

          {/* Recommended Books Section */}
          <div className="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm space-y-5">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-blue-600" />
                <h3 className="text-base font-bold text-slate-900">Recommended Books</h3>
              </div>
              <button
                onClick={() => onNavigate('my-books')}
                className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1"
              >
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            {/* Books Cards Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
              {recommendedBooks.map((book) => (
                <div
                  key={book.id}
                  className="flex flex-col justify-between p-3 rounded-xl border border-slate-100 hover:border-blue-200 hover:shadow-md transition-all group bg-slate-50/40"
                >
                  <div className="space-y-2.5">
                    <div className="aspect-[3/4] w-full flex items-center justify-center overflow-hidden rounded-lg shadow-sm">
                      <BookCover
                        title={book.title}
                        author={book.author}
                        coverImage={book.coverImage}
                        coverTheme={book.coverTheme}
                        size="md"
                        className="w-full h-full"
                      />
                    </div>

                    <div>
                      <h4 className="font-bold text-xs text-slate-900 line-clamp-1 group-hover:text-blue-600 transition-colors">
                        {book.title}
                      </h4>
                      <p className="text-[11px] text-slate-500 line-clamp-1 mt-0.5">
                        {book.author}
                      </p>
                      <div className="mt-1.5">
                        <CategoryBadge category={book.category} />
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => handleReserve(book)}
                    className="mt-3 w-full py-1.5 px-2 bg-white hover:bg-blue-50 border border-blue-400 text-blue-600 font-semibold text-xs rounded-lg flex items-center justify-center gap-1.5 transition-colors shadow-2xs"
                  >
                    <Calendar className="w-3.5 h-3.5" />
                    <span>Reserve</span>
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Column (4 cols) */}
        <div className="lg:col-span-4 space-y-6">
          {/* My Reading Summary */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
              <BookOpen className="w-4 h-4 text-blue-600" />
              <h3 className="font-bold text-slate-900 text-sm">My Reading Summary</h3>
            </div>

            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 bg-blue-50/40 rounded-xl border border-blue-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold">
                  <BookOpen className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900 tabular-nums">3</div>
                  <div className="text-[11px] text-slate-500">Books Borrowed</div>
                </div>
              </div>

              <div className="p-3 bg-sky-50/40 rounded-xl border border-sky-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-sky-100 text-sky-600 flex items-center justify-center font-bold">
                  <Clock className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900 tabular-nums">1</div>
                  <div className="text-[11px] text-slate-500">Due Soon</div>
                </div>
              </div>

              <div className="p-3 bg-emerald-50/40 rounded-xl border border-emerald-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center font-bold">
                  <Calendar className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900 tabular-nums">1</div>
                  <div className="text-[11px] text-slate-500">Reservation(s)</div>
                </div>
              </div>

              <div className="p-3 bg-rose-50/40 rounded-xl border border-rose-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center font-bold">
                  <Bell className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-xl font-bold text-slate-900 tabular-nums">2</div>
                  <div className="text-[11px] text-slate-500">Notifications</div>
                </div>
              </div>
            </div>
          </div>

          {/* Upcoming Due Dates */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Upcoming Due Dates</h3>
              </div>
              <button
                onClick={() => onNavigate('my-books')}
                className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1"
              >
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover title="Atomic Habits" coverTheme="atomic-habits" size="xs" />
                  <div>
                    <div className="text-xs font-bold text-slate-900">Atomic Habits</div>
                    <div className="text-[11px] text-slate-500">James Clear</div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-rose-50 text-rose-700 border border-rose-200">
                  Due in 2 days
                </span>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover
                    title="Dune"
                    coverImage="/web/src/assets/images/book_cover_dune_1791886211742.jpg"
                    size="xs"
                  />
                  <div>
                    <div className="text-xs font-bold text-slate-900">Dune</div>
                    <div className="text-[11px] text-slate-500">Frank Herbert</div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                  Due in 5 days
                </span>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover
                    title="The Great Gatsby"
                    coverImage="/web/src/assets/images/book_cover_gatsby_1791886212070.jpg"
                    size="xs"
                  />
                  <div>
                    <div className="text-xs font-bold text-slate-900">The Great Gatsby</div>
                    <div className="text-[11px] text-slate-500">F. Scott Fitzgerald</div>
                  </div>
                </div>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                  Due in 7 days
                </span>
              </div>
            </div>
          </div>

          {/* Recent Notifications */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Recent Notifications</h3>
              </div>
              <button
                onClick={() => onNavigate('reader-notifications')}
                className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1"
              >
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center shrink-0 mt-0.5">
                  <Bell className="w-3.5 h-3.5" />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-slate-800">
                    Your book "Atomic Habits" is due in 2 days.
                  </div>
                  <div className="text-[10px] text-slate-400 mt-0.5">2 hours ago</div>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center shrink-0 mt-0.5">
                  <Info className="w-3.5 h-3.5" />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-slate-800">
                    Your reservation for "The Martian" is now available.
                  </div>
                  <div className="text-[10px] text-slate-400 mt-0.5">1 day ago</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
