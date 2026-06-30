package com.ldpst.queueforge.branch.service;

import java.time.DateTimeException;
import java.time.Instant;
import java.time.ZoneId;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.ldpst.queueforge.branch.dto.BranchResponse;
import com.ldpst.queueforge.branch.dto.CreateBranchRequest;
import com.ldpst.queueforge.branch.entity.BranchEntity;
import com.ldpst.queueforge.branch.entity.BranchStatus;
import com.ldpst.queueforge.branch.repository.BranchRepository;
import com.ldpst.queueforge.common.exception.BadRequestException;
import com.ldpst.queueforge.common.exception.ConflictException;
import com.ldpst.queueforge.common.exception.NotFoundException;
import com.ldpst.queueforge.organization.repository.OrganizationRepository;

import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Service
public class BranchService {
    private final BranchRepository branchRepository;
    private final OrganizationRepository organizationRepository;

    @Transactional
    public BranchResponse create(UUID organizationId, CreateBranchRequest request) {
        if (!organizationRepository.existsById(organizationId)) {
            throw new NotFoundException("Organization not found");
        }

        String branchName = request.name().trim();

        if (branchRepository.existsByOrganizationIdAndNameIgnoreCase(organizationId, branchName)) {
            throw new ConflictException("Branch with this name already exists in organization");
        }

        Instant timenow = Instant.now();

        BranchEntity branchEntity = new BranchEntity();
        branchEntity.setOrganizationId(organizationId);
        branchEntity.setName(branchName);
        branchEntity.setAddress(request.address().trim());
        branchEntity.setTimezone(parseTimezone(request.timezone()));
        branchEntity.setStatus(BranchStatus.ACTIVE);
        branchEntity.setCreatedAt(timenow);
        branchEntity.setUpdatedAt(timenow);

        BranchEntity updBranchEntity = branchRepository.save(branchEntity);

        return toResponse(updBranchEntity);
    }

    @Transactional(readOnly = true)
    public List<BranchResponse> getByOrganization(UUID organizationId) {
        if (!organizationRepository.existsById(organizationId)) {
            throw new NotFoundException("Organization not found");
        }

        List<BranchEntity> organizationEntities = 
                branchRepository.findAllByOrganizationIdOrderByCreatedAtAsc(organizationId);
        
        return organizationEntities.stream()
                .map(entity -> toResponse(entity))
                .toList();
    }

    @Transactional(readOnly = true)
    public BranchResponse getById(UUID branchId) {
        BranchEntity branch = branchRepository.findById(branchId)
            .orElseThrow(() -> new NotFoundException("Branch not found"));

        return toResponse(branch);
    }
    
    private String parseTimezone(String timezone) {
        try {
            return ZoneId.of(timezone.trim()).getId();
        } catch (DateTimeException exception) {
            throw new BadRequestException("Invalid timezone: " + timezone);
        }
    }

    private BranchResponse toResponse(BranchEntity entity) {
        return new BranchResponse(
                entity.getId(),
                entity.getOrganizationId(),
                entity.getName(),
                entity.getAddress(),
                entity.getTimezone(),
                entity.getStatus(),
                entity.getCreatedAt(),
                entity.getUpdatedAt());
    }
}
