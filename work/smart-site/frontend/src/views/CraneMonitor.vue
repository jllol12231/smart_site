<template>
  <div>
    <el-alert type="info" :closable="false" class="mb16"
      title="数据由设备模拟器每 5 秒生成并通过 WebSocket 实时推送，力矩 = 吊重 × 幅度（实时计算）" />

    <el-row :gutter="16">
      <el-col :span="8" v-for="crane in cranes" :key="crane.deviceId">
        <el-card shadow="hover" :class="['crane-card', crane.status !== 1 ? 'is-offline' : '', riskClass(crane)]">
          <div class="card-head">
            <div>
              <div class="name">{{ crane.deviceName }}</div>
              <div class="code">{{ crane.deviceCode }}</div>
            </div>
            <el-tag :type="crane.status === 1 ? 'success' : 'danger'">
              {{ crane.status === 1 ? '在线' : '离线' }}
            </el-tag>
          </div>

          <div class="moment-box">
            <div class="moment-label">当前力矩</div>
            <div class="moment-value" :style="{ color: riskColor(crane) }">
              {{ fmt(crane.moment) }} <span class="unit">t·m</span>
            </div>
            <el-progress :percentage="percent(crane.momentPercent)" :color="progressColor" :stroke-width="10" />
            <div class="moment-sub">
              额定 {{ fmt(crane.ratedMoment) }} t·m · 占比 {{ fmt(crane.momentPercent) }}%
            </div>
          </div>

          <el-descriptions :column="3" size="small" class="mt12">
            <el-descriptions-item label="吊重">{{ fmt(crane.loadVal) }} t</el-descriptions-item>
            <el-descriptions-item label="幅度">{{ fmt(crane.radiusVal) }} m</el-descriptions-item>
            <el-descriptions-item label="风速">{{ fmt(crane.windSpeed) }} m/s</el-descriptions-item>
            <el-descriptions-item label="高度">{{ fmt(crane.height) }} m</el-descriptions-item>
            <el-descriptions-item label="角度">{{ fmt(crane.angle) }}°</el-descriptions-item>
            <el-descriptions-item label="额定载荷">{{ fmt(crane.ratedLoad) }} t</el-descriptions-item>
          </el-descriptions>

          <el-button type="primary" size="small" class="mt12" @click="showDetail(crane)">查看详情</el-button>
        </el-card>
      </el-col>
    </el-row>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailVisible" :title="detail && detail.deviceName" width="560px">
      <template v-if="detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="设备编码">{{ detail.deviceCode }}</el-descriptions-item>
          <el-descriptions-item label="运行状态">
            <el-tag :type="detail.status === 1 ? 'success' : 'danger'" size="small">
              {{ detail.status === 1 ? '在线' : '离线' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="前臂长">{{ fmt(detail.frontArmLen) }} m</el-descriptions-item>
          <el-descriptions-item label="最大高度">{{ fmt(detail.maxHeight) }} m</el-descriptions-item>
          <el-descriptions-item label="额定载荷">{{ fmt(detail.ratedLoad) }} t</el-descriptions-item>
          <el-descriptions-item label="最大载荷">{{ fmt(detail.maxLoad) }} t</el-descriptions-item>
          <el-descriptions-item label="额定力矩">{{ fmt(detail.ratedMoment) }} t·m</el-descriptions-item>
          <el-descriptions-item label="当前力矩">{{ fmt(detail.moment) }} t·m ({{ fmt(detail.momentPercent) }}%)</el-descriptions-item>
          <el-descriptions-item label="吊重">{{ fmt(detail.loadVal) }} t</el-descriptions-item>
          <el-descriptions-item label="幅度">{{ fmt(detail.radiusVal) }} m</el-descriptions-item>
          <el-descriptions-item label="风速">{{ fmt(detail.windSpeed) }} m/s</el-descriptions-item>
          <el-descriptions-item label="吊钩高度">{{ fmt(detail.height) }} m</el-descriptions-item>
          <el-descriptions-item label="回转角度">{{ fmt(detail.angle) }}°</el-descriptions-item>
          <el-descriptions-item label="数据更新">WebSocket 实时推送</el-descriptions-item>
        </el-descriptions>
        <el-alert v-if="detail.momentPercent && detail.momentPercent >= 90" type="error" :closable="false"
          class="mt12" title="力矩接近/超过额定值，存在超载风险！" />
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { getCraneList } from '../api/monitor'
import wsClient from '../api/ws'

const cranes = ref([])
const detailVisible = ref(false)
const detail = ref(null)

const fmt = v => (v === null || v === undefined ? '-' : Number(v).toLocaleString())
const percent = p => Math.min(100, Number(p || 0))

const progressColor = p => {
  if (p >= 90) return '#F56C6C'
  if (p >= 80) return '#E6A23C'
  return '#67C23A'
}

const riskClass = crane => (crane.momentPercent && crane.momentPercent >= 90 ? 'is-risk' : '')
const riskColor = crane => (crane.momentPercent && crane.momentPercent >= 90 ? '#F56C6C' : '#303133')

const showDetail = crane => {
  detail.value = crane
  detailVisible.value = true
}

let unsub = null
onMounted(async () => {
  cranes.value = await getCraneList()
  unsub = wsClient.subscribe(data => {
    if (data.cranes) cranes.value = data.cranes
  })
})
onUnmounted(() => unsub && unsub())
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.mt12 { margin-top: 12px; }
.crane-card { border-top: 3px solid #409EFF; }
.crane-card.is-risk { border-top-color: #F56C6C; }
.crane-card.is-offline { opacity: 0.65; }
.card-head { display: flex; justify-content: space-between; align-items: center; }
.name { font-size: 16px; font-weight: 600; }
.code { font-size: 12px; color: #909399; margin-top: 2px; }
.moment-box { margin: 14px 0 6px; }
.moment-label { font-size: 12px; color: #909399; }
.moment-value { font-size: 30px; font-weight: 700; }
.moment-value .unit { font-size: 14px; font-weight: 400; }
.moment-sub { font-size: 12px; color: #909399; margin-top: 4px; }
</style>
