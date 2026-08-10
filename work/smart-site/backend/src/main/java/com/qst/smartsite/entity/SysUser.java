package com.qst.smartsite.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 系统用户表 t_sys_user
 */
@Data
@TableName("t_sys_user")
public class SysUser {

    /** 主键ID */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /** 登录账号 */
    private String username;

    /** 登录密码(BCrypt加密) */
    private String password;

    /** 真实姓名 */
    private String realName;

    /** 员工编号 */
    private String empNo;

    /** 手机号 */
    private String phone;

    /** 邮箱 */
    private String email;

    /** 性别(0-未选择,1-男,2-女) */
    private Integer gender;

    /** 岗位 */
    private String position;

    /** 部门 */
    private String dept;

    /** 直属上级 */
    private String leader;

    /** 账号状态(1-正常,0-禁用,2-未激活) */
    private Integer status;

    /** 锁定标记(1-锁定,0-正常) */
    private Integer locked;

    /** 最后登录时间 */
    private LocalDateTime lastLoginTime;

    /** 创建时间 */
    private LocalDateTime createTime;

    /** 更新时间 */
    private LocalDateTime updateTime;
}
