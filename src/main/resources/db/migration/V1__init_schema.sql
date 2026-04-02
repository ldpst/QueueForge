create extension if not exists pgcrypto;

create table organizations (
    id uuid primary key default gen_random_uuid(),
    name varchar(255) not null,
    description text,
    status varchar(32) not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,

    constraint chk_organizations_status
        check (status in ('ACTIVE', 'DISABLED'))
);

create table branches (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null,
    name varchar(255) not null,
    address varchar(500) not null,
    timezone varchar(64) not null,
    status varchar(32) not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,

    constraint fk_branches_organization
        foreign key (organization_id) references organizations(id),

    constraint chk_branches_status
        check (status in ('ACTIVE', 'DISABLED'))
);

create table queue_services (
    id uuid primary key default gen_random_uuid(),
    branch_id uuid not null,
    code varchar(32) not null,
    name varchar(255) not null,
    description text,
    avg_service_time_minutes integer,
    is_active boolean not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,

    constraint fk_queue_services_branch
        foreign key (branch_id) references branches(id),

    constraint uq_queue_services_branch_code
        unique (branch_id, code),

    constraint chk_queue_services_avg_time
        check (avg_service_time_minutes is null or avg_service_time_minutes > 0)
);

create table operator_windows (
    id uuid primary key default gen_random_uuid(),
    branch_id uuid not null,
    number integer not null,
    name varchar(255),
    status varchar(32) not null,
    created_at timestamptz not null,
    updated_at timestamptz not null,

    constraint fk_operator_windows_branch
        foreign key (branch_id) references branches(id),

    constraint uq_operator_windows_branch_number
        unique (branch_id, number),

    constraint chk_operator_windows_status
        check (status in ('OPEN', 'PAUSED', 'CLOSED')),

    constraint chk_operator_windows_number
        check (number > 0)
);

create table ticket_number_counters (
    id uuid primary key default gen_random_uuid(),
    branch_id uuid not null,
    service_id uuid not null,
    business_date date not null,
    last_number integer not null,
    updated_at timestamptz not null,

    constraint fk_ticket_number_counters_branch
        foreign key (branch_id) references branches(id),

    constraint fk_ticket_number_counters_service
        foreign key (service_id) references queue_services(id),

    constraint uq_ticket_number_counters_scope
        unique (branch_id, service_id, business_date),

    constraint chk_ticket_number_counters_last_number
        check (last_number >= 0)
);

create table tickets (
    id uuid primary key default gen_random_uuid(),
    branch_id uuid not null,
    service_id uuid not null,
    operator_window_id uuid,
    business_date date not null,
    ticket_number varchar(32) not null,
    sequence_number integer not null,
    status varchar(32) not null,
    priority integer not null,

    created_at timestamptz not null,
    called_at timestamptz,
    service_started_at timestamptz,
    completed_at timestamptz,
    skipped_at timestamptz,
    cancelled_at timestamptz,
    expired_at timestamptz,

    constraint fk_tickets_branch
        foreign key (branch_id) references branches(id),

    constraint fk_tickets_service
        foreign key (service_id) references queue_services(id),

    constraint fk_tickets_operator_window
        foreign key (operator_window_id) references operator_windows(id),

    constraint uq_tickets_branch_date_number
        unique (branch_id, business_date, ticket_number),

    constraint chk_tickets_status
        check (status in (
            'WAITING',
            'CALLED',
            'IN_SERVICE',
            'COMPLETED',
            'SKIPPED',
            'CANCELLED',
            'EXPIRED'
        )),

    constraint chk_tickets_sequence_number
        check (sequence_number > 0),

    constraint chk_tickets_priority
        check (priority >= 0)
);

create table ticket_status_history (
    id uuid primary key default gen_random_uuid(),
    ticket_id uuid not null,
    old_status varchar(32),
    new_status varchar(32) not null,
    changed_by uuid,
    reason varchar(500),
    changed_at timestamptz not null,

    constraint fk_ticket_status_history_ticket
        foreign key (ticket_id) references tickets(id)
);

create table audit_logs (
    id uuid primary key default gen_random_uuid(),
    actor_id uuid,
    action varchar(128) not null,
    entity_type varchar(128) not null,
    entity_id uuid,
    payload jsonb,
    created_at timestamptz not null
);

create index idx_branches_organization_id
    on branches(organization_id);

create index idx_queue_services_branch_id
    on queue_services(branch_id);

create index idx_operator_windows_branch_status
    on operator_windows(branch_id, status);

create index idx_tickets_next_waiting
    on tickets(branch_id, service_id, status, priority desc, created_at);

create index idx_tickets_branch_status
    on tickets(branch_id, status);

create index idx_tickets_operator_window
    on tickets(operator_window_id);

create index idx_ticket_status_history_ticket_changed_at
    on ticket_status_history(ticket_id, changed_at);

create index idx_audit_logs_entity
    on audit_logs(entity_type, entity_id);

create index idx_audit_logs_created_at
    on audit_logs(created_at);