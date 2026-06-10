package com.bank.numsante.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
public class NotificationDto {
    private Long idNotification;
    private String titre;
    private String message;
    private String type;
    private boolean lue;
    private LocalDateTime creeLe;
}