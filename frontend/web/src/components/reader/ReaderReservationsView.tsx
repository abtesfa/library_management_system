import React, { useState } from 'react';
import {
  Calendar,
  Hourglass,
  Clock,
  CheckCircle2,
  Search,
  Filter,
  MapPin,
  ArrowRight,
  Info,
  ChevronLeft,
  ChevronRight,
  Lightbulb,
  Bell,
  X
} from 'lucide-react';
import { Reservation } from '../../types';
import { BookCover } from '../common/BookCover';
import { CategoryBadge } from '../common/Badges';

interface ReaderReservationsViewProps {
  reservations: Reservation[];
  onCancelReservation: (reservationId: string) => void;
  onMarkPickedUp: (reservationId: string) => void;
}

export const ReaderReservationsView: React.FC<ReaderReservationsViewProps> = ({
  reservations,
  onCancelReservation,
  onMarkPickedUp
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);
  const [historyPage, setHistoryPage] = useState(1);

  const activeReservations = reservations.filter((r) => r.status === 'Active');
  const readyReservations = reservations.filter((r) => r.status === 'Ready for Pickup');
  const completedReservations = reservations.filter((r) => r.status === 'Completed');

  const handleCancel = (id: string, title: string) => {
    onCancelReservation(id);
    setToastMessage(`Cancelled reservation for "${title}".`);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const handlePickup = (id: string, title: string) => {
    onMarkPickedUp(id);
    setToastMessage(`Marked "${title}" as picked up! Added to borrowed books.`);
    setTimeout(() => setToastMessage(null), 3000);
  };

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      {/* Toast */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#1877F2] text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in fade-in duration-200">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">{toastMessage}</span>
        </div>
      )}

      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Reservations</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          View and manage your active reservations and reservation history.
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
            placeholder="Search by book title, author, or ISBN..."
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
            <Calendar className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Active Reservations</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">
              {activeReservations.length}
            </div>
            <div className="text-[11px] text-slate-400">Reservation</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-amber-600 shrink-0">
            <Hourglass className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Ready for Pickup</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">
              {readyReservations.length}
            </div>
            <div className="text-[11px] text-slate-400">Reservation</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-sky-100 flex items-center justify-center text-sky-600 shrink-0">
            <Clock className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Upcoming</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">0</div>
            <div className="text-[11px] text-slate-400">Reservations</div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Completed</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">
              {completedReservations.length}
            </div>
            <div className="text-[11px] text-slate-400">Reservations</div>
          </div>
        </div>
      </div>

      {/* Main Grid: Active & Ready & History (8 cols) + Policies & Pickups (4 cols) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column (8 cols) */}
        <div className="lg:col-span-8 space-y-6">
          {/* Active Reservations */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
              <Calendar className="w-5 h-5 text-blue-600" />
              <h3 className="font-bold text-slate-900 text-base">Active Reservations</h3>
            </div>

            {activeReservations.length === 0 ? (
              <p className="text-xs text-slate-500 py-2">No active reservations.</p>
            ) : (
              activeReservations.map((res) => (
                <div
                  key={res.id}
                  className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-slate-100 bg-slate-50/50 hover:bg-slate-50 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <BookCover
                      title={res.bookTitle}
                      coverImage="/web/src/assets/images/book_cover_gatsby_1791886212070.jpg"
                      size="sm"
                    />
                    <div>
                      <h4 className="font-bold text-sm text-slate-900">{res.bookTitle}</h4>
                      <p className="text-xs text-slate-500">{res.author}</p>
                      <div className="mt-1">
                        <CategoryBadge category="Fiction" />
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600">
                    <div>
                      <span className="text-[11px] text-slate-400 block">Reserved On</span>
                      <span className="font-mono text-slate-700">{res.reservedOn}</span>
                    </div>
                    <div>
                      <span className="text-[11px] text-slate-400 block">Pickup By</span>
                      <span className="font-mono text-slate-700">{res.pickupBy}</span>
                    </div>
                    <div>
                      <span className="text-[11px] text-slate-400 block">Pickup Location</span>
                      <span className="flex items-center gap-1 text-slate-700">
                        <MapPin className="w-3.5 h-3.5 text-blue-500" />
                        {res.pickupLocation}
                      </span>
                    </div>
                    <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-50 text-amber-700 border border-amber-200">
                      Expires in 10 days
                    </span>
                  </div>

                  <button
                    onClick={() => handleCancel(res.id, res.bookTitle)}
                    className="px-3.5 py-1.5 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold text-xs rounded-lg shadow-2xs whitespace-nowrap shrink-0"
                  >
                    Cancel Reservation
                  </button>
                </div>
              ))
            )}
          </div>

          {/* Ready for Pickup */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
              <Hourglass className="w-5 h-5 text-amber-600" />
              <h3 className="font-bold text-slate-900 text-base">Ready for Pickup</h3>
            </div>

            {readyReservations.length === 0 ? (
              <p className="text-xs text-slate-500 py-2">No books waiting for pickup.</p>
            ) : (
              readyReservations.map((res) => (
                <div
                  key={res.id}
                  className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl border border-amber-100 bg-amber-50/20 hover:bg-amber-50/30 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <BookCover title={res.bookTitle} coverTheme="atomic-habits" size="sm" />
                    <div>
                      <h4 className="font-bold text-sm text-slate-900">{res.bookTitle}</h4>
                      <p className="text-xs text-slate-500">{res.author}</p>
                      <div className="mt-1">
                        <CategoryBadge category="Self-Help" />
                      </div>
                    </div>
                  </div>

                  <div className="flex flex-wrap items-center gap-6 text-xs text-slate-600">
                    <div>
                      <span className="text-[11px] text-slate-400 block">Ready Since</span>
                      <span className="font-mono text-slate-700">{res.readySince}</span>
                    </div>
                    <div>
                      <span className="text-[11px] text-slate-400 block">Pickup By</span>
                      <span className="font-mono text-slate-700">{res.pickupBy}</span>
                    </div>
                    <div>
                      <span className="text-[11px] text-slate-400 block">Pickup Location</span>
                      <span className="flex items-center gap-1 text-slate-700">
                        <MapPin className="w-3.5 h-3.5 text-blue-500" />
                        {res.pickupLocation}
                      </span>
                    </div>
                    <span className="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-100 text-amber-800 border border-amber-200">
                      Ready for 3 days
                    </span>
                  </div>

                  <button
                    onClick={() => handlePickup(res.id, res.bookTitle)}
                    className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-semibold text-xs rounded-lg shadow-sm whitespace-nowrap shrink-0"
                  >
                    Mark as Picked Up
                  </button>
                </div>
              ))
            )}
          </div>

          {/* Reservation History */}
          <div className="bg-white rounded-xl border border-slate-200/80 shadow-sm overflow-hidden">
            <div className="p-4 px-6 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Clock className="w-5 h-5 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-base">Reservation History</h3>
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
                    <th className="py-3 px-4">Author</th>
                    <th className="py-3 px-4">Reserved On</th>
                    <th className="py-3 px-4">Status</th>
                    <th className="py-3 px-4">Completed On</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 text-slate-700">
                  {completedReservations.map((item) => (
                    <tr key={item.id} className="hover:bg-slate-50/50 transition-colors">
                      <td className="py-3.5 px-4 font-semibold text-slate-900">
                        {item.bookTitle}
                      </td>
                      <td className="py-3.5 px-4 text-slate-600">
                        {item.author}
                      </td>
                      <td className="py-3.5 px-4 font-mono text-slate-600 text-[11px]">
                        {item.reservedOn}
                      </td>
                      <td className="py-3.5 px-4">
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-100 text-emerald-700">
                          Completed
                        </span>
                      </td>
                      <td className="py-3.5 px-4 font-mono text-slate-600 text-[11px]">
                        {item.completedOn}
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
              {[1, 2].map((p) => (
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
                disabled={historyPage >= 2}
                onClick={() => setHistoryPage((p) => Math.min(2, p + 1))}
                className="w-7 h-7 flex items-center justify-center rounded border border-slate-200 text-slate-600"
              >
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>

        {/* Right Column (4 cols) */}
        <div className="lg:col-span-4 space-y-6">
          {/* Reservation Policies Card */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center gap-2 border-b border-slate-100 pb-3">
              <Info className="w-4 h-4 text-blue-600" />
              <h3 className="font-bold text-slate-900 text-sm">Reservation Policies</h3>
            </div>

            <ul className="space-y-2.5 text-xs text-slate-600 list-disc list-inside leading-relaxed">
              <li>You can reserve up to 3 books at a time.</li>
              <li>You will be notified when your book is ready for pickup.</li>
              <li>Reserved books will be held for 7 days.</li>
              <li>Please cancel if you no longer need the book.</li>
            </ul>
          </div>

          {/* Upcoming Pickups */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Upcoming Pickups</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
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
                  <div className="text-[10px] text-slate-500">F. Scott Fitzgerald</div>
                  <div className="text-[10px] text-slate-400 mt-0.5 font-mono">Pickup by May 29, 2026</div>
                </div>
              </div>
              <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-sky-50 text-sky-700 border border-sky-200">
                Upcoming
              </span>
            </div>
          </div>

          {/* Recently Completed */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm space-y-4">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Recently Completed</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3.5">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <BookCover
                    title="Dune"
                    coverImage="/web/src/assets/images/book_cover_dune_1791886211742.jpg"
                    size="xs"
                  />
                  <div>
                    <div className="text-xs font-bold text-slate-900">Dune</div>
                    <div className="text-[10px] text-slate-500">Frank Herbert</div>
                  </div>
                </div>
                <div className="text-right text-[10px] text-slate-400">
                  <span>Completed on</span>
                  <div className="font-mono text-slate-600">Apr 27, 2026</div>
                </div>
              </div>

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
                  <span>Completed on</span>
                  <div className="font-mono text-slate-600">Apr 17, 2026</div>
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
                  <span>Completed on</span>
                  <div className="font-mono text-slate-600">Apr 2, 2026</div>
                </div>
              </div>
            </div>
          </div>

          {/* Need help CTA */}
          <div className="p-5 bg-blue-50/50 border border-blue-100 rounded-xl space-y-3">
            <div className="w-9 h-9 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center">
              <Lightbulb className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-xs font-bold text-slate-900">Need help with reservations?</h4>
              <p className="text-xs text-slate-600 mt-0.5 leading-snug">
                Find answers to common questions about reservations and pickups.
              </p>
            </div>
            <button
              onClick={() => {}}
              className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white font-semibold text-xs rounded-lg transition-colors w-full"
            >
              View Help Center
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
