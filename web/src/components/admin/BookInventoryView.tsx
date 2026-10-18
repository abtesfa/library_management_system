import React, { useState, useMemo } from 'react';
import {
  BookOpen,
  Plus,
  Search,
  CheckCircle2,
  FileText,
  Clock,
  Layers,
  Edit2,
  Trash2,
  Upload,
  Tag,
  MapPin,
  ChevronLeft,
  ChevronRight,
  ArrowRight
} from 'lucide-react';
import { Book } from '../../types';
import { BookCover } from '../common/BookCover';
import { CategoryBadge, StatusBadge } from '../common/Badges';

interface BookInventoryViewProps {
  books: Book[];
  onAddBook: () => void;
  onEditBook: (book: Book) => void;
  onDeleteBook: (bookId: string) => void;
  onImportBooks: () => void;
}

export const BookInventoryView: React.FC<BookInventoryViewProps> = ({
  books,
  onAddBook,
  onEditBook,
  onDeleteBook,
  onImportBooks
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All Categories');
  const [statusFilter, setStatusFilter] = useState('All Statuses');
  const [selectedBooks, setSelectedBooks] = useState<string[]>([]);
  const [currentPage, setCurrentPage] = useState(1);

  // Filtered books
  const filteredBooks = useMemo(() => {
    return books.filter((b) => {
      const matchSearch =
        searchTerm === '' ||
        b.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.author.toLowerCase().includes(searchTerm.toLowerCase()) ||
        b.isbn.includes(searchTerm) ||
        b.location.toLowerCase().includes(searchTerm.toLowerCase());

      const matchCategory =
        categoryFilter === 'All Categories' || b.category === categoryFilter;

      const matchStatus =
        statusFilter === 'All Statuses' || b.status === statusFilter;

      return matchSearch && matchCategory && matchStatus;
    });
  }, [books, searchTerm, categoryFilter, statusFilter]);

  const toggleSelectAll = () => {
    if (selectedBooks.length === filteredBooks.length) {
      setSelectedBooks([]);
    } else {
      setSelectedBooks(filteredBooks.map((b) => b.id));
    }
  };

  const toggleSelectBook = (id: string) => {
    if (selectedBooks.includes(id)) {
      setSelectedBooks(selectedBooks.filter((item) => item !== id));
    } else {
      setSelectedBooks([...selectedBooks, id]);
    }
  };

  const categories = [
    'All Categories',
    'Self-Help',
    'Science Fiction',
    'Fiction',
    'Computer Science',
    'History',
    'Fantasy',
    'Dystopian',
    'Classic'
  ];

  const statuses = ['All Statuses', 'Available', 'Low Stock', 'Unavailable'];

  return (
    <div className="p-8 space-y-6 max-w-[1600px] mx-auto">
      {/* Top Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div className="flex items-start gap-4">
          <div className="w-12 h-12 rounded-xl bg-blue-100 flex items-center justify-center text-[#0052CC] shrink-0 shadow-sm">
            <BookOpen className="w-7 h-7" />
          </div>
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Book Inventory</h1>
            <p className="text-sm text-slate-500 mt-0.5">
              Manage book titles, authors, categories, physical copies, shelf locations, and availability status.
            </p>
          </div>
        </div>

        <button
          onClick={onAddBook}
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-[#1877F2] hover:bg-blue-600 active:bg-blue-700 text-white font-medium text-sm rounded-lg shadow-sm transition-colors whitespace-nowrap shrink-0"
        >
          <Plus className="w-4 h-4 stroke-[2.5]" />
          <span>Add New Book</span>
        </button>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex flex-col md:flex-row items-center gap-3">
        <div className="relative flex-1 w-full">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Search by title, author, ISBN, or accession number..."
            className="w-full pl-10 pr-4 py-2 text-sm bg-slate-50 border border-slate-200 rounded-lg text-slate-800 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          />
        </div>

        <div className="w-full md:w-52">
          <select
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
            className="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-200 rounded-lg text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          >
            {categories.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>
        </div>

        <div className="w-full md:w-44">
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="w-full px-3 py-2 text-sm bg-slate-50 border border-slate-200 rounded-lg text-slate-700 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500"
          >
            {statuses.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>

        <button
          onClick={() => {}}
          className="w-full md:w-auto px-6 py-2 bg-[#1877F2] hover:bg-blue-600 text-white text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-colors shrink-0"
        >
          <Search className="w-4 h-4" />
          <span>Search</span>
        </button>
      </div>

      {/* 5 KPI Stat Cards */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        {/* Total Books */}
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
            <BookOpen className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Total Books</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">1,248</div>
            <div className="text-[11px] text-slate-400">titles in collection</div>
          </div>
        </div>

        {/* Total Copies */}
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 shrink-0">
            <Layers className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Total Copies</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">2,860</div>
            <div className="text-[11px] text-slate-400">physical copies</div>
          </div>
        </div>

        {/* Available Copies */}
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-emerald-100 flex items-center justify-center text-emerald-600 shrink-0">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Available Copies</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">2,341</div>
            <div className="text-[11px] text-slate-400">available for loan</div>
          </div>
        </div>

        {/* On Loan */}
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-amber-600 shrink-0">
            <FileText className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">On Loan</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">487</div>
            <div className="text-[11px] text-slate-400">currently borrowed</div>
          </div>
        </div>

        {/* Reserved */}
        <div className="bg-white p-4 rounded-xl border border-slate-200/80 shadow-sm flex items-center gap-4 col-span-2 md:col-span-1">
          <div className="w-12 h-12 rounded-full bg-rose-100 flex items-center justify-center text-rose-600 shrink-0">
            <Clock className="w-6 h-6" />
          </div>
          <div>
            <div className="text-xs text-slate-500 font-medium">Reserved</div>
            <div className="text-2xl font-bold text-slate-900 tracking-tight tabular-nums">32</div>
            <div className="text-[11px] text-slate-400">awaiting availability</div>
          </div>
        </div>
      </div>

      {/* Main Grid: Book List Table (Left) + Side Panels (Right) */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* Left Column (8 cols): Book Inventory List */}
        <div className="lg:col-span-8 bg-white rounded-xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div className="p-4 px-6 border-b border-slate-100 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <BookOpen className="w-5 h-5 text-blue-600" />
              <h2 className="text-base font-bold text-slate-900">Book Inventory List</h2>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-xs text-slate-500">
                Showing 1-10 of 1,248
              </span>
              <div className="flex items-center gap-1">
                <button
                  disabled={currentPage <= 1}
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  className="w-7 h-7 flex items-center justify-center rounded border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40"
                >
                  <ChevronLeft className="w-4 h-4" />
                </button>
                {[1, 2, 3, 4, 5].map((page) => (
                  <button
                    key={page}
                    onClick={() => setCurrentPage(page)}
                    className={`w-7 h-7 flex items-center justify-center rounded text-xs font-semibold ${
                      currentPage === page
                        ? 'bg-[#1877F2] text-white'
                        : 'border border-slate-200 text-slate-700 hover:bg-slate-50'
                    }`}
                  >
                    {page}
                  </button>
                ))}
                <button
                  onClick={() => setCurrentPage((p) => Math.min(5, p + 1))}
                  className="w-7 h-7 flex items-center justify-center rounded border border-slate-200 text-slate-600 hover:bg-slate-50"
                >
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50/70 border-b border-slate-200 text-[11px] font-semibold text-slate-500 uppercase tracking-wider">
                  <th className="py-3 px-4 w-10">
                    <input
                      type="checkbox"
                      checked={
                        filteredBooks.length > 0 &&
                        selectedBooks.length === filteredBooks.length
                      }
                      onChange={toggleSelectAll}
                      className="rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                    />
                  </th>
                  <th className="py-3 px-3">Cover</th>
                  <th className="py-3 px-3">Title</th>
                  <th className="py-3 px-3">Author</th>
                  <th className="py-3 px-3 font-mono">ISBN</th>
                  <th className="py-3 px-3">Category</th>
                  <th className="py-3 px-3 text-center">Total Copies</th>
                  <th className="py-3 px-3 text-center">Available</th>
                  <th className="py-3 px-3 text-center">Status</th>
                  <th className="py-3 px-3">Location</th>
                  <th className="py-3 px-4 text-center">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs text-slate-700">
                {filteredBooks.slice(0, 10).map((book) => {
                  const isChecked = selectedBooks.includes(book.id);
                  return (
                    <tr
                      key={book.id}
                      className={`hover:bg-blue-50/40 transition-colors ${
                        isChecked ? 'bg-blue-50/60' : ''
                      }`}
                    >
                      <td className="py-3 px-4">
                        <input
                          type="checkbox"
                          checked={isChecked}
                          onChange={() => toggleSelectBook(book.id)}
                          className="rounded border-slate-300 text-blue-600 focus:ring-blue-500"
                        />
                      </td>
                      <td className="py-2.5 px-3">
                        <BookCover
                          title={book.title}
                          author={book.author}
                          coverImage={book.coverImage}
                          coverTheme={book.coverTheme}
                          size="sm"
                        />
                      </td>
                      <td className="py-3 px-3">
                        <button
                          onClick={() => onEditBook(book)}
                          className="font-semibold text-[#1877F2] hover:underline text-left"
                        >
                          {book.title}
                        </button>
                      </td>
                      <td className="py-3 px-3 text-slate-600">{book.author}</td>
                      <td className="py-3 px-3 font-mono text-slate-500 text-[11px] whitespace-nowrap">
                        {book.isbn}
                      </td>
                      <td className="py-3 px-3 whitespace-nowrap">
                        <CategoryBadge category={book.category} />
                      </td>
                      <td className="py-3 px-3 text-center font-semibold tabular-nums text-slate-800">
                        {book.totalCopies}
                      </td>
                      <td className="py-3 px-3 text-center font-semibold tabular-nums text-slate-800">
                        {book.availableCopies}
                      </td>
                      <td className="py-3 px-3 text-center whitespace-nowrap">
                        <StatusBadge status={book.status} />
                      </td>
                      <td className="py-3 px-3 font-medium text-slate-600 whitespace-nowrap">
                        {book.location}
                      </td>
                      <td className="py-3 px-4 text-center whitespace-nowrap">
                        <div className="flex items-center justify-center gap-2">
                          <button
                            onClick={() => onEditBook(book)}
                            title="Edit book"
                            className="p-1 rounded text-blue-600 hover:bg-blue-100 transition-colors"
                          >
                            <Edit2 className="w-3.5 h-3.5" />
                          </button>
                          <button
                            onClick={() => onDeleteBook(book.id)}
                            title="Delete book"
                            className="p-1 rounded text-rose-500 hover:bg-rose-100 transition-colors"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>

        {/* Right Column (4 cols): Overview + Quick Actions + Activity */}
        <div className="lg:col-span-4 space-y-6">
          {/* Inventory Overview (Donut chart card) */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center gap-2 mb-4">
              <Layers className="w-5 h-5 text-slate-700" />
              <h3 className="font-bold text-slate-900 text-sm">Inventory Overview</h3>
            </div>

            <div className="flex items-center justify-between gap-4">
              {/* SVG Donut Chart */}
              <div className="relative w-36 h-36 shrink-0 flex items-center justify-center">
                <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
                  {/* Background track */}
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="transparent"
                    stroke="#E2E8F0"
                    strokeWidth="11"
                  />
                  {/* Available arc (81.8%) */}
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="transparent"
                    stroke="#10B981"
                    strokeWidth="11"
                    strokeDasharray="238.76"
                    strokeDashoffset="43.45"
                  />
                  {/* On Loan arc (17.0%) */}
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="transparent"
                    stroke="#F59E0B"
                    strokeWidth="11"
                    strokeDasharray="238.76"
                    strokeDashoffset="198.17"
                    transform="rotate(294 50 50)"
                  />
                  {/* Reserved arc (1.1%) */}
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="transparent"
                    stroke="#EF4444"
                    strokeWidth="11"
                    strokeDasharray="238.76"
                    strokeDashoffset="236.13"
                    transform="rotate(356 50 50)"
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center text-center">
                  <span className="text-xl font-extrabold text-slate-900 leading-none tabular-nums">
                    2,860
                  </span>
                  <span className="text-[10px] text-slate-500 font-medium mt-0.5">
                    Total Copies
                  </span>
                </div>
              </div>

              {/* Legend */}
              <div className="space-y-3 flex-1 text-xs">
                <div className="flex items-start gap-2">
                  <div className="w-2.5 h-2.5 rounded-full bg-emerald-500 mt-1 shrink-0"></div>
                  <div>
                    <div className="font-semibold text-slate-800">Available</div>
                    <div className="text-[11px] text-slate-500 tabular-nums">2,341 (81.8%)</div>
                  </div>
                </div>

                <div className="flex items-start gap-2">
                  <div className="w-2.5 h-2.5 rounded-full bg-amber-500 mt-1 shrink-0"></div>
                  <div>
                    <div className="font-semibold text-slate-800">On Loan</div>
                    <div className="text-[11px] text-slate-500 tabular-nums">487 (17.0%)</div>
                  </div>
                </div>

                <div className="flex items-start gap-2">
                  <div className="w-2.5 h-2.5 rounded-full bg-rose-500 mt-1 shrink-0"></div>
                  <div>
                    <div className="font-semibold text-slate-800">Reserved</div>
                    <div className="text-[11px] text-slate-500 tabular-nums">32 (1.1%)</div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center gap-2 mb-3">
              <span className="text-blue-600 font-bold">⚡</span>
              <h3 className="font-bold text-slate-900 text-sm">Quick Actions</h3>
            </div>

            <div className="grid grid-cols-2 gap-2.5">
              <button
                onClick={onAddBook}
                className="p-3 bg-blue-50/60 hover:bg-blue-100/70 border border-blue-100 rounded-xl text-center transition-colors group flex flex-col items-center justify-center gap-1"
              >
                <div className="w-7 h-7 rounded-full bg-blue-600 text-white flex items-center justify-center group-hover:scale-105 transition-transform">
                  <Plus className="w-4 h-4 stroke-[2.5]" />
                </div>
                <div className="text-xs font-bold text-slate-800 mt-0.5">Add New Book</div>
                <div className="text-[10px] text-slate-500">Add a new book title</div>
              </button>

              <button
                onClick={onImportBooks}
                className="p-3 bg-blue-50/60 hover:bg-blue-100/70 border border-blue-100 rounded-xl text-center transition-colors group flex flex-col items-center justify-center gap-1"
              >
                <div className="w-7 h-7 rounded-full bg-blue-600 text-white flex items-center justify-center group-hover:scale-105 transition-transform">
                  <Upload className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-slate-800 mt-0.5">Import Books</div>
                <div className="text-[10px] text-slate-500">Bulk import from file</div>
              </button>

              <button
                onClick={() => {}}
                className="p-3 bg-blue-50/60 hover:bg-blue-100/70 border border-blue-100 rounded-xl text-center transition-colors group flex flex-col items-center justify-center gap-1"
              >
                <div className="w-7 h-7 rounded-full bg-blue-600 text-white flex items-center justify-center group-hover:scale-105 transition-transform">
                  <Tag className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-slate-800 mt-0.5">Manage Categories</div>
                <div className="text-[10px] text-slate-500">View and edit categories</div>
              </button>

              <button
                onClick={() => {}}
                className="p-3 bg-blue-50/60 hover:bg-blue-100/70 border border-blue-100 rounded-xl text-center transition-colors group flex flex-col items-center justify-center gap-1"
              >
                <div className="w-7 h-7 rounded-full bg-blue-600 text-white flex items-center justify-center group-hover:scale-105 transition-transform">
                  <MapPin className="w-4 h-4" />
                </div>
                <div className="text-xs font-bold text-slate-800 mt-0.5">Manage Locations</div>
                <div className="text-[10px] text-slate-500">Edit shelf locations</div>
              </button>
            </div>
          </div>

          {/* Recent Book Activity */}
          <div className="bg-white p-5 rounded-xl border border-slate-200/80 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <Clock className="w-4 h-4 text-slate-600" />
                <h3 className="font-bold text-slate-900 text-sm">Recent Book Activity</h3>
              </div>
              <button className="text-xs font-semibold text-[#1877F2] hover:underline flex items-center gap-1">
                View All <ArrowRight className="w-3 h-3" />
              </button>
            </div>

            <div className="space-y-3.5">
              {/* Activity item 1 */}
              <div className="flex items-start gap-3">
                <BookCover
                  title="Clean Code"
                  coverImage="/web/src/assets/images/book_cover_cleancode_1791886211255.jpg"
                  size="xs"
                />
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold text-slate-800">New book added</div>
                  <div className="text-xs font-semibold text-[#1877F2] truncate">Clean Code</div>
                  <div className="text-[10px] text-slate-400 mt-0.5">by Robert C. Martin · 2 hours ago</div>
                </div>
              </div>

              {/* Activity item 2 */}
              <div className="flex items-start gap-3">
                <BookCover title="Atomic Habits" coverTheme="atomic-habits" size="xs" />
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold text-slate-800">Book updated</div>
                  <div className="text-xs font-semibold text-[#1877F2] truncate">Atomic Habits</div>
                  <div className="text-[10px] text-slate-400 mt-0.5">by James Clear · 4 hours ago</div>
                </div>
              </div>

              {/* Activity item 3 */}
              <div className="flex items-start gap-3">
                <BookCover
                  title="Dune"
                  coverImage="/web/src/assets/images/book_cover_dune_1791886211742.jpg"
                  size="xs"
                />
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold text-slate-800">Copy checked in</div>
                  <div className="text-xs font-semibold text-[#1877F2] truncate">Dune (Copy #3)</div>
                  <div className="text-[10px] text-slate-400 mt-0.5">by Frank Herbert · 1 day ago</div>
                </div>
              </div>

              {/* Activity item 4 */}
              <div className="flex items-start gap-3">
                <BookCover title="The Martian" coverTheme="the-martian" size="xs" />
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold text-slate-800">Book marked as reserved</div>
                  <div className="text-xs font-semibold text-[#1877F2] truncate">The Martian</div>
                  <div className="text-[10px] text-slate-400 mt-0.5">by Andy Weir · 1 day ago</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
