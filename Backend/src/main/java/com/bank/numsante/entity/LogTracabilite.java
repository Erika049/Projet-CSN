package com.bank.numsante.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "logs_tracabilite")
@Data @NoArgsConstructor @AllArgsConstructor
public class LogTracabilite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_log")
    private Long idLog;

    @Column(name = "id_personnel")
    private Long idUtilisateur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_personnel",
            insertable = false,
            updatable = false)
    private PersonnelMedical personnel;

    @Column(name = "id_patient")
    private UUID idPatient;

    @Column(name = "action_effectuee",
            nullable = false)
    private String actionEffectuee;

    @Column(name = "id_dossier_concerne")
    private UUID idDossierConcerne;

    @Column(name = "adresse_ip")
    private String adresseIp;

    @CreationTimestamp
    @Column(name = "horodatage")
    private LocalDateTime horodatage;
}