package com.ldpst.queueforge.branch.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateBranchRequest (
    @NotBlank(message = "Branch name must not be blank")
    @Size(max = 255, message = "Branch name must be at most 255 characters")
    String name,
    
    @NotBlank(message = "Branch address must not be blank")
    @Size(max = 500, message = "Branch address must be at most 500 characters")
    String address,

    @NotBlank(message = "Branch timezone must not be blank")
    @Size(max = 64, message = "Branch timezone must be at most 64 characters")
    String timezone
) {
}
