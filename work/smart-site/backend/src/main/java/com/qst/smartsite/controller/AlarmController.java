package com.qst.smartsite.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.qst.smartsite.common.BusinessException;
import com.qst.smartsite.common.Result;
import com.qst.smartsite.entity.Alarm;
import com.qst.smartsite.mapper.AlarmMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 告警管理接口
 * 对应《页面功能清单》八、告警管理
 */
@RestController
@RequestMapping("/api/alarm")
public class AlarmController {

    @Autowired
    private AlarmMapper alarmMapper;

    /** 告警分页列表 */
    @GetMapping("/list")
    public Result<Page<Alarm>> list(@RequestParam(defaultValue = "1") Integer pageNum,
                                    @RequestParam(defaultValue = "10") Integer pageSize,
                                    @RequestParam(required = false) Integer alarmLevel,
                                    @RequestParam(required = false) Integer alarmSource,
                                    @RequestParam(required = false) Integer handleStatus,
                                    @RequestParam(required = false) String keyword) {
        Page<Alarm> page = alarmMapper.selectPage(new Page<>(pageNum, pageSize),
                new LambdaQueryWrapper<Alarm>()
                        .eq(alarmLevel != null, Alarm::getAlarmLevel, alarmLevel)
                        .eq(alarmSource != null, Alarm::getAlarmSource, alarmSource)
                        .eq(handleStatus != null, Alarm::getHandleStatus, handleStatus)
                        .like(keyword != null && !keyword.isBlank(), Alarm::getAlarmContent, keyword)
                        .orderByDesc(Alarm::getAlarmTime));
        return Result.ok(page);
    }

    /** 告警处置（未处置→已处置） */
    @PutMapping("/{id}/handle")
    public Result<Void> handle(@PathVariable Long id,
                               @RequestBody Alarm req,
                               @RequestAttribute("username") String username) {
        Alarm alarm = alarmMapper.selectById(id);
        if (alarm == null) {
            throw new BusinessException(404, "告警不存在");
        }
        alarm.setHandleStatus(2);
        alarm.setHandlePerson(req.getHandlePerson() == null ? username : req.getHandlePerson());
        alarm.setHandleMeasure(req.getHandleMeasure());
        alarm.setHandleConclusion(req.getHandleConclusion());
        alarm.setHandleTime(LocalDateTime.now());
        alarmMapper.updateById(alarm);
        return Result.ok();
    }

    /** 告警统计：级别分布/状态分布/来源分布/近7天趋势 */
    @GetMapping("/stats")
    public Result<Map<String, Object>> stats() {
        Map<String, Object> result = new HashMap<>();
        result.put("byLevel", alarmMapper.countByLevel());
        result.put("byStatus", alarmMapper.countByHandleStatus());
        result.put("bySource", alarmMapper.countBySource());
        result.put("trend", alarmMapper.countByDay(LocalDateTime.now().minusDays(7).toString()));
        return Result.ok(result);
    }
}
