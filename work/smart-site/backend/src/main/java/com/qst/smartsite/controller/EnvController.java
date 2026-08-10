package com.qst.smartsite.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.qst.smartsite.common.Result;
import com.qst.smartsite.entity.EnvData;
import com.qst.smartsite.mapper.EnvDataMapper;
import com.qst.smartsite.service.MonitorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 环境监测接口
 * 对应《页面功能清单》九、环境监测
 */
@RestController
@RequestMapping("/api/env")
public class EnvController {

    @Autowired
    private MonitorService monitorService;

    @Autowired
    private EnvDataMapper envDataMapper;

    /** 环境监测点实时状态 */
    @GetMapping("/points")
    public Result<List<Map<String, Object>>> points() {
        return Result.ok(monitorService.listEnvStatus());
    }

    /** 单个监测点历史趋势（默认最近 24 小时） */
    @GetMapping("/history")
    public Result<List<EnvData>> history(@RequestParam Long pointId,
                                         @RequestParam(defaultValue = "24") Integer hours) {
        LocalDateTime start = LocalDateTime.now().minusHours(hours);
        List<EnvData> list = envDataMapper.selectList(
                new LambdaQueryWrapper<EnvData>()
                        .eq(EnvData::getPointId, pointId)
                        .ge(EnvData::getCollectTime, start)
                        .orderByAsc(EnvData::getCollectTime)
                        .last("LIMIT 500"));
        return Result.ok(list);
    }
}
