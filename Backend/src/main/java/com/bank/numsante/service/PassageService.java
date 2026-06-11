package com.bank.numsante.service;

import com.bank.numsante.dto.ConstantesVitalesRequest;
import com.bank.numsante.dto.ConsultationRequest;
import com.bank.numsante.dto.SoinInfirmierRequest;
import com.bank.numsante.dto.InjectionInfirmierRequest;
import com.bank.numsante.entity.PassageMedical;
import com.bank.numsante.repository.PassageMedicalRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PassageService {

    private final PassageMedicalRepository passageRepo;
    private final LogService logService;

    @Transactional
    public void updateConstantes(UUID idPassage, ConstantesVitalesRequest request, Long idPersonnel) {
        PassageMedical passage = passageRepo.findById(idPassage)
                .orElseThrow(() -> new RuntimeException("Passage introuvable"));
        Map<String, Object> constantes = new HashMap<>();
        if (request.getTension()        != null) constantes.put("tension",        request.getTension());
        if (request.getTemperature()    != null) constantes.put("temperature",    request.getTemperature());
        if (request.getPoids()          != null) constantes.put("poids",          request.getPoids());
        if (request.getFreqCardiaque()  != null) constantes.put("freqCardiaque",  request.getFreqCardiaque());
        if (request.getSpo2()           != null) constantes.put("spo2",           request.getSpo2());
        if (request.getFreqRespi()      != null) constantes.put("freqRespi",      request.getFreqRespi());
        if (request.getNoteInfirmiere() != null) constantes.put("noteInfirmiere", request.getNoteInfirmiere());
        passage.setConstantesVitales(constantes);
        passageRepo.save(passage);

        logService.logAction(idPersonnel,
                passage.getPatient().getIdPatient(),
                "MAJ_CONSTANTES", passage.getIdPassage());
    }

    public Map<String, String> getConstantes(UUID idPassage) {
        PassageMedical passage = passageRepo.findById(idPassage)
                .orElseThrow(() -> new RuntimeException("Passage introuvable"));
        Map<String, Object> raw = passage.getConstantesVitales();
        if (raw == null) return Map.of();
        Map<String, String> result = new LinkedHashMap<>();
        raw.forEach((k, v) -> result.put(k, v != null ? v.toString() : ""));
        return result;
    }

    @Transactional
    public void enregistrerSoin(UUID idPassage, SoinInfirmierRequest request, Long idPersonnel) {
        PassageMedical passage = passageRepo.findById(idPassage)
                .orElseThrow(() -> new RuntimeException("Passage introuvable"));
        String desc = (request.getTypeSoin() != null ? request.getTypeSoin() : "Soin")
                    + (request.getDescription() != null && !request.getDescription().isBlank()
                       ? " · " + request.getDescription() : "");
        logService.logAction(idPersonnel,
                passage.getPatient().getIdPatient(),
                "SOIN_REALISE", passage.getIdPassage(), desc);
    }

    @Transactional
    public void enregistrerInjection(UUID idPassage, InjectionInfirmierRequest request, Long idPersonnel) {
        PassageMedical passage = passageRepo.findById(idPassage)
                .orElseThrow(() -> new RuntimeException("Passage introuvable"));
        String desc = (request.getMedicament() != null ? request.getMedicament() : "Injection")
                    + (request.getDose() != null ? " · " + request.getDose() : "")
                    + (request.getVoie() != null ? " · " + request.getVoie() : "");
        logService.logAction(idPersonnel,
                passage.getPatient().getIdPatient(),
                "INJECTION_IV", passage.getIdPassage(), desc);
    }

    @Transactional
    public void ajouterConsultation(UUID idPassage, ConsultationRequest request, Long idPersonnel) {
        PassageMedical passage = passageRepo.findById(idPassage)
                .orElseThrow(() -> new RuntimeException("Passage introuvable"));
        if (request.getDiagnostic() != null) passage.setDiagnostic(request.getDiagnostic());
        if (request.getPrescriptionOrdonnance() != null)
            passage.setPrescriptionOrdonnance(request.getPrescriptionOrdonnance());
        if (request.isCloturerPassage()) passage.setStatutPassage("termine");
        passageRepo.save(passage);

        logService.logAction(idPersonnel,
                passage.getPatient().getIdPatient(),
                "CONSULTATION", passage.getIdPassage());
    }
}