package com.library.library_backend.Service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;
import java.util.Set;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.library.library_backend.dto.StaffRequest;
import com.library.library_backend.dto.StaffResponse;
import com.library.library_backend.entity.Permission;
import com.library.library_backend.entity.Staff;
import com.library.library_backend.repository.PermissionRepository;
import com.library.library_backend.repository.StaffRepository;
import com.library.library_backend.security.PasswordHashService;

@ExtendWith(MockitoExtension.class)
class StaffServiceTest {

    @Mock
    private StaffRepository staffRepository;

    @Mock
    private PermissionRepository permissionRepository;

    private StaffService staffService;

    @BeforeEach
    void setUp() {
        staffService = new StaffService(
                staffRepository,
                permissionRepository,
                new PasswordHashService());
    }

    @Test
    void createsLibrarianWithSelectedPermissionsWhenPermissionRowsAreMissing() {
        when(staffRepository.existsByEmail("librarian@example.com"))
                .thenReturn(false);
        when(permissionRepository.findByPermissionCode(anyString()))
                .thenReturn(Optional.empty());
        when(permissionRepository.save(any(Permission.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        when(staffRepository.save(any(Staff.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        StaffRequest request = new StaffRequest();
        request.setFullName("Test Librarian");
        request.setEmail("librarian@example.com");
        request.setRole("LIBRARIAN");
        request.setPassword("password123");
        request.setPermissions(Set.of("ADD_BOOK", "MANAGE_STAFF"));

        StaffResponse response = staffService.createStaff(request);

        assertEquals(Set.of("ADD_BOOK", "MANAGE_STAFF"), response.getPermissions());
        assertNull(response.getPosition());
        verify(permissionRepository, times(2)).save(any(Permission.class));
    }
}
