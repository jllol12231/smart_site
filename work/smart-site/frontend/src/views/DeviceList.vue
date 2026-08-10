<template>
  <el-card shadow="never">
    <template #header>
      <div class="card-header">
        <span><el-icon><Monitor /></el-icon> 设备台账列表</span>
        <div>
          <el-input
            v-model="keyword"
            placeholder="搜索设备名称/编码"
            clearable
            style="width: 240px"
            @input="loadList"
          />
          <el-select v-model="statusFilter" placeholder="运行状态" clearable style="width: 130px; margin-left: 8px" @change="loadList">
            <el-option label="在线" :value="1" />
            <el-option label="离线" :value="0" />
          </el-select>
        </div>
      </div>
    </template>

    <el-table :data="filteredList" v-loading="loading" border stripe>
      <el-table-column prop="deviceCode" label="设备编码" width="110" />
      <el-table-column prop="deviceName" label="设备名称" min-width="140" />
      <el-table-column prop="brand" label="品牌" width="100" />
      <el-table-column prop="model" label="型号" width="110" />
      <el-table-column prop="remark" label="安装位置/备注" min-width="160" show-overflow-tooltip />
      <el-table-column label="运行状态" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
            {{ row.status === 1 ? '在线' : '离线' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="启用状态" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.enableStatus === 1 ? 'primary' : 'info'" size="small">
            {{ row.enableStatus === 1 ? '启用' : '禁用' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="170" />
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import request from '../api/request'

const list = ref([])
const loading = ref(false)
const keyword = ref('')
const statusFilter = ref(null)

const filteredList = computed(() => {
  let result = list.value
  if (statusFilter.value !== null && statusFilter.value !== '') {
    result = result.filter(d => d.status === statusFilter.value)
  }
  if (keyword.value) {
    const k = keyword.value.toLowerCase()
    result = result.filter(d =>
      (d.deviceName || '').toLowerCase().includes(k) ||
      (d.deviceCode || '').toLowerCase().includes(k)
    )
  }
  return result
})

const loadList = async () => {
  loading.value = true
  try {
    list.value = await request.get('/device/list')
  } finally {
    loading.value = false
  }
}

onMounted(loadList)
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
