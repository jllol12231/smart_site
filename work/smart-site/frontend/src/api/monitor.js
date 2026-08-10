import request from './request'

// ============ 塔吊监控 ============
export const getCraneList = () => request.get('/crane/list')
export const getCraneDetail = id => request.get(`/crane/${id}`)

// ============ 升降机监控 ============
export const getLiftList = () => request.get('/lift/list')
export const getLiftDetail = id => request.get(`/lift/${id}`)

// ============ 环境监测 ============
export const getEnvPoints = () => request.get('/env/points')
export const getEnvHistory = (pointId, hours = 24) => request.get('/env/history', { params: { pointId, hours } })

// ============ 告警管理 ============
export const getAlarmList = params => request.get('/alarm/list', { params })
export const handleAlarm = (id, data) => request.put(`/alarm/${id}/handle`, data)
export const getAlarmStats = () => request.get('/alarm/stats')

// ============ 数据大屏 / 首页 ============
export const getDashboardStats = () => request.get('/dashboard/stats')
export const getDashboardOverview = () => request.get('/dashboard/overview')
