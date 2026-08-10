-- =============================================
-- PostgreSQL Schema for smart_site (No Chinese Comments)
-- =============================================

-- 1. Permission Management
DROP TABLE IF EXISTS t_sys_user CASCADE;
CREATE TABLE t_sys_user (
    id BIGSERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(200) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    emp_no VARCHAR(50) DEFAULT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) DEFAULT NULL,
    gender SMALLINT DEFAULT 0,
    position VARCHAR(50) DEFAULT NULL,
    dept VARCHAR(50) DEFAULT NULL,
    leader VARCHAR(50) DEFAULT NULL,
    status SMALLINT NOT NULL DEFAULT 2,
    locked SMALLINT NOT NULL DEFAULT 0,
    last_login_time TIMESTAMP DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_sys_user_username ON t_sys_user(username);
CREATE INDEX idx_sys_user_status ON t_sys_user(status);

DROP TABLE IF EXISTS t_sys_role CASCADE;
CREATE TABLE t_sys_role (
    id BIGSERIAL NOT NULL,
    role_code VARCHAR(50) NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    description VARCHAR(200) DEFAULT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_sys_role_code ON t_sys_role(role_code);

DROP TABLE IF EXISTS t_sys_user_role CASCADE;
CREATE TABLE t_sys_user_role (
    id BIGSERIAL NOT NULL,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_sys_user_role ON t_sys_user_role(user_id, role_id);

DROP TABLE IF EXISTS t_sys_menu CASCADE;
CREATE TABLE t_sys_menu (
    id BIGSERIAL NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    menu_name VARCHAR(50) NOT NULL,
    menu_code VARCHAR(50) NOT NULL,
    menu_type SMALLINT NOT NULL DEFAULT 1,
    path VARCHAR(100) DEFAULT NULL,
    icon VARCHAR(50) DEFAULT NULL,
    sort INT NOT NULL DEFAULT 0,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_sys_menu_parent ON t_sys_menu(parent_id);

DROP TABLE IF EXISTS t_sys_role_menu CASCADE;
CREATE TABLE t_sys_role_menu (
    id BIGSERIAL NOT NULL,
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    actions VARCHAR(100) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_sys_role_menu ON t_sys_role_menu(role_id, menu_id);

-- 2. Device Asset Management
DROP TABLE IF EXISTS t_device_type CASCADE;
CREATE TABLE t_device_type (
    id BIGSERIAL NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    type_name VARCHAR(50) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_device_type_parent ON t_device_type(parent_id);

DROP TABLE IF EXISTS t_device_location CASCADE;
CREATE TABLE t_device_location (
    id BIGSERIAL NOT NULL,
    parent_id BIGINT NOT NULL DEFAULT 0,
    location_name VARCHAR(50) NOT NULL,
    sort INT NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_device_location_parent ON t_device_location(parent_id);

DROP TABLE IF EXISTS t_device CASCADE;
CREATE TABLE t_device (
    id BIGSERIAL NOT NULL,
    device_code VARCHAR(50) NOT NULL,
    device_name VARCHAR(50) NOT NULL,
    type_id BIGINT NOT NULL,
    location_id BIGINT NOT NULL,
    brand VARCHAR(50) DEFAULT NULL,
    model VARCHAR(50) DEFAULT NULL,
    supplier VARCHAR(100) DEFAULT NULL,
    qr_code VARCHAR(255) DEFAULT NULL,
    produce_date DATE DEFAULT NULL,
    supply_date DATE DEFAULT NULL,
    accept_date DATE DEFAULT NULL,
    install_date DATE DEFAULT NULL,
    enable_date DATE DEFAULT NULL,
    design_service_life INT DEFAULT NULL,
    expect_scrap_date DATE DEFAULT NULL,
    actual_scrap_date DATE DEFAULT NULL,
    last_maintain_date DATE DEFAULT NULL,
    original_value NUMERIC(14,2) DEFAULT NULL,
    device_image VARCHAR(255) DEFAULT NULL,
    coordinate VARCHAR(50) DEFAULT NULL,
    status SMALLINT NOT NULL DEFAULT 0,
    enable_status SMALLINT NOT NULL DEFAULT 1,
    remark VARCHAR(500) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_device_code ON t_device(device_code);
CREATE INDEX idx_device_type ON t_device(type_id);
CREATE INDEX idx_device_location ON t_device(location_id);

DROP TABLE IF EXISTS t_tower_crane_param CASCADE;
CREATE TABLE t_tower_crane_param (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    front_arm_len NUMERIC(10,2) NOT NULL,
    rear_arm_len NUMERIC(10,2) NOT NULL,
    max_height NUMERIC(10,2) NOT NULL,
    rated_load NUMERIC(10,2) NOT NULL,
    max_load NUMERIC(10,2) NOT NULL,
    rated_moment NUMERIC(12,2) NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_tc_param_device ON t_tower_crane_param(device_id);

DROP TABLE IF EXISTS t_lift_param CASCADE;
CREATE TABLE t_lift_param (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    rated_weight NUMERIC(10,2) NOT NULL,
    base_height NUMERIC(10,2) NOT NULL,
    lift_speed NUMERIC(8,2) NOT NULL,
    rated_load NUMERIC(10,2) NOT NULL,
    cage_size NUMERIC(8,2) NOT NULL,
    max_lift_height NUMERIC(10,2) NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_lift_param_device ON t_lift_param(device_id);

DROP TABLE IF EXISTS t_device_monitor_point CASCADE;
CREATE TABLE t_device_monitor_point (
    id BIGSERIAL NOT NULL,
    point_code VARCHAR(50) NOT NULL,
    device_id BIGINT NOT NULL,
    point_name VARCHAR(50) NOT NULL,
    monitor_type VARCHAR(20) NOT NULL,
    monitor_sub_type VARCHAR(30) NOT NULL,
    unit VARCHAR(20) DEFAULT NULL,
    warn_min NUMERIC(12,2) DEFAULT NULL,
    warn_max NUMERIC(12,2) DEFAULT NULL,
    alarm_min NUMERIC(12,2) DEFAULT NULL,
    alarm_max NUMERIC(12,2) DEFAULT NULL,
    spray_enabled SMALLINT NOT NULL DEFAULT 0,
    spray_on_threshold NUMERIC(12,2) DEFAULT NULL,
    spray_off_threshold NUMERIC(12,2) DEFAULT NULL,
    spray_device_id BIGINT DEFAULT NULL,
    collect_interval INT NOT NULL DEFAULT 30,
    install_location VARCHAR(100) DEFAULT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_monitor_point_code ON t_device_monitor_point(point_code);
CREATE INDEX idx_monitor_point_device ON t_device_monitor_point(device_id);

DROP TABLE IF EXISTS t_device_offline_record CASCADE;
CREATE TABLE t_device_offline_record (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    status SMALLINT NOT NULL,
    record_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_offline_device_time ON t_device_offline_record(device_id, record_time);

DROP TABLE IF EXISTS t_realtime_data CASCADE;
CREATE TABLE t_realtime_data (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    point_id BIGINT NOT NULL,
    param_code VARCHAR(30) NOT NULL,
    param_value NUMERIC(12,2) NOT NULL,
    unit VARCHAR(20) DEFAULT NULL,
    collect_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_realtime_device_time ON t_realtime_data(device_id, collect_time);
CREATE INDEX idx_realtime_point_time ON t_realtime_data(point_id, collect_time);

-- 3. Tower Crane & Lift Operation Records
DROP TABLE IF EXISTS t_tower_crane_record CASCADE;
CREATE TABLE t_tower_crane_record (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    hoisting_weight NUMERIC(12,2) NOT NULL,
    max_load_percent NUMERIC(6,2) NOT NULL,
    max_radius NUMERIC(10,2) DEFAULT NULL,
    min_radius NUMERIC(10,2) DEFAULT NULL,
    max_height NUMERIC(10,2) DEFAULT NULL,
    min_height NUMERIC(10,2) DEFAULT NULL,
    max_wind_speed NUMERIC(6,2) DEFAULT NULL,
    max_load NUMERIC(12,2) DEFAULT NULL,
    start_angle NUMERIC(8,2) DEFAULT NULL,
    end_angle NUMERIC(8,2) DEFAULT NULL,
    hook_radius NUMERIC(10,2) DEFAULT NULL,
    hook_height NUMERIC(10,2) DEFAULT NULL,
    unload_radius NUMERIC(10,2) DEFAULT NULL,
    unload_height NUMERIC(10,2) DEFAULT NULL,
    remark VARCHAR(255) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_tc_device_time ON t_tower_crane_record(device_id, start_time);

DROP TABLE IF EXISTS t_lift_record CASCADE;
CREATE TABLE t_lift_record (
    id BIGSERIAL NOT NULL,
    device_id BIGINT NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    load_weight NUMERIC(12,2) NOT NULL,
    person_count INT NOT NULL,
    start_floor INT DEFAULT NULL,
    end_floor INT DEFAULT NULL,
    wind_speed NUMERIC(6,2) DEFAULT NULL,
    run_speed NUMERIC(8,2) DEFAULT NULL,
    tilt_angle_x NUMERIC(8,2) DEFAULT NULL,
    tilt_angle_y NUMERIC(8,2) DEFAULT NULL,
    start_height NUMERIC(10,2) DEFAULT NULL,
    end_height NUMERIC(10,2) DEFAULT NULL,
    direction SMALLINT NOT NULL DEFAULT 1,
    remark VARCHAR(255) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_lift_device_time ON t_lift_record(device_id, start_time);

-- 4. Video Surveillance
DROP TABLE IF EXISTS t_camera CASCADE;
CREATE TABLE t_camera (
    id BIGSERIAL NOT NULL,
    camera_code VARCHAR(50) NOT NULL,
    camera_name VARCHAR(50) NOT NULL,
    location_id BIGINT NOT NULL,
    stream_url VARCHAR(255) NOT NULL,
    online_status SMALLINT NOT NULL DEFAULT 0,
    enable_status SMALLINT NOT NULL DEFAULT 1,
    ai_helmet SMALLINT NOT NULL DEFAULT 0,
    ai_vest SMALLINT NOT NULL DEFAULT 0,
    ai_smoke SMALLINT NOT NULL DEFAULT 0,
    ai_fire SMALLINT NOT NULL DEFAULT 0,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_camera_code ON t_camera(camera_code);
CREATE INDEX idx_camera_location ON t_camera(location_id);

-- 5. Alarm Management
DROP TABLE IF EXISTS t_alarm CASCADE;
CREATE TABLE t_alarm (
    id BIGSERIAL NOT NULL,
    alarm_no VARCHAR(30) NOT NULL,
    batch_no VARCHAR(30) DEFAULT NULL,
    alarm_source SMALLINT NOT NULL,
    alarm_level SMALLINT NOT NULL DEFAULT 1,
    device_id BIGINT DEFAULT NULL,
    point_id BIGINT DEFAULT NULL,
    camera_id BIGINT DEFAULT NULL,
    image_url VARCHAR(255) DEFAULT NULL,
    alarm_content VARCHAR(255) NOT NULL,
    alarm_value NUMERIC(12,2) DEFAULT NULL,
    alarm_time TIMESTAMP NOT NULL,
    handle_status SMALLINT NOT NULL DEFAULT 0,
    handle_person VARCHAR(50) DEFAULT NULL,
    handle_measure VARCHAR(500) DEFAULT NULL,
    handle_conclusion VARCHAR(500) DEFAULT NULL,
    handle_time TIMESTAMP DEFAULT NULL,
    recover_time TIMESTAMP DEFAULT NULL,
    recover_value NUMERIC(12,2) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_alarm_status_level ON t_alarm(handle_status, alarm_level);
CREATE INDEX idx_alarm_source_time ON t_alarm(alarm_source, alarm_time);
CREATE INDEX idx_alarm_device ON t_alarm(device_id, alarm_time);
CREATE INDEX idx_alarm_batch ON t_alarm(batch_no);

-- 6. Environmental Monitoring
DROP TABLE IF EXISTS t_env_monitor_point CASCADE;
CREATE TABLE t_env_monitor_point (
    id BIGSERIAL NOT NULL,
    point_code VARCHAR(50) NOT NULL,
    point_name VARCHAR(50) NOT NULL,
    device_id BIGINT NOT NULL,
    monitor_type VARCHAR(20) NOT NULL,
    monitor_sub_type VARCHAR(30) NOT NULL,
    unit VARCHAR(20) DEFAULT NULL,
    warn_min NUMERIC(12,2) DEFAULT NULL,
    warn_max NUMERIC(12,2) DEFAULT NULL,
    alarm_min NUMERIC(12,2) DEFAULT NULL,
    alarm_max NUMERIC(12,2) DEFAULT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uk_env_point_code ON t_env_monitor_point(point_code);
CREATE INDEX idx_env_point_device ON t_env_monitor_point(device_id);

DROP TABLE IF EXISTS t_env_data CASCADE;
CREATE TABLE t_env_data (
    id BIGSERIAL NOT NULL,
    point_id BIGINT NOT NULL,
    index_value NUMERIC(12,2) NOT NULL,
    collect_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_env_point_time ON t_env_data(point_id, collect_time);

DROP TABLE IF EXISTS t_env_daily_stat CASCADE;
CREATE TABLE t_env_daily_stat (
    id BIGSERIAL NOT NULL,
    point_id BIGINT NOT NULL,
    stat_date DATE NOT NULL,
    max_value NUMERIC(12,2) NOT NULL,
    min_value NUMERIC(12,2) NOT NULL,
    avg_value NUMERIC(12,2) NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_env_daily_point_date ON t_env_daily_stat(point_id, stat_date);

-- 7. Spray Dust Suppression
DROP TABLE IF EXISTS t_spray_task CASCADE;
CREATE TABLE t_spray_task (
    id BIGSERIAL NOT NULL,
    task_name VARCHAR(50) NOT NULL,
    location_id BIGINT NOT NULL,
    start_time TIME NOT NULL,
    duration INT NOT NULL,
    period_value INT NOT NULL,
    period_unit VARCHAR(20) NOT NULL,
    status SMALLINT NOT NULL DEFAULT 1,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_spray_task_location ON t_spray_task(location_id);

DROP TABLE IF EXISTS t_spray_record CASCADE;
CREATE TABLE t_spray_record (
    id BIGSERIAL NOT NULL,
    point_id BIGINT DEFAULT NULL,
    location_id BIGINT NOT NULL,
    device_id BIGINT DEFAULT NULL,
    trigger_type SMALLINT NOT NULL,
    action SMALLINT NOT NULL,
    reason VARCHAR(255) DEFAULT NULL,
    operator VARCHAR(50) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_spray_record_time ON t_spray_record(location_id, create_time);
CREATE INDEX idx_spray_record_point ON t_spray_record(point_id, create_time);

-- 8. IoT & Logging
DROP TABLE IF EXISTS t_iot_data CASCADE;
CREATE TABLE t_iot_data (
    id BIGSERIAL NOT NULL,
    device_tag VARCHAR(20) NOT NULL,
    data_sub_type VARCHAR(20) DEFAULT NULL,
    payload TEXT NOT NULL,
    report_time TIMESTAMP NOT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_iot_tag_time ON t_iot_data(device_tag, report_time);

DROP TABLE IF EXISTS t_operation_log CASCADE;
CREATE TABLE t_operation_log (
    id BIGSERIAL NOT NULL,
    user_id BIGINT DEFAULT NULL,
    username VARCHAR(50) NOT NULL,
    module VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    content VARCHAR(500) DEFAULT NULL,
    ip VARCHAR(50) DEFAULT NULL,
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
CREATE INDEX idx_operlog_user_time ON t_operation_log(user_id, create_time);