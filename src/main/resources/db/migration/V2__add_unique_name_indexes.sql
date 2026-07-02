create unique index uq_organizations_name_lower
    on organizations (lower(name));

create unique index uq_branches_organization_name_lower
    on branches (organization_id, lower(name));