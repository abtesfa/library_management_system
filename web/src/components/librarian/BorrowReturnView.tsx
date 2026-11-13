import React, { useState } from 'react';
import {
  BookOpen,
  ArrowLeftRight,
  Search,
  Calendar,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Bell,
  ArrowRight,
  Info,
  BookCheck,
  Check
} from 'lucide-react';
import { Book, BorrowRecord } from '../../types';
import { BookCover } from '../common/BookCover';

interface BorrowReturnViewProps {
  books: Book[];
  onBorrowBook: (studentId: string, studentName: string, book: Book) => void;
  onReturnBook: (studentId: string, bookId: string, condition: string) => void;
}

export const BorrowReturnView: React.FC<BorrowReturnViewProps> = ({
  books,
  onBorrowBook,
  onReturnBook
}) => {
  // Borrow state
  const [borrowStudentId, setBorrowStudentId] = useState('S-00123');
  const [borrowBookQuery, setBorrowBookQuery] = useState('The Great Gatsby');
  const [borrowSuccess, setBorrowSuccess] = useState(false);

  // Return state
  const [returnStudentId, setReturnStudentId] = useState('S-00123');
  const [returnBookQuery, setReturnBookQuery] = useState('The Great Gatsby');
  const [bookCondition, setBookCondition] = useState<'Good' | 'Minor damage' | 'Lost'>('Good');
  const [returnSuccess, setReturnSuccess] = useState(false);

  const selectedBorrowBook = books.find(
    (b) =>
      b.title.toLowerCase().includes(borrowBookQuery.toLowerCase()) ||
      b.isbn.includes(borrowBookQuery)
  ) || books[2]; // Default to Great Gatsby

  const handleConfirmBorrow = () => {
    onBorrowBook(borrowStudentId, 'Abebe Kebede', selectedBorrowBook);
    setBorrowSuccess(true);
    setTimeout(() => setBorrowSuccess(false), 3000);
  };

  const handleConfirmReturn = () => {
    onReturnBook(returnStudentId, selectedBorrowBook.id, bookCondition);
    setReturnSuccess(true);
    setTimeout(() => setReturnSuccess(false), 3000);
  };

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      {/* Toast notifications */}
      {borrowSuccess && (
        <div className="fixed top-20 right-8 z-50 bg-[#1877F2] text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in fade-in duration-200">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">Book successfully issued to student!</span>
        </div>
      )}
      {returnSuccess && (
        <div className="fixed top-20 right-8 z-50 bg-emerald-600 text-white px-5 py-3 rounded-xl shadow-xl flex items-center gap-2.5 animate-in fade-in duration-200">
          <CheckCircle2 className="w-5 h-5" />
          <span className="text-sm font-semibold">Book return processed successfully! Fine recorded.</span>
        </div>
      )}

      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Welcome back, Sara!</h1>
        <p className="text-sm text-slate-500 mt-0.5">
          Borrow books, process returns, and keep track of your library activities.
        </p>
      </div>

      {/* Main Grid: Borrow & Return Panels (Left 8 cols) + Right Summary & Upcoming (4 cols) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left 8 cols: 2 workflow cards side-by-side */}
        <div className="lg:col-span-8 grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Card 1: Borrow Book */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-5">
            <div className="flex items-center gap-3 border-b border-slate-100 pb-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
                <BookOpen className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-base font-bold text-slate-900">Borrow Book</h2>
                <p className="text-xs text-slate-500">Issue a book to a student</p>
              </div>
            </div>

            {/* Student ID search */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Student ID <span className="text-rose-500">*</span>
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs">👤</span>
                  <input
                    type="text"
                    value={borrowStudentId}
                    onChange={(e) => setBorrowStudentId(e.target.value)}
                    placeholder="Enter student ID (e.g. S-00123)"
                    className="w-full pl-8 pr-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-lg text-slate-800 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <button className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white text-xs font-semibold rounded-lg flex items-center gap-1.5 transition-colors shrink-0">
                  <Search className="w-3.5 h-3.5" />
                  <span>Search</span>
                </button>
              </div>
            </div>

            {/* Book Title or ISBN search */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Book Title or ISBN <span className="text-rose-500">*</span>
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={borrowBookQuery}
                    onChange={(e) => setBorrowBookQuery(e.target.value)}
                    placeholder="Enter book title or ISBN (e.g. 978-0132357059)"
                    className="w-full pl-8 pr-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-lg text-slate-800 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <button className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white text-xs font-semibold rounded-lg flex items-center gap-1.5 transition-colors shrink-0">
                  <Search className="w-3.5 h-3.5" />
                  <span>Search</span>
                </button>
              </div>
            </div>

            {/* Book Information Card */}
            <div className="p-3.5 bg-blue-50/50 border border-blue-100 rounded-xl space-y-2 text-xs">
              <div className="flex items-center gap-1.5 font-bold text-blue-900 text-xs">
                <Bell className="w-3.5 h-3.5 text-blue-600" />
                <span>Book Information</span>
              </div>
              <div className="space-y-1 text-slate-600 pt-1">
                <div className="flex justify-between">
                  <span className="text-slate-500">Title:</span>
                  <span className="font-semibold text-slate-800">{selectedBorrowBook.title}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Author:</span>
                  <span className="font-medium text-slate-700">{selectedBorrowBook.author}</span>
                </div>
                <div className="flex justify-between font-mono text-[11px]">
                  <span className="text-slate-500 font-sans">ISBN:</span>
                  <span className="text-slate-600">{selectedBorrowBook.isbn}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Available Copies:</span>
                  <span className="font-bold text-slate-900 tabular-nums">{selectedBorrowBook.availableCopies}</span>
                </div>
              </div>
            </div>

            {/* Student Information Card */}
            <div className="p-3.5 bg-emerald-50/40 border border-emerald-100 rounded-xl space-y-2 text-xs">
              <div className="flex items-center gap-1.5 font-bold text-emerald-900 text-xs">
                <span className="text-emerald-600">👤</span>
                <span>Student Information</span>
              </div>
              <div className="space-y-1 text-slate-600 pt-1">
                <div className="flex justify-between">
                  <span className="text-slate-500">Name:</span>
                  <span className="font-semibold text-slate-800">Abebe Kebede</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Student ID:</span>
                  <span className="font-mono text-slate-700">{borrowStudentId}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Department:</span>
                  <span className="text-slate-700 font-medium">Computer Science</span>
                </div>
              </div>
            </div>

            {/* Borrowing Details */}
            <div className="space-y-2 text-xs">
              <div className="flex items-center gap-1.5 font-bold text-slate-800">
                <Calendar className="w-3.5 h-3.5 text-blue-600" />
                <span>Borrowing Details</span>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between p-2 bg-slate-50 border border-slate-200 rounded-lg text-slate-700">
                  <span className="text-slate-500">Borrow Date:</span>
                  <span className="font-mono text-xs flex items-center gap-1.5">
                    <Calendar className="w-3.5 h-3.5 text-slate-400" />
                    2025-06-08
                  </span>
                </div>
                <div className="flex items-center justify-between p-2 bg-slate-50 border border-slate-200 rounded-lg text-slate-700">
                  <span className="text-slate-500">Due Date:</span>
                  <span className="font-mono text-xs flex items-center gap-1.5">
                    <Calendar className="w-3.5 h-3.5 text-slate-400" />
                    2025-06-22 (14 days)
                  </span>
                </div>
              </div>
            </div>

            {/* Confirm Borrowing Button */}
            <button
              onClick={handleConfirmBorrow}
              className="w-full py-2.5 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-semibold text-xs rounded-lg shadow-sm flex items-center justify-center gap-2 transition-colors"
            >
              <BookOpen className="w-4 h-4" />
              <span>Confirm Borrowing</span>
            </button>
          </div>

          {/* Card 2: Return Book */}
          <div className="bg-white p-6 rounded-xl border border-slate-200/80 shadow-sm space-y-5">
            <div className="flex items-center gap-3 border-b border-slate-100 pb-3">
              <div className="w-10 h-10 rounded-full bg-teal-100 flex items-center justify-center text-teal-600 shrink-0">
                <ArrowLeftRight className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-base font-bold text-slate-900">Return Book</h2>
                <p className="text-xs text-slate-500">Process a book return and check for fines</p>
              </div>
            </div>

            {/* Student ID search */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Student ID <span className="text-rose-500">*</span>
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs">👤</span>
                  <input
                    type="text"
                    value={returnStudentId}
                    onChange={(e) => setReturnStudentId(e.target.value)}
                    placeholder="Enter student ID (e.g. S-00123)"
                    className="w-full pl-8 pr-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-lg text-slate-800 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <button className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white text-xs font-semibold rounded-lg flex items-center gap-1.5 transition-colors shrink-0">
                  <Search className="w-3.5 h-3.5" />
                  <span>Search</span>
                </button>
              </div>
            </div>

            {/* Book Title or ISBN search */}
            <div>
              <label className="block text-xs font-semibold text-slate-700 mb-1">
                Book Title or ISBN <span className="text-rose-500">*</span>
              </label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <Search className="w-3.5 h-3.5 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
                  <input
                    type="text"
                    value={returnBookQuery}
                    onChange={(e) => setReturnBookQuery(e.target.value)}
                    placeholder="Enter book title or ISBN (e.g. 978-0132357059)"
                    className="w-full pl-8 pr-3 py-2 text-xs bg-slate-50 border border-slate-200 rounded-lg text-slate-800 focus:outline-none focus:ring-1 focus:ring-blue-500"
                  />
                </div>
                <button className="px-4 py-2 bg-[#1877F2] hover:bg-blue-600 text-white text-xs font-semibold rounded-lg flex items-center gap-1.5 transition-colors shrink-0">
                  <Search className="w-3.5 h-3.5" />
                  <span>Search</span>
                </button>
              </div>
            </div>

            {/* Borrowing Record Card */}
            <div className="p-3.5 bg-blue-50/50 border border-blue-100 rounded-xl space-y-2 text-xs">
              <div className="flex items-center gap-1.5 font-bold text-blue-900 text-xs">
                <BookCheck className="w-3.5 h-3.5 text-blue-600" />
                <span>Borrowing Record</span>
              </div>
              <div className="space-y-1 text-slate-600 pt-1">
                <div className="flex justify-between">
                  <span className="text-slate-500">Student Name:</span>
                  <span className="font-semibold text-slate-800">Abebe Kebede</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-slate-500">Book Title:</span>
                  <span className="font-semibold text-slate-800">The Great Gatsby</span>
                </div>
                <div className="flex justify-between font-mono text-[11px]">
                  <span className="text-slate-500 font-sans">ISBN:</span>
                  <span className="text-slate-600">978-0132357059</span>
                </div>
                <div className="flex justify-between font-mono text-[11px]">
                  <span className="text-slate-500 font-sans">Borrow Date:</span>
                  <span className="text-slate-700">2025-06-08</span>
                </div>
                <div className="flex justify-between font-mono text-[11px]">
                  <span className="text-slate-500 font-sans">Due Date:</span>
                  <span className="text-slate-700">2025-06-22</span>
                </div>
              </div>
            </div>

            {/* Overdue Fine Alert Box */}
            <div className="p-3.5 bg-rose-50/70 border border-rose-200 rounded-xl flex items-start justify-between gap-3 text-xs">
              <div className="space-y-1">
                <div className="flex items-center gap-1.5 text-rose-700 font-bold">
                  <AlertTriangle className="w-4 h-4 text-rose-600" />
                  <span>Overdue Fine</span>
                </div>
                <div className="text-2xl font-black text-rose-600 tabular-nums">
                  $2.00
                </div>
                <div className="text-[11px] text-rose-700/80 font-medium">
                  The book is 5 days overdue.
                </div>
              </div>

              <div className="text-right text-[11px] space-y-1 text-slate-600">
                <div className="font-bold text-slate-800">Fine Details</div>
                <div>Daily fine rate: <span className="font-semibold tabular-nums">$0.40</span></div>
                <div>Overdue days: <span className="font-semibold tabular-nums">5</span></div>
                <div className="font-bold text-rose-700">Total fine: $2.00</div>
              </div>
            </div>

            {/* Book Condition Radios */}
            <div className="space-y-2 text-xs">
              <label className="block font-bold text-slate-800">Book Condition</label>
              <div className="flex items-center gap-4">
                {(['Good', 'Minor damage', 'Lost'] as const).map((cond) => (
                  <label key={cond} className="flex items-center gap-1.5 cursor-pointer text-slate-700 font-medium">
                    <input
                      type="radio"
                      name="condition"
                      value={cond}
                      checked={bookCondition === cond}
                      onChange={() => setBookCondition(cond)}
                      className="text-blue-600 focus:ring-blue-500"
                    />
                    <span>{cond}</span>
                  </label>
                ))}
              </div>
            </div>

            {/* Confirm Return Button */}
            <button
              onClick={handleConfirmReturn}
              className="w-full py-2.5 bg-emerald-600 hover:bg-emerald-700 active:bg-emerald-800 text-white font-semibold text-xs rounded-lg shadow-sm flex items-center justify-center gap-2 transition-colors"
            >
              <ArrowLeftRight className="w-4 h-4" />
              <span>Confirm Return</span>
            </button>
          </div>
        </div>

        {/* Right 4 cols: Summary & Upcoming & Recent */}
        <div className="lg:col-span-4 space-y-6">
          {/* My Reading Summary */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2">
                <BookOpen className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">My Reading Summary</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 bg-blue-50/40 rounded-xl border border-blue-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-bold">
                  <BookOpen className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-lg font-bold text-slate-900 tabular-nums">3</div>
                  <div className="text-[11px] text-slate-500">Books Borrowed</div>
                </div>
              </div>

              <div className="p-3 bg-sky-50/40 rounded-xl border border-sky-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-sky-100 text-sky-600 flex items-center justify-center font-bold">
                  <Clock className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-lg font-bold text-slate-900 tabular-nums">1</div>
                  <div className="text-[11px] text-slate-500">Due Soon</div>
                </div>
              </div>

              <div className="p-3 bg-emerald-50/40 rounded-xl border border-emerald-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center font-bold">
                  <Calendar className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-lg font-bold text-slate-900 tabular-nums">1</div>
                  <div className="text-[11px] text-slate-500">Reservation(s)</div>
                </div>
              </div>

              <div className="p-3 bg-rose-50/40 rounded-xl border border-rose-100 flex items-center gap-3">
                <div className="w-8 h-8 rounded-full bg-rose-100 text-rose-600 flex items-center justify-center font-bold">
                  <Bell className="w-4 h-4" />
                </div>
                <div>
                  <div className="text-lg font-bold text-slate-900 tabular-nums">2</div>
                  <div className="text-[11px] text-slate-500">Notifications</div>
                </div>
              </div>
            </div>
          </div>

          {/* Upcoming Due Dates */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Upcoming Due Dates</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3.5">
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
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2">
                <Bell className="w-4 h-4 text-blue-600" />
                <h3 className="font-bold text-slate-900 text-sm">Recent Notifications</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
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
                    New reservation for "The Martian" is now available.
                  </div>
                  <div className="text-[10px] text-slate-400 mt-0.5">1 day ago</div>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="w-7 h-7 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center shrink-0 mt-0.5">
                  <Check className="w-3.5 h-3.5" />
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-slate-800">
                    Book returned: "Clean Code" by Selam Tesfaye.
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
