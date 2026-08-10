package com.qst.smartsite.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.qst.smartsite.common.Result;
import com.qst.smartsite.entity.Device;
import com.qst.smartsite.mapper.DeviceMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 设备台账接口（最小闭环：列表 + 详情）
 * 对应《接口设计》4.2.x 设备管理接口
 */
@RestController
@RequestMapping("/api/device")
public class DeviceController {

    @Autowired
    private DeviceMapper deviceMapper;

    /**
     * 设备列表 GET /api/device/list
     */
    @GetMapping("/list")
    public Result<List<Device>> list() {
        List<Device> list = deviceMapper.selectList(
                new LambdaQueryWrapper<Device>().orderByDesc(Device::getCreateTime));
        return Result.ok(list);
    }

    /**
     * 设备详情 GET /api/device/{id}
     */
    @GetMapping("/{id}")
    public Result<Device> detail(@PathVariable Long id) {
        return Result.ok(deviceMapper.selectById(id));
    }
}
