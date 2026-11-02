package com.library.library_backend.dto;

public class InventorySummaryDTO {
    private long totalBooks;
    private long totalCopies;
    private long availableCopies;
    private long onLoanCopies;
    private long reservedCopies;

    public InventorySummaryDTO(long totalBooks, long totalCopies, long availableCopies, long onLoanCopies, long reservedCopies) {
        this.totalBooks = totalBooks;
        this.totalCopies = totalCopies;
        this.availableCopies = availableCopies;
        this.onLoanCopies = onLoanCopies;
        this.reservedCopies = reservedCopies;
    }

    public long getTotalBooks() { return totalBooks; }
    public void setTotalBooks(long totalBooks) { this.totalBooks = totalBooks; }

    public long getTotalCopies() { return totalCopies; }
    public void setTotalCopies(long totalCopies) { this.totalCopies = totalCopies; }

    public long getAvailableCopies() { return availableCopies; }
    public void setAvailableCopies(long availableCopies) { this.availableCopies = availableCopies; }

    public long getOnLoanCopies() { return onLoanCopies; }
    public void setOnLoanCopies(long onLoanCopies) { this.onLoanCopies = onLoanCopies; }

    public long getReservedCopies() { return reservedCopies; }
    public void setReservedCopies(long reservedCopies) { this.reservedCopies = reservedCopies; }
}