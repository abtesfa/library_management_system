
package com.library.library_backend.repository;

import com.library.library_backend.entity.Staff;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StaffRepository extends JpaRepository<Staff, Integer> {

    Optional<Staff> findByEmail(String email);

    boolean existsByEmail(String email);
}
