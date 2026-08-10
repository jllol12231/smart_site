import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/',
    component: () => import('../layouts/MainLayout.vue'),
    redirect: '/home',
    children: [
      {
        path: 'home',
        name: 'Home',
        component: () => import('../views/Home.vue'),
        meta: { title: '首页/工作台' }
      },
      {
        path: 'device',
        name: 'DeviceList',
        component: () => import('../views/DeviceList.vue'),
        meta: { title: '设备资产管理' }
      },
      {
        path: 'crane',
        name: 'CraneMonitor',
        component: () => import('../views/CraneMonitor.vue'),
        meta: { title: '塔吊监控' }
      },
      {
        path: 'lift',
        name: 'LiftMonitor',
        component: () => import('../views/LiftMonitor.vue'),
        meta: { title: '升降机监控' }
      },
      {
        path: 'env',
        name: 'EnvMonitor',
        component: () => import('../views/EnvMonitor.vue'),
        meta: { title: '环境监测' }
      },
      {
        path: 'video',
        name: 'VideoMonitor',
        component: () => import('../views/VideoMonitor.vue'),
        meta: { title: '视频监控' }
      },
      {
        path: 'ai',
        name: 'AiAlarm',
        component: () => import('../views/AiAlarm.vue'),
        meta: { title: 'AI智能识别' }
      },
      {
        path: 'alarm',
        name: 'AlarmManage',
        component: () => import('../views/AlarmManage.vue'),
        meta: { title: '告警管理' }
      },
      {
        path: 'screen',
        name: 'DataScreen',
        component: () => import('../views/DataScreen.vue'),
        meta: { title: '数据大屏' }
      }
    ]
  },
  { path: '/:pathMatch(.*)*', redirect: '/home' }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫：未登录跳转登录页
router.beforeEach((to, from, next) => {
  document.title = (to.meta.title ? to.meta.title + ' - ' : '') + '建筑安全智能监控平台'
  const token = localStorage.getItem('token')
  if (to.path !== '/login' && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router
