package com.bank.numsante.config;

import com.bank.numsante.entity.Hopital;
import com.bank.numsante.repository.HopitalRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final HopitalRepository hopitalRepo;

    @Override
    public void run(String... args) {
        if (hopitalRepo.count() == 0) {
            hopitalRepo.save(new Hopital(null, "Hôpital Général", "Yaoundé, Cameroun", "HG-CMR-001", null));
        }
    }
}
