package com.qst.smartsite.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.qst.smartsite.common.BusinessException;
import com.qst.smartsite.common.Result;
import com.qst.smartsite.entity.Camera;
import com.qst.smartsite.mapper.CameraMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 摄像头管理接口
 * 对应《页面功能清单》六、视频监控
 */
@RestController
@RequestMapping("/api/camera")
public class CameraController {

    @Autowired
    private CameraMapper cameraMapper;

    /** 摄像头列表 */
    @GetMapping("/list")
    public Result<List<Camera>> list() {
        return Result.ok(cameraMapper.selectList(
                new LambdaQueryWrapper<Camera>().orderByAsc(Camera::getId)));
    }

    /** 新增摄像头 */
    @PostMapping
    public Result<Void> add(@RequestBody Camera camera) {
        if (camera.getCameraCode() == null || camera.getCameraCode().isBlank()) {
            throw new BusinessException(400, "摄像头编码不能为空");
        }
        Long exists = cameraMapper.selectCount(
                new LambdaQueryWrapper<Camera>().eq(Camera::getCameraCode, camera.getCameraCode()));
        if (exists != null && exists > 0) {
            throw new BusinessException(400, "摄像头编码已存在");
        }
        if (camera.getOnlineStatus() == null) camera.setOnlineStatus(1);
        if (camera.getEnableStatus() == null) camera.setEnableStatus(1);
        cameraMapper.insert(camera);
        return Result.ok();
    }

    /** 编辑摄像头 */
    @PutMapping("/{id}")
    public Result<Void> update(@PathVariable Long id, @RequestBody Camera camera) {
        Camera db = cameraMapper.selectById(id);
        if (db == null) {
            throw new BusinessException(404, "摄像头不存在");
        }
        camera.setId(id);
        cameraMapper.updateById(camera);
        return Result.ok();
    }

    /** 删除摄像头 */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        cameraMapper.deleteById(id);
        return Result.ok();
    }
}
