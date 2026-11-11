
package com.library.library_backend.Controller;

import com.library.library_backend.Service.ReservationService;
import com.library.library_backend.dto.ReservationResponse;
import com.library.library_backend.entity.Reservation;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(origins = "*")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    // Request body for creating a reservation.
    public record CreateReservationRequest(Integer bookId) {}

    // --------------------------------------------------
    // CREATE RESERVATION
    // POST /api/students/{userId}/reservations
    // --------------------------------------------------

    @PostMapping("/{userId}/reservations")
    public ResponseEntity<Reservation> createReservation(
            @PathVariable Integer userId,
            @RequestBody CreateReservationRequest request) {

        if (request == null || request.bookId() == null) {
            return ResponseEntity.badRequest().build();
        }

        Reservation reservation = reservationService.createReservation(
                userId,
                request.bookId()
        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(reservation);
    }

    // --------------------------------------------------
    // GET STUDENT RESERVATIONS
    // GET /api/students/{userId}/reservations
    // --------------------------------------------------

    @GetMapping("/{userId}/reservations")
    public ResponseEntity<List<ReservationResponse>> getStudentReservations(
            @PathVariable Integer userId) {

        List<ReservationResponse> reservations =
                reservationService.getStudentReservations(userId);

        return ResponseEntity.ok(reservations);
    }

    // --------------------------------------------------
    // CANCEL RESERVATION
    // PATCH /api/students/{userId}/reservations/{reservationId}/cancel
    // --------------------------------------------------

    @PatchMapping("/{userId}/reservations/{reservationId}/cancel")
    public ResponseEntity<Void> cancelReservation(
            @PathVariable Integer userId,
            @PathVariable Integer reservationId) {

        reservationService.cancelReservation(userId, reservationId);

        return ResponseEntity.noContent().build();
    }
}
