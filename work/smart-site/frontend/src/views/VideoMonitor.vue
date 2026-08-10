<template>
  <div>
    <el-alert type="info" :closable="false" class="mb16"
      title="视频监控：OBS/FFmpeg 推流 → nginx-rtmp 转 HLS → 页面实时播放。支持 1/4/9 分屏与全屏" />

    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span><el-icon><VideoCamera /></el-icon> 实时视频监控</span>
          <div>
            <el-radio-group v-model="layout" size="small" @change="rebuildPlayers">
              <el-radio-button :value="1">单画面</el-radio-button>
              <el-radio-button :value="4">4画面</el-radio-button>
              <el-radio-button :value="9">9画面</el-radio-button>
            </el-radio-group>
            <el-button size="small" class="ml12" @click="toggleFullscreen">
              {{ isFullscreen ? '退出全屏' : '全屏' }}
            </el-button>
            <el-button size="small" type="primary" class="ml12" @click="manageVisible = true">摄像头管理</el-button>
          </div>
        </div>
      </template>

      <!-- 视频网格 -->
      <div class="video-grid" :class="'grid-' + layout" ref="gridRef">
        <div class="video-cell" v-for="(cam, idx) in visibleCams" :key="cam.id">
          <div class="video-title">
            <span>{{ cam.cameraName }}</span>
            <el-tag :type="cam.onlineStatus === 1 ? 'success' : 'danger'" size="small" class="status-tag">
              {{ cam.onlineStatus === 1 ? '在线' : '离线' }}
            </el-tag>
          </div>
          <video v-if="cam.onlineStatus === 1" :ref="el => setVideoRef(el, cam.id)" class="video-el" muted autoplay></video>
          <div v-else class="video-offline">
            <el-icon :size="40"><VideoCameraFilled /></el-icon>
            <p>摄像头离线</p>
          </div>
        </div>
        <!-- 空位补齐 -->
        <div class="video-cell empty-cell" v-for="n in (layout - visibleCams.length)" :key="'empty-' + n">
          <span class="empty-text">无摄像头画面</span>
        </div>
      </div>
    </el-card>

    <!-- 摄像头管理弹窗 -->
    <el-dialog v-model="manageVisible" title="摄像头管理" width="860px">
      <el-form :inline="true" class="mb12">
        <el-form-item label="名称">
          <el-input v-model="form.cameraName" placeholder="摄像头名称" style="width: 160px" />
        </el-form-item>
        <el-form-item label="编码">
          <el-input v-model="form.cameraCode" placeholder="如 CAM-003" style="width: 140px" />
        </el-form-item>
        <el-form-item label="HLS地址">
          <el-input v-model="form.streamUrl" placeholder="http://localhost:8088/hls/cam1.m3u8" style="width: 300px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="addCamera">新增</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="cameras" size="small" border stripe max-height="360">
        <el-table-column prop="cameraCode" label="编码" width="100" />
        <el-table-column prop="cameraName" label="名称" width="140" />
        <el-table-column prop="streamUrl" label="HLS地址" min-width="260" show-overflow-tooltip />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.onlineStatus === 1 ? 'success' : 'danger'" size="small">
              {{ row.onlineStatus === 1 ? '在线' : '离线' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="AI识别" width="180">
          <template #default="{ row }">
            <el-tag v-if="row.aiHelmet === 1" size="small" class="ai-tag">安全帽</el-tag>
            <el-tag v-if="row.aiVest === 1" size="small" class="ai-tag">安全服</el-tag>
            <el-tag v-if="row.aiSmoke === 1" size="small" class="ai-tag">吸烟</el-tag>
            <el-tag v-if="row.aiFire === 1" size="small" class="ai-tag">明火</el-tag>
            <span v-if="!row.aiHelmet && !row.aiVest && !row.aiSmoke && !row.aiFire" class="empty-text">未配置</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" align="center">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="editCamera(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="deleteCamera(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import Hls from 'hls.js'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../api/request'

const layout = ref(4)
const cameras = ref([])
const manageVisible = ref(false)
const isFullscreen = ref(false)
const gridRef = ref()
const videoRefs = {}
const players = []

const visibleCams = computed(() => cameras.value.filter(c => c.enableStatus === 1).slice(0, layout.value))

const setVideoRef = (el, id) => {
  if (el) videoRefs[id] = el
}

const playStream = (cam) => {
  const videoEl = videoRefs[cam.id]
  if (!videoEl || !cam.streamUrl) return
  if (Hls.isSupported()) {
    const hls = new Hls({ liveDurationInfinity: true })
    hls.loadSource(cam.streamUrl)
    hls.attachMedia(videoEl)
    players.push(hls)
    hls.on(Hls.Events.ERROR, (e, data) => {
      if (data.fatal) {
        // 流不存在时静默重试不刷屏
        hls.destroy()
      }
    })
  } else if (videoEl.canPlayType('application/vnd.apple.mpegurl')) {
    videoEl.src = cam.streamUrl
  }
}

const rebuildPlayers = async () => {
  // 销毁旧播放器
  players.forEach(p => p.destroy())
  players.length = 0
  Object.keys(videoRefs).forEach(k => delete videoRefs[k])
  await nextTick()
  visibleCams.value.forEach(cam => playStream(cam))
}

const toggleFullscreen = () => {
  if (!document.fullscreenElement) {
    gridRef.value.requestFullscreen()
    isFullscreen.value = true
  } else {
    document.exitFullscreen()
    isFullscreen.value = false
  }
}

// 摄像头管理
const form = ref({})
const addCamera = async () => {
  if (!form.value.cameraName || !form.value.cameraCode) {
    ElMessage.warning('请填写名称和编码')
    return
  }
  await request.post('/camera', form.value)
  ElMessage.success('新增成功')
  form.value = {}
  loadCameras()
}
const editCamera = async row => {
  const { value } = await ElMessageBox.prompt('HLS 播放地址', '编辑 ' + row.cameraName, {
    inputValue: row.streamUrl, inputPlaceholder: 'http://localhost:8088/hls/xxx.m3u8'
  })
  row.streamUrl = value
  await request.put(`/camera/${row.id}`, row)
  ElMessage.success('已更新，重新加载播放器')
  loadCameras()
}
const deleteCamera = async row => {
  await ElMessageBox.confirm(`确定删除摄像头「${row.cameraName}」吗？`, '提示', { type: 'warning' })
  await request.delete(`/camera/${row.id}`)
  ElMessage.success('已删除')
  loadCameras()
}

const loadCameras = async () => {
  cameras.value = await request.get('/camera/list')
  rebuildPlayers()
}

const onFullscreenChange = () => { isFullscreen.value = !!document.fullscreenElement }

onMounted(async () => {
  await loadCameras()
  document.addEventListener('fullscreenchange', onFullscreenChange)
})
onUnmounted(() => {
  players.forEach(p => p.destroy())
  document.removeEventListener('fullscreenchange', onFullscreenChange)
})
</script>

<style scoped>
.mb16 { margin-bottom: 16px; }
.ml12 { margin-left: 12px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.video-grid { display: grid; gap: 8px; background: #0a0f1a; padding: 8px; border-radius: 6px; }
.grid-1 { grid-template-columns: 1fr; }
.grid-4 { grid-template-columns: 1fr 1fr; }
.grid-9 { grid-template-columns: 1fr 1fr 1fr; }
.video-cell { position: relative; background: #000; border-radius: 4px; overflow: hidden; aspect-ratio: 16/9; }
.video-title {
  position: absolute; top: 0; left: 0; right: 0; z-index: 10;
  display: flex; justify-content: space-between; align-items: center;
  padding: 6px 10px; background: linear-gradient(180deg, #000c, transparent);
  color: #fff; font-size: 13px;
}
.status-tag { transform: scale(0.85); }
.video-el { width: 100%; height: 100%; object-fit: cover; }
.video-offline {
  height: 100%; display: flex; flex-direction: column;
  align-items: center; justify-content: center; color: #556;
}
.video-offline p { margin-top: 8px; font-size: 13px; }
.empty-cell { display: flex; align-items: center; justify-content: center; background: #0d1320; }
.empty-text { color: #556; font-size: 13px; }
.mb12 { margin-bottom: 12px; }
.ai-tag { margin-right: 4px; }
</style>
