package com.qst.smartsite.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.qst.smartsite.config.RealtimeWebSocketHandler;
import com.qst.smartsite.entity.*;
import com.qst.smartsite.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;

/**
 * 设备数据模拟器（支撑功能，对应计划书"Express+TCP 模拟平台"的轻量实现）
 * 每 5 秒生成一次塔吊/升降机/环境数据，写入数据库并触发阈值告警，
 * 最后通过 WebSocket 广播最新状态给前端。
 */
@Component
public class MockDataScheduler {

    @Autowired
    private DeviceMapper deviceMapper;
    @Autowired
    private RealtimeDataMapper realtimeDataMapper;
    @Autowired
    private EnvDataMapper envDataMapper;
    @Autowired
    private AlarmMapper alarmMapper;
    @Autowired
    private EnvMonitorPointMapper envMonitorPointMapper;
    @Autowired
    private MonitorService monitorService;

    /** 注入 Spring 管理的 ObjectMapper（已注册 JavaTimeModule，可序列化 LocalDateTime） */
    @Autowired
    private ObjectMapper objectMapper;

    private static final DateTimeFormatter NO_FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    // ============ 阈值配置（与 init_data.sql 一致） ============
    private static final BigDecimal CRANE_LOAD_WARN = new BigDecimal("7.2");   // 吊重预警(t)
    private static final BigDecimal CRANE_LOAD_ALARM = new BigDecimal("8.0");  // 吊重警报(t)
    private static final BigDecimal CRANE_WIND_WARN = new BigDecimal("12");    // 风速预警(m/s)
    private static final BigDecimal CRANE_WIND_ALARM = new BigDecimal("18");
    private static final BigDecimal LIFT_LOAD_WARN = new BigDecimal("1800");   // 载重预警(kg)
    private static final BigDecimal LIFT_LOAD_ALARM = new BigDecimal("2000");
    private static final int LIFT_PERSON_WARN = 8;                              // 超员预警
    private static final BigDecimal CRANE_RATED_MOMENT = new BigDecimal("630");// 额定力矩(t·m)

    /**
     * 定时生成模拟数据（5 秒一次）
     */
    @Scheduled(fixedRate = 5000)
    public void generateData() {
        try {
            generateCrane(1L);
            generateCrane(2L);
            generateLift(3L);
            generateEnv();
            broadcast();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /** 塔吊数据 + 告警判断 */
    private void generateCrane(Long deviceId) {
        Random r = ThreadLocalRandom.current();
        write(deviceId, "load", BigDecimal.valueOf(0.8 + r.nextDouble() * 6.5).setScale(2, RoundingMode.HALF_UP), "t");
        write(deviceId, "radius", BigDecimal.valueOf(12 + r.nextDouble() * 40).setScale(1, RoundingMode.HALF_UP), "m");
        write(deviceId, "wind_speed", BigDecimal.valueOf(2 + r.nextDouble() * 14).setScale(1, RoundingMode.HALF_UP), "m/s");
        write(deviceId, "height", BigDecimal.valueOf(8 + r.nextDouble() * 95).setScale(1, RoundingMode.HALF_UP), "m");
        write(deviceId, "angle", BigDecimal.valueOf(r.nextDouble() * 360).setScale(1, RoundingMode.HALF_UP), "°");

        BigDecimal load = latest(deviceId, "load");
        BigDecimal wind = latest(deviceId, "wind_speed");
        BigDecimal radius = latest(deviceId, "radius");
        // 力矩 = 吊重 × 幅度
        BigDecimal moment = (load == null || radius == null) ? null : load.multiply(radius).setScale(2, RoundingMode.HALF_UP);

        checkDeviceAlarm(deviceId, 1L, "吊重", load, CRANE_LOAD_WARN, CRANE_LOAD_ALARM, "t");
        checkDeviceAlarm(deviceId, 3L, "风速", wind, CRANE_WIND_WARN, CRANE_WIND_ALARM, "m/s");
        if (moment != null && moment.compareTo(CRANE_RATED_MOMENT) > 0) {
            addAlarm(1, 3, deviceId, 1L,
                    "塔吊力矩超限！当前" + moment + " t·m > 额定" + CRANE_RATED_MOMENT + " t·m",
                    moment, null);
        }
    }

    /** 升降机数据 + 告警判断 */
    private void generateLift(Long deviceId) {
        Random r = ThreadLocalRandom.current();
        write(deviceId, "load_weight", BigDecimal.valueOf(300 + r.nextDouble() * 1650).setScale(0, RoundingMode.HALF_UP), "kg");
        write(deviceId, "person_count", BigDecimal.valueOf(1 + r.nextInt(8)).setScale(0, RoundingMode.HALF_UP), "人");
        write(deviceId, "height", BigDecimal.valueOf(5 + r.nextDouble() * 115).setScale(1, RoundingMode.HALF_UP), "m");
        write(deviceId, "wind_speed", BigDecimal.valueOf(2 + r.nextDouble() * 12).setScale(1, RoundingMode.HALF_UP), "m/s");
        write(deviceId, "direction", BigDecimal.valueOf(r.nextBoolean() ? 1 : 2).setScale(0, RoundingMode.HALF_UP), "");
        // 门锁：正常互斥；5% 概率双门同时打开（安全隐患）
        boolean bothOpen = r.nextDouble() < 0.05;
        write(deviceId, "door_front", BigDecimal.valueOf(bothOpen || r.nextBoolean() ? 1 : 0).setScale(0, RoundingMode.HALF_UP), "");
        write(deviceId, "door_back", BigDecimal.valueOf(bothOpen || r.nextBoolean() ? 1 : 0).setScale(0, RoundingMode.HALF_UP), "");

        BigDecimal load = latest(deviceId, "load_weight");
        BigDecimal persons = latest(deviceId, "person_count");
        BigDecimal doorF = latest(deviceId, "door_front");
        BigDecimal doorB = latest(deviceId, "door_back");

        checkDeviceAlarm(deviceId, 4L, "载重", load, LIFT_LOAD_WARN, LIFT_LOAD_ALARM, "kg");
        if (persons != null && persons.intValue() > LIFT_PERSON_WARN) {
            addAlarm(1, 1, deviceId, null, "升降机超员！当前" + persons.intValue() + "人", persons, null);
        }
        if (doorF != null && doorB != null && doorF.intValue() == 1 && doorB.intValue() == 1) {
            addAlarm(1, 2, deviceId, null, "升降机前后门同时打开，存在坠落风险", BigDecimal.ONE, null);
        }
    }

    /** 环境监测数据 + 告警判断 */
    private void generateEnv() {
        List<EnvMonitorPoint> points = envMonitorPointMapper.selectList(null);
        Random r = ThreadLocalRandom.current();
        for (EnvMonitorPoint p : points) {
            BigDecimal value = switch (p.getMonitorSubType()) {
                case "PM2.5" -> BigDecimal.valueOf(30 + r.nextDouble() * 130).setScale(1, RoundingMode.HALF_UP);
                case "PM10" -> BigDecimal.valueOf(50 + r.nextDouble() * 230).setScale(1, RoundingMode.HALF_UP);
                case "噪声" -> BigDecimal.valueOf(55 + r.nextDouble() * 40).setScale(1, RoundingMode.HALF_UP);
                case "温度" -> BigDecimal.valueOf(22 + r.nextDouble() * 18).setScale(1, RoundingMode.HALF_UP);
                case "湿度" -> BigDecimal.valueOf(35 + r.nextDouble() * 50).setScale(1, RoundingMode.HALF_UP);
                case "风速" -> BigDecimal.valueOf(2 + r.nextDouble() * 14).setScale(1, RoundingMode.HALF_UP);
                default -> BigDecimal.valueOf(50 + r.nextDouble() * 50).setScale(1, RoundingMode.HALF_UP);
            };
            EnvData data = new EnvData();
            data.setPointId(p.getId());
            data.setIndexValue(value);
            data.setCollectTime(LocalDateTime.now());
            envDataMapper.insert(data);

            // 阈值判断：warn/alarm 上下限
            if (p.getAlarmMax() != null && value.compareTo(p.getAlarmMax()) > 0) {
                addAlarm(2, 2, p.getDeviceId(), p.getId(), p.getPointName() + "超标(警报)：" + value + p.getUnit(), value, null);
            } else if (p.getWarnMax() != null && value.compareTo(p.getWarnMax()) > 0) {
                addAlarm(2, 1, p.getDeviceId(), p.getId(), p.getPointName() + "超标(预警)：" + value + p.getUnit(), value, null);
            } else if (p.getAlarmMin() != null && value.compareTo(p.getAlarmMin()) < 0) {
                addAlarm(2, 2, p.getDeviceId(), p.getId(), p.getPointName() + "低于下限(警报)：" + value + p.getUnit(), value, null);
            } else if (p.getWarnMin() != null && value.compareTo(p.getWarnMin()) < 0) {
                addAlarm(2, 1, p.getDeviceId(), p.getId(), p.getPointName() + "低于下限(预警)：" + value + p.getUnit(), value, null);
            }
        }
    }

    /** 设备参数告警（预警/警报两级） */
    private void checkDeviceAlarm(Long deviceId, Long pointId, String name, BigDecimal value,
                                  BigDecimal warn, BigDecimal alarm, String unit) {
        if (value == null) return;
        if (value.compareTo(alarm) > 0) {
            addAlarm(1, 2, deviceId, pointId, name + "超标(警报)：" + value + unit, value, null);
        } else if (value.compareTo(warn) > 0) {
            addAlarm(1, 1, deviceId, pointId, name + "超标(预警)：" + value + unit, value, null);
        }
    }

    /** 写入实时数据表 */
    private void write(Long deviceId, String paramCode, BigDecimal value, String unit) {
        RealtimeData d = new RealtimeData();
        d.setDeviceId(deviceId);
        d.setParamCode(paramCode);
        d.setParamValue(value);
        d.setUnit(unit);
        d.setCollectTime(LocalDateTime.now());
        realtimeDataMapper.insert(d);
    }

    private BigDecimal latest(Long deviceId, String paramCode) {
        RealtimeData d = realtimeDataMapper.selectOne(
                new LambdaQueryWrapper<RealtimeData>()
                        .eq(RealtimeData::getDeviceId, deviceId)
                        .eq(RealtimeData::getParamCode, paramCode)
                        .orderByDesc(RealtimeData::getCollectTime)
                        .last("LIMIT 1"));
        return d == null ? null : d.getParamValue();
    }

    /** 新增告警（10 分钟内同设备同点同级别未处置的不重复插入） */
    private void addAlarm(int source, int level, Long deviceId, Long pointId, String content, BigDecimal value, Long cameraId) {
        LocalDateTime tenMinAgo = LocalDateTime.now().minusMinutes(10);
        Long count = alarmMapper.selectCount(
                new LambdaQueryWrapper<Alarm>()
                        .eq(Alarm::getAlarmSource, source)
                        .eq(Alarm::getAlarmLevel, level)
                        .eq(Alarm::getDeviceId, deviceId)
                        .eq(pointId != null, Alarm::getPointId, pointId)
                        .ne(Alarm::getHandleStatus, 2)
                        .ge(Alarm::getAlarmTime, tenMinAgo));
        if (count != null && count > 0) {
            return; // 已有活跃告警，不重复生成
        }
        Alarm alarm = new Alarm();
        alarm.setAlarmNo("AL" + LocalDateTime.now().format(NO_FMT) + ThreadLocalRandom.current().nextInt(100, 999));
        alarm.setBatchNo("B" + LocalDateTime.now().format(NO_FMT));
        alarm.setAlarmSource(source);
        alarm.setAlarmLevel(level);
        alarm.setDeviceId(deviceId);
        alarm.setPointId(pointId);
        alarm.setCameraId(cameraId);
        alarm.setAlarmContent(content);
        alarm.setAlarmValue(value);
        alarm.setAlarmTime(LocalDateTime.now());
        alarm.setHandleStatus(0);
        alarmMapper.insert(alarm);
        System.out.println("[ALARM] " + alarm.getAlarmNo() + " " + content);
    }

    /** 广播最新状态给所有前端 */
    private void broadcast() {
        try {
            RealtimeWebSocketHandler.broadcast(objectMapper.writeValueAsString(monitorService.buildRealtimePayload()));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
