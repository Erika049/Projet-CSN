package com.bank.numsante.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Data @NoArgsConstructor @AllArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long idNotification;

    @ManyToOne
    @JoinColumn(name = "id_patient", nullable = false)
    private Patient patient;

    @Column(nullable = false)
    private String titre;

    @Column(nullable = false)
    private String message;

    @Column(nullable = false)
    private String type; // examen | ordonnance | admission | acces | securite

    @Column(nullable = false)
    private boolean lue = false;

    @CreationTimestamp
    @Column(name = "cree_le")
    private LocalDateTime creeLe;
}