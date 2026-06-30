package com.ldpst.queueforge.branch.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ldpst.queueforge.branch.entity.BranchEntity;
import java.util.List;


public interface BranchRepository extends JpaRepository<BranchEntity, UUID> {
    boolean existsByOrganizationIdAndNameIgnoreCase(UUID organizationId, String name);    

    List<BranchEntity> findAllByOrganizationIdOrderByCreatedAtAsc(UUID organizationId);
}
