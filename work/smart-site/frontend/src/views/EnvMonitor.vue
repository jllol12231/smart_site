<template>
  <div>
    <el-alert type="info" :closable="false" class="mb16"
      title="环境监测：PM2.5 / PM10 / 噪声 / 温度 / 湿度 / 风速，点击监测点查看历史趋势" />

    <el-row :gutter="16">
      <el-col :span="8" v-for="p in points" :key="p.pointId">
        <el-card shadow="hover" class="env-card" :class="statusClass(p)" @click="selectPoint(p)">
          <div class="env-head">
            <span class="env-name">{{ p.pointName }}</span>
            <el-tag :type="statusTag(p)" size="small">{{ statusText(p) }}</el-tag>
          </div>
          <div class="env-value" :style="{ color: statusColor(p) }">
            {{ fmt(p.value) }} <span class="unit">{{ p.unit }}</span>
          </div>
          <div class="env-sub">
            预警阈值 {{ fmt(p.warnMax) }} · 报警阈值 {{ fmt(p.alarmMax) }}
            <template v-if="p.warnMin != null"> · 下限 {{ fmt(p.warnMin) }}</template>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card shadow="never" class="mt16">
      <template #header>
        <span><el-icon><TrendCharts /></el-icon> 历史趋势：{{ selected ? selected.pointName : '请点击上方监测点' }}</span>
        <el-radio-group v-model="hours" size="small" class="ml12" @change="loadHistory">
          <el-radio-button :value="6">6小时</el-radio-button>
          <el-radio-button :value="24">24小时</el-radio-button>
        </el-radio-group>
      </template>
      <div ref="chartRef" class="chart"></div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getEnvPoints, getEnvHistory } from '../api/monitor'
import wsClient from '../api/ws'

const points = ref([])
const selected = ref(null)
const hours = ref(24)
const chartRef = ref()
let chart = null

const fmt = v => (v === null || v === undefined ? '-' : Number(v).toLocaleString())

const statusOf = p => {
  if (p.value === null || p.value === undefined) return 0
  const v = Number(p.value)
  if (p.alarmMax != null && v > Number(p.alarmMax)) return 2
  if (p.warnMax != null && v > Number(p.warnMax)) return 1
  if (p.alarmMin != null && v < Number(p.alarmMin)) return 2
  if (p.warnMin != null && v < Number(p.warnMin)) return 1
  return 0
}
const statusText = p => ['正常', '预警', '警报'][statusOf(p)]
const statusTag = p => ['success', 'warning', 'danger'][statusOf(p)]
const statusColor = p => ['#67C23A', '#E6A23C', '#F56C6C'][statusOf(p)]
const statusClass = p => (statusOf(p) === 2 ? 'is-alarm' : statusOf(p) === 1 ? 'is-warn' : '')

const selectPoint = p => {
  selected.value = p
  loadHistory()
}
const isSelected = p => selected.value && selected.value.pointId === p.pointId

const loadHistory = async () => {
  if (!selected.value) return
  const data = await getEnvHistory(selected.value.pointId, hours.value)
  renderChart(data)
}

const renderChart = data => {
  if (!chartRef.value) return
  if (!chart) chart = echarts.init(chartRef.value)
  chart.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 50, right: 20, top: 30, bottom: 30 },
    xAxis: { type: 'time' },
    yAxis: { type: 'value', name: selected.value ? selected.value.unit : '' },
    series: [{
      name: selected.value ? selected.value.pointName : '',
      type: 'line',
      smooth: true,
      showSymbol: false,
      areaStyle: { opacity: 0.15 },
      lineStyle: { width: 2 },
      data: data.map(d => [d.collectTime, Number(d.indexValue)])
    }]
  })
}

const resize = () => chart && chart.resize()

let unsub = null
onMounted(async () => {
  points.value = await getEnvPoints()
  if (points.value.length) {
    selected.value = points.value[0]
    loadHistory()
  }
  window.addEventListener('resize', resize)
  unsub = wsClient.subscribe(data => {
    if (data.env) {
      points.value = data.env
      if (selected.value) {
        const cur = data.env.find(p => p.pointId === selected.value.pointId)
        if (cur && cur.value !== null) {
          const time = new Date().toISOString()
          chart && chart.appendData && chart.appendData({ seriesIndex: 0, data: [[time, Number(cur.value)]] })
        }
      }
    }
  })
})
onUnmounted(() => {
  unsub && unsub()
  window.removeEventListener('resize', resize)
  chart && chart.dispose()
})
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.mt16 { margin-top: 16px; }
.env-card { cursor: pointer; border-top: 3px solid #67C23A; }
.env-card.is-warn { border-top-color: #E6A23C; }
.env-card.is-alarm { border-top-color: #F56C6C; }
.env-head { display: flex; justify-content: space-between; align-items: center; }
.env-name { font-size: 15px; font-weight: 600; }
.env-value { font-size: 30px; font-weight: 700; margin: 10px 0 4px; }
.env-value .unit { font-size: 14px; font-weight: 400; color: #909399; }
.env-sub { font-size: 12px; color: #909399; }
.chart { height: 340px; }
.ml12 { margin-left: 12px; }
</style>
