package com.bank.numsante.service;

import com.bank.numsante.dto.PersonnelProfilDto;
import com.bank.numsante.entity.PersonnelMedical;
import com.bank.numsante.repository.PersonnelMedicalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PersonnelService {

    private final PersonnelMedicalRepository personnelRepo;
    private final LogService logService;

    public PersonnelProfilDto getProfil(Long idPersonnel) {
        PersonnelMedical personnel = personnelRepo.findById(idPersonnel)
                .orElseThrow(() -> new RuntimeException("Personnel non trouvé : " + idPersonnel));

        logService.logAction(idPersonnel, null, "LECTURE_PROFIL_PERSONNEL", null);

        Long   idHopital      = personnel.getHopital() != null ? personnel.getHopital().getIdHopital() : null;
        String nomHopital     = personnel.getHopital() != null ? personnel.getHopital().getNom()       : null;
        String adresseHopital = personnel.getHopital() != null ? personnel.getHopital().getAdresse()   : null;

        return new PersonnelProfilDto(
                personnel.getIdPersonnel(),
                personnel.getNom(),
                personnel.getPrenom(),
                personnel.getRole(),
                personnel.getIdentifiantPro(),
                idHopital,
                nomHopital,
                adresseHopital
        );
    }
}
