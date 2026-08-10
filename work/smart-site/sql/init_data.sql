SET NAMES utf8mb4;

INSERT INTO t_sys_role (id, role_code, role_name, description, status) VALUES
(1, 'ADMIN', '系统管理员', '管理用户、角色、系统配置，看到所有功能', 1),
(2, 'LEADER', '项目经理/领导', '查看全局数据大屏、统计报表，只读为主', 1),
(3, 'SAFETY', '安全管理员', '查看设备、处理告警、管理监控，日常操作为主', 1);

INSERT INTO t_sys_user (id, username, password, real_name, emp_no, phone, email, gender, position, dept, status, locked) VALUES
(1, 'admin', '$2a$10$1l1PrzdAHS3j358aW/gYrem4SD7nwzppof05l5BjUPhqeDrYt8/cO', '系统管理员', 'EMP001', '13800000001', 'admin@qst.edu.cn', 1, '系统管理员', '信息中心', 1, 0),
(2, 'leader', '$2a$10$1l1PrzdAHS3j358aW/gYrem4SD7nwzppof05l5BjUPhqeDrYt8/cO', '项目经理', 'EMP002', '13800000002', 'leader@qst.edu.cn', 1, '项目经理', '项目部', 1, 0),
(3, 'safety', '$2a$10$1l1PrzdAHS3j358aW/gYrem4SD7nwzppof05l5BjUPhqeDrYt8/cO', '安全管理员', 'EMP003', '13800000003', 'safety@qst.edu.cn', 2, '安全管理员', '安全管理部', 1, 0);

INSERT INTO t_sys_user_role (user_id, role_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO t_sys_menu (id, parent_id, menu_name, menu_code, menu_type, path, icon, sort, status) VALUES
(1, 0, '首页/工作台', 'home', 1, '/home', 'HomeFilled', 1, 1),
(2, 0, '设备资产管理', 'device', 1, '/device', 'Monitor', 2, 1),
(3, 0, '塔吊监控', 'crane', 1, '/crane', 'Platform', 3, 1),
(4, 0, '升降机监控', 'lift', 1, '/lift', 'Odometer', 4, 1),
(5, 0, '视频监控', 'video', 1, '/video', 'VideoCamera', 5, 1),
(6, 0, 'AI智能识别', 'ai', 1, '/ai', 'Aim', 6, 1),
(7, 0, '告警管理', 'alarm', 1, '/alarm', 'Bell', 7, 1),
(8, 0, '环境监测', 'env', 1, '/env', 'Sunny', 8, 1),
(9, 0, '喷淋降尘', 'spray', 1, '/spray', 'Umbrella', 9, 1),
(10, 0, '数据大屏', 'screen', 1, '/screen', 'DataBoard', 10, 1),
(11, 0, '3D可视化', 'three', 1, '/three', 'Box', 11, 1),
(12, 0, 'Coze智能体', 'coze', 1, '/coze', 'ChatDotRound', 12, 1);

INSERT INTO t_sys_role_menu (role_id, menu_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),
(2,1),(2,3),(2,4),(2,7),(2,8),(2,10),(2,11),
(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9);

INSERT INTO t_device_type (id, parent_id, type_name, sort) VALUES
(1, 0, '大型机械', 1),
(2, 1, '塔吊', 1),
(3, 1, '施工升降机', 2),
(4, 0, '环境监测设备', 2),
(5, 4, '环境传感器', 1),
(6, 0, '安全防护设备', 3),
(7, 6, '喷淋设备', 1),
(8, 6, '视频监控', 2);

INSERT INTO t_device_location (id, parent_id, location_name, sort) VALUES
(1, 0, '一期项目', 1),
(2, 1, '1号楼', 1),
(3, 1, '2号楼', 2),
(4, 2, '东侧', 1),
(5, 2, '西侧', 2),
(6, 3, '南侧', 1);

INSERT INTO t_device (id, device_code, device_name, type_id, location_id, brand, model, supplier, qr_code, produce_date, supply_date, accept_date, install_date, enable_date, design_service_life, original_value, coordinate, status, enable_status, remark) VALUES
(1, 'TC-001', '1号塔吊', 2, 4, '中联重科', 'QTZ80', '中联重科', 'QR-TC-001', '2024-03-01', '2024-04-10', '2024-04-20', '2024-05-01', '2024-05-10', 10, 680000.00, 'x:120,y:80', 1, 1, '一期1号楼东侧塔吊'),
(2, 'TC-002', '2号塔吊', 2, 5, '徐工集团', 'QTZ63', '徐工集团', 'QR-TC-002', '2024-06-01', '2024-07-01', '2024-07-10', '2024-07-15', '2024-07-20', 10, 520000.00, 'x:260,y:80', 1, 1, '一期1号楼西侧塔吊'),
(3, 'LFT-001', '1号施工升降机', 3, 4, '广州特威', 'SC200/200', '广州特威', 'QR-LFT-001', '2024-05-01', '2024-06-01', '2024-06-10', '2024-06-15', '2024-06-20', 8, 180000.00, 'x:150,y:40', 1, 1, '一期1号楼东侧升降机'),
(4, 'ENV-001', '环境监测站1', 5, 4, '聚光科技', 'ENV-8000', '聚光科技', 'QR-ENV-001', '2024-02-01', '2024-03-01', '2024-03-10', '2024-03-15', '2024-03-20', 5, 45000.00, 'x:100,y:60', 1, 1, '一期1号楼东侧环境监测'),
(5, 'ENV-002', '环境监测站2', 5, 6, '聚光科技', 'ENV-8000', '聚光科技', 'QR-ENV-002', '2024-02-01', '2024-03-01', '2024-03-10', '2024-03-15', '2024-03-20', 5, 45000.00, 'x:300,y:120', 0, 1, '一期2号楼南侧环境监测'),
(6, 'SPR-001', '1号楼喷淋装置', 7, 4, '国产', 'PL-100', '本地供应商', 'QR-SPR-001', '2024-02-01', '2024-03-01', '2024-03-10', '2024-03-15', '2024-03-20', 3, 12000.00, 'x:100,y:60', 1, 1, '与ENV-001联动'),
(7, 'CAM-001', '1号楼东侧摄像头', 8, 4, '海康威视', 'DS-2CD', '海康威视', 'QR-CAM-001', '2024-02-01', '2024-03-01', '2024-03-10', '2024-03-15', '2024-03-20', 5, 3200.00, 'x:110,y:50', 1, 1, '覆盖塔吊区域，AI识别：安全帽+安全服'),
(8, 'CAM-002', '材料堆场摄像头', 8, 6, '海康威视', 'DS-2CD', '海康威视', 'QR-CAM-002', '2024-02-01', '2024-03-01', '2024-03-10', '2024-03-15', '2024-03-20', 5, 3200.00, 'x:320,y:100', 0, 1, '覆盖堆场区域，AI识别：明火');

INSERT INTO t_tower_crane_param (device_id, front_arm_len, rear_arm_len, max_height, rated_load, max_load, rated_moment) VALUES
(1, 55.00, 12.00, 120.00, 8.00, 10.00, 630.00),
(2, 45.00, 10.00, 100.00, 6.00, 8.00, 400.00);

INSERT INTO t_lift_param (device_id, rated_weight, base_height, lift_speed, rated_load, cage_size, max_lift_height) VALUES
(3, 2.00, 5.00, 0.63, 2000.00, 8.40, 150.00);

INSERT INTO t_env_monitor_point (id, point_code, point_name, device_id, monitor_type, monitor_sub_type, unit, warn_min, warn_max, alarm_min, alarm_max, status) VALUES
(1, 'ENV-PM25-01', 'PM2.5监测点', 4, 'env', 'PM2.5', 'μg/m³', NULL, 75.00, NULL, 150.00, 1),
(2, 'ENV-PM10-01', 'PM10监测点', 4, 'env', 'PM10', 'μg/m³', NULL, 150.00, NULL, 260.00, 1),
(3, 'ENV-NOISE-01', '噪声监测点', 4, 'env', '噪声', 'dB', NULL, 70.00, NULL, 90.00, 1),
(4, 'ENV-TEMP-01', '温度监测点', 4, 'env', '温度', '℃', NULL, 38.00, NULL, 42.00, 1),
(5, 'ENV-HUMI-01', '湿度监测点', 4, 'env', '湿度', '%', 20.00, 85.00, 10.00, 95.00, 1),
(6, 'ENV-WIND-01', '风速监测点', 4, 'env', '风速', 'm/s', NULL, 12.00, NULL, 18.00, 1);

INSERT INTO t_device_monitor_point (id, point_code, device_id, point_name, monitor_type, monitor_sub_type, unit, warn_max, alarm_max, spray_enabled, collect_interval, status) VALUES
(1, 'TC-MOMENT-01', 1, '力矩监测点', 'device', '力矩', 't·m', 567.00, 630.00, 0, 5, 1),
(2, 'TC-LOAD-01', 1, '吊重监测点', 'device', '吊重', 't', 7.20, 8.00, 0, 5, 1),
(3, 'TC-WIND-01', 1, '风速监测点', 'device', '风速', 'm/s', 12.00, 18.00, 0, 5, 1),
(4, 'LFT-LOAD-01', 3, '载重监测点', 'device', '载重', 'kg', 1800.00, 2000.00, 0, 5, 1),
(5, 'ENV-PM25-SPR', 4, 'PM2.5联动喷淋点', 'device', 'PM2.5', 'μg/m³', 75.00, 150.00, 1, 30, 1);

INSERT INTO t_camera (camera_code, camera_name, location_id, stream_url, online_status, enable_status, ai_helmet, ai_vest, ai_smoke, ai_fire) VALUES
('CAM-001', '1号楼东侧摄像头', 4, 'http://localhost:8068/hls/cam1/index.m3u8', 1, 1, 1, 1, 0, 0),
('CAM-002', '材料堆场摄像头', 6, 'http://localhost:8068/hls/cam2/index.m3u8', 1, 1, 0, 0, 0, 1);