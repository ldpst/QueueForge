package com.ldpst.queueforge.branch.dto;

import java.time.Instant;
import java.util.UUID;

import com.ldpst.queueforge.branch.entity.BranchStatus;

public record BranchResponse (
    UUID id,
    UUID organizationId,
    String name,
    String address,
    String timezone,
    BranchStatus status,
    Instant createdAt,
    Instant updatedAt
) {    
}
