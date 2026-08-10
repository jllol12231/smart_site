<template>
  <div>
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span><el-icon><HomeFilled /></el-icon> 数据概览首页</span>
          <el-tag type="success" size="small">今日安全态势 · 自动刷新</el-tag>
        </div>
      </template>

      <el-row :gutter="16">
        <el-col :span="6" v-for="item in stats" :key="item.label">
          <div class="stat-card" :style="{ borderColor: item.color }">
            <div class="stat-value" :style="{ color: item.color }">{{ item.value }}</div>
            <div class="stat-label">{{ item.label }}</div>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="16" class="mt16">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <span><el-icon><Bell /></el-icon> 最新告警</span>
          </template>
          <el-table :data="latestAlarms" size="small" stripe>
            <el-table-column prop="alarmTime" label="时间" width="160" />
            <el-table-column prop="alarmContent" label="告警内容" min-width="200" show-overflow-tooltip />
            <el-table-column label="级别" width="70" align="center">
              <template #default="{ row }">
                <el-tag :type="['', 'warning', 'danger', 'error'][row.alarmLevel]" size="small">
                  {{ ['', '预警', '警报', '控制'][row.alarmLevel] }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>
            <span><el-icon><User /></el-icon> 当前登录用户</span>
          </template>
          <el-descriptions :column="2" border>
            <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
            <el-descriptions-item label="姓名">{{ userInfo.realName }}</el-descriptions-item>
            <el-descriptions-item label="角色">{{ roleName }}</el-descriptions-item>
            <el-descriptions-item label="部门">{{ userInfo.dept || '-' }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { getDashboardStats, getAlarmList } from '../api/monitor'
import request from '../api/request'
import wsClient from '../api/ws'

const userInfo = ref({})
const roleName = ref('')
const stats = ref([
  { label: '在线设备', value: '-', color: '#67C23A' },
  { label: '离线设备', value: '-', color: '#F56C6C' },
  { label: '今日告警', value: '-', color: '#E6A23C' },
  { label: '未处理告警', value: '-', color: '#409EFF' }
])
const latestAlarms = ref([])

const loadStats = async () => {
  const data = await getDashboardStats()
  const labels = ['在线设备', '离线设备', '今日告警', '未处理告警']
  const keys = ['onlineDevices', 'offlineDevices', 'todayAlarms', 'unhandledAlarms']
  stats.value = keys.map((k, i) => ({ label: labels[i], value: data[k], color: stats.value[i].color }))
  const alarms = await getAlarmList({ pageNum: 1, pageSize: 6 })
  latestAlarms.value = alarms.records
}

let unsub = null
onMounted(async () => {
  const stored = JSON.parse(localStorage.getItem('userInfo') || '{}')
  userInfo.value = await request.get('/auth/info')
  const map = { ADMIN: '系统管理员', LEADER: '项目经理', SAFETY: '安全管理员' }
  roleName.value = (stored.roles || []).map(r => map[r] || r).join(' / ')
  await loadStats()
  unsub = wsClient.subscribe(() => loadStats())
})
onUnmounted(() => unsub && unsub())
</script>

<style scoped>
.card-header { display: flex; justify-content: space-between; align-items: center; }
.stat-card { text-align: center; padding: 20px 0; border: 2px solid; border-radius: 8px; background: #fff; }
.stat-value { font-size: 32px; font-weight: 700; }
.stat-label { margin-top: 6px; color: #606266; font-size: 14px; }
.mt16 { margin-top: 16px; }
</style>
