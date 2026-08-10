package com.qst.smartsite.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.qst.smartsite.entity.Alarm;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface AlarmMapper extends BaseMapper<Alarm> {

    /** 按告警级别统计 */
    @Select("SELECT alarm_level AS level, COUNT(*) AS cnt FROM t_alarm GROUP BY alarm_level")
    List<Map<String, Object>> countByLevel();

    /** 按处置状态统计 */
    @Select("SELECT handle_status AS status, COUNT(*) AS cnt FROM t_alarm GROUP BY handle_status")
    List<Map<String, Object>> countByHandleStatus();

    /** 按告警来源统计 */
    @Select("SELECT alarm_source AS source, COUNT(*) AS cnt FROM t_alarm GROUP BY alarm_source")
    List<Map<String, Object>> countBySource();

    /** 近 N 天每日告警趋势 */
    @Select("SELECT DATE_FORMAT(alarm_time, '%Y-%m-%d') AS day, COUNT(*) AS cnt " +
            "FROM t_alarm WHERE alarm_time >= #{startDate} GROUP BY day ORDER BY day")
    List<Map<String, Object>> countByDay(String startDate);
}
