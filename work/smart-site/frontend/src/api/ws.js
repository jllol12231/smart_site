/**
 * WebSocket 实时数据客户端
 * 连接 ws://localhost:8080/ws，自动重连，消息分发到订阅者
 */
class WsClient {
  constructor() {
    this.ws = null
    this.subscribers = []
    this.reconnectTimer = null
    this.reconnectCount = 0
  }

  connect() {
    const proto = location.protocol === 'https:' ? 'wss' : 'ws'
    this.ws = new WebSocket(`${proto}://${location.hostname}:8080/ws`)

    this.ws.onopen = () => {
      console.log('[WS] 已连接')
      this.reconnectCount = 0
    }

    this.ws.onmessage = e => {
      try {
        const data = JSON.parse(e.data)
        this.subscribers.forEach(fn => {
          try { fn(data) } catch (err) { console.error(err) }
        })
      } catch (err) {
        console.error('[WS] 消息解析失败', err)
      }
    }

    this.ws.onclose = () => {
      console.log('[WS] 连接断开，准备重连')
      // 指数退避重连：2s → 4s → 8s ... 最长 30s
      const delay = Math.min(2000 * Math.pow(2, this.reconnectCount), 30000)
      this.reconnectCount++
      clearTimeout(this.reconnectTimer)
      this.reconnectTimer = setTimeout(() => this.connect(), delay)
    }

    this.ws.onerror = () => this.ws && this.ws.close()
  }

  /** 订阅实时消息，返回取消订阅函数 */
  subscribe(fn) {
    this.subscribers.push(fn)
    return () => {
      this.subscribers = this.subscribers.filter(f => f !== fn)
    }
  }
}

// 单例，页面引入即自动连接
const wsClient = new WsClient()
wsClient.connect()

export default wsClient
