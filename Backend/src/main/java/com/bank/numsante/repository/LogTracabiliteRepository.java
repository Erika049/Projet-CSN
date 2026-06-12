package com.bank.numsante.repository;

import com.bank.numsante.entity.LogTracabilite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Pageable;
import java.util.List;

public interface LogTracabiliteRepository
        extends JpaRepository<LogTracabilite, Long> {

    List<LogTracabilite> findAllByOrderByHorodatageDesc(
            Pageable pageable);
}