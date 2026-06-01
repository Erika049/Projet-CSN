package com.bank.numsante.security;

import com.bank.numsante.entity.Patient;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.repository.PatientRepository;
import com.bank.numsante.repository.PersonnelMedicalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final PersonnelMedicalRepository personnelRepo;
    private final PatientRepository patientRepo;

    @Override
    public UserDetails loadUserByUsername(String username)
            throws UsernameNotFoundException {

        // Essayer d'abord comme personnel
        try {
            PersonnelMedical personnel = personnelRepo
                    .findByIdentifiantPro(username).orElse(null);
            if (personnel != null) {
                return new CustomUserDetails(personnel);
            }
        } catch (Exception ignored) {}

        // Essayer comme patient (username = UUID)
        try {
            UUID patientId = UUID.fromString(username);
            Patient patient = patientRepo.findById(patientId).orElse(null);
            if (patient != null) {
                return User.builder()
                        .username(patient.getIdPatient().toString())
                        .password(patient.getMotDePasseHash() != null
                                ? patient.getMotDePasseHash() : "")
                        .authorities(List.of(
                                new SimpleGrantedAuthority("ROLE_PATIENT")))
                        .accountLocked(false)
                        .disabled(false)
                        .build();
            }
        } catch (IllegalArgumentException ignored) {}

        throw new UsernameNotFoundException(
                "Utilisateur non trouvé : " + username);
    }
}