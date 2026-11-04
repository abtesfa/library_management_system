
package com.library.library_backend.Controller;

import com.library.library_backend.Service.ReservationService;
import com.library.library_backend.entity.Reservation;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
public class ReservationCreateController {

    private final ReservationService reservationService;

    public ReservationCreateController(
            ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    // Request now uses numeric Book_ID.
    public record CreateReservationRequest(
            Integer userId,
            Integer bookId
    ) {}

    // POST /api/reservations
    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody CreateReservationRequest request) {

        if (request == null
                || request.userId() == null
                || request.bookId() == null) {

            return ResponseEntity.badRequest().body(
                    Map.of("message", "Student ID and Book ID are required")
            );
        }

        Reservation reservation = reservationService.createReservation(
                request.userId(),
                request.bookId()
        );

        return ResponseEntity.status(HttpStatus.CREATED).body(
                Map.of(
                        "message", "Reservation created successfully",
                        "reservationId", reservation.getReservationId(),
                        "userId", reservation.getUserId(),
                        "bookId", reservation.getBookId(),
                        "status", reservation.getStatus(),
                        "queuePosition", reservation.getQueuePosition()
                )
        );
    }
}
