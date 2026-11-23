package com.library.library_backend.Controller;

import com.library.library_backend.entity.Staff;
import com.library.library_backend.entity.Student;
import com.library.library_backend.repository.StaffRepository;
import com.library.library_backend.repository.StudentRepository;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/profile-pictures")
@CrossOrigin(origins = "*")
public class ProfilePictureController {
    private final StaffRepository staffRepository;
    private final StudentRepository studentRepository;
    public ProfilePictureController(StaffRepository staffRepository, StudentRepository studentRepository) {
        this.staffRepository = staffRepository; this.studentRepository = studentRepository;
    }
    @PutMapping(value="/{role}/{id}", consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Void> upload(@PathVariable String role, @PathVariable Integer id,
                                       @RequestPart("file") MultipartFile file) throws Exception {
        if (!"STUDENT".equalsIgnoreCase(role) && !"READER".equalsIgnoreCase(role)
                && !"ADMIN".equalsIgnoreCase(role) && !"LIBRARIAN".equalsIgnoreCase(role)) {
            throw new IllegalArgumentException("Role must be STUDENT, ADMIN, or LIBRARIAN.");
        }
        if (file.isEmpty() || file.getSize() > 5 * 1024 * 1024) throw new IllegalArgumentException("Choose an image smaller than 5 MB.");
        String type = file.getContentType() == null ? "" : file.getContentType();
        if (!type.equals("image/jpeg") && !type.equals("image/png") && !type.equals("image/webp")) throw new IllegalArgumentException("Only JPG, PNG, or WEBP images are allowed.");
        if ("STUDENT".equalsIgnoreCase(role) || "READER".equalsIgnoreCase(role)) {
            Student s = studentRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Student not found."));
            s.setProfilePicture(file.getBytes()); studentRepository.save(s);
        } else {
            Staff s = staffRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Staff member not found."));
            s.setProfilePicture(file.getBytes()); staffRepository.save(s);
        }
        return ResponseEntity.noContent().build();
    }
    @GetMapping(value="/{role}/{id}", produces=MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<byte[]> get(@PathVariable String role, @PathVariable Integer id) {
        byte[] bytes;
        if ("STUDENT".equalsIgnoreCase(role) || "READER".equalsIgnoreCase(role)) bytes = studentRepository.findById(id).map(Student::getProfilePicture).orElse(null);
        else bytes = staffRepository.findById(id).map(Staff::getProfilePicture).orElse(null);
        return bytes == null ? ResponseEntity.notFound().build() : ResponseEntity.ok().contentType(MediaType.APPLICATION_OCTET_STREAM).body(bytes);
    }
}
