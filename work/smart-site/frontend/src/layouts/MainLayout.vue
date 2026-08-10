<template>
  <el-container class="layout">
    <!-- 左侧菜单 -->
    <el-aside width="220px" class="aside">
      <div class="logo">
        <el-icon :size="26" color="#409EFF"><Monitor /></el-icon>
        <span>智慧工地监控平台</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#001529"
        text-color="#c0c4cc"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/home">
          <el-icon><HomeFilled /></el-icon>
          <span>首页/工作台</span>
        </el-menu-item>
        <el-menu-item index="/device">
          <el-icon><Monitor /></el-icon>
          <span>设备资产管理</span>
        </el-menu-item>
        <el-menu-item index="/crane">
          <el-icon><Platform /></el-icon>
          <span>塔吊监控</span>
        </el-menu-item>
        <el-menu-item index="/lift">
          <el-icon><Odometer /></el-icon>
          <span>升降机监控</span>
        </el-menu-item>
        <el-menu-item index="/env">
          <el-icon><Sunny /></el-icon>
          <span>环境监测</span>
        </el-menu-item>
        <el-menu-item index="/video">
          <el-icon><VideoCamera /></el-icon>
          <span>视频监控</span>
        </el-menu-item>
        <el-menu-item index="/ai">
          <el-icon><Aim /></el-icon>
          <span>AI智能识别</span>
        </el-menu-item>
        <el-menu-item index="/alarm">
          <el-icon><Bell /></el-icon>
          <span>告警管理</span>
        </el-menu-item>
        <el-menu-item index="/screen">
          <el-icon><DataBoard /></el-icon>
          <span>数据大屏</span>
        </el-menu-item>
        <el-sub-menu index="more">
          <template #title>
            <el-icon><Aim /></el-icon>
            <span>更多功能（开发中）</span>
          </template>
          <el-menu-item index="/video" disabled>视频监控</el-menu-item>
          <el-menu-item index="/ai" disabled>AI智能识别</el-menu-item>
          <el-menu-item index="/spray" disabled>喷淋降尘</el-menu-item>
          <el-menu-item index="/three" disabled>3D可视化</el-menu-item>
          <el-menu-item index="/coze" disabled>Coze智能体</el-menu-item>
        </el-sub-menu>
      </el-menu>
    </el-aside>

    <el-container>
      <!-- 顶栏 -->
      <el-header class="header">
        <div class="header-title">{{ currentTitle }}</div>
        <div class="header-right">
          <el-tag v-if="roles.length" size="small" type="success" class="role-tag">
            {{ roleName }}
          </el-tag>
          <el-dropdown @command="handleCommand">
            <span class="user-name">
              <el-icon><User /></el-icon>
              {{ userInfo.realName || userInfo.username }}
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 内容区 -->
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()

const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
const roles = userInfo.roles || []

const roleName = computed(() => {
  const map = { ADMIN: '系统管理员', LEADER: '项目经理', SAFETY: '安全管理员' }
  return roles.map(r => map[r] || r).join(' / ')
})

const activeMenu = computed(() => route.path)
const currentTitle = computed(() => route.meta.title || '')

const handleCommand = command => {
  if (command === 'logout') {
    ElMessageBox.confirm('确定退出登录吗？', '提示', { type: 'warning' })
      .then(() => {
        localStorage.removeItem('token')
        localStorage.removeItem('userInfo')
        router.push('/login')
      })
      .catch(() => {})
  }
}
</script>

<style scoped>
.layout { height: 100%; }
.aside { background-color: #001529; overflow-x: hidden; }
.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  color: #fff;
  font-size: 15px;
  font-weight: 600;
  border-bottom: 1px solid #ffffff1a;
}
.aside :deep(.el-menu) { border-right: none; }
.header {
  background: #fff;
  border-bottom: 1px solid #e8e8e8;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.header-title { font-size: 16px; font-weight: 600; color: #303133; }
.header-right { display: flex; align-items: center; gap: 12px; }
.user-name {
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #303133;
  outline: none;
}
.main { background: #f0f2f5; }
</style>
