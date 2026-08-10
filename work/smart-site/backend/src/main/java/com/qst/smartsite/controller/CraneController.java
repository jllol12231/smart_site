package com.qst.smartsite.controller;

import com.qst.smartsite.common.Result;
import com.qst.smartsite.dto.CraneStatusVO;
import com.qst.smartsite.service.MonitorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 塔吊监控接口
 * 对应《页面功能清单》四、塔吊监控
 */
@RestController
@RequestMapping("/api/crane")
public class CraneController {

    @Autowired
    private MonitorService monitorService;

    /** 塔吊列表（实时状态 + 力矩计算） */
    @GetMapping("/list")
    public Result<List<CraneStatusVO>> list() {
        return Result.ok(monitorService.listCraneStatus());
    }

    /** 塔吊实时监控详情 */
    @GetMapping("/{id}")
    public Result<CraneStatusVO> detail(@PathVariable Long id) {
        return monitorService.listCraneStatus().stream()
                .filter(c -> c.getDeviceId().equals(id))
                .findFirst()
                .map(Result::ok)
                .orElse(Result.fail(404, "塔吊不存在"));
    }
}
