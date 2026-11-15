<template>
    <div class="monitor-page">
        <section class="hero-card">
            <div>
                <div class="hero-tag">System Monitor</div>
                <h2 class="hero-title">系统监控与配置中心</h2>
                <p class="hero-desc">集中查看前端环境、接口地址、管理员会话和后端关键配置。</p>
            </div>
            <el-button type="primary" class="refresh-btn" @click="refreshMetrics">刷新状态</el-button>
        </section>

        <section class="grid-top">
            <article class="status-card primary">
                <span class="status-label">当前时间</span>
                <strong>{{ metrics.currentTime }}</strong>
                <small>系统本地时间</small>
            </article>
            <article class="status-card">
                <span class="status-label">网络状态</span>
                <strong>{{ metrics.networkStatus }}</strong>
                <small>{{ metrics.connectionHint }}</small>
            </article>
            <article class="status-card">
                <span class="status-label">管理员会话</span>
                <strong>{{ metrics.adminSession }}</strong>
                <small>{{ metrics.adminName }}</small>
            </article>
            <article class="status-card">
                <span class="status-label">视口尺寸</span>
                <strong>{{ metrics.viewport }}</strong>
                <small>{{ metrics.deviceHint }}</small>
            </article>
        </section>

        <section class="monitor-grid">
            <article class="panel-card">
                <div class="panel-head">
                    <h3>接口与环境</h3>
                    <span>Frontend</span>
                </div>
                <div class="kv-list">
                    <div class="kv-item">
                        <span>运行模式</span>
                        <strong>{{ config.runtime.mode }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>页面来源</span>
                        <strong>{{ config.runtime.origin }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>API 基地址</span>
                        <strong>{{ config.runtime.apiBase }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>上传地址</span>
                        <strong>{{ config.runtime.uploadEndpoint }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>withCredentials</span>
                        <strong>已启用</strong>
                    </div>
                </div>
            </article>

            <article class="panel-card">
                <div class="panel-head">
                    <h3>后端关键配置</h3>
                    <span>Backend</span>
                </div>
                <div class="kv-list">
                    <div class="kv-item">
                        <span>服务地址</span>
                        <strong>{{ config.backend.baseUrl }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>数据库</span>
                        <strong>{{ config.backend.database }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>时区</span>
                        <strong>{{ config.backend.timezone }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>上传限制</span>
                        <strong>{{ config.backend.uploadLimit }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>文件目录</span>
                        <strong>{{ config.backend.filePath }}</strong>
                    </div>
                </div>
            </article>

            <article class="panel-card">
                <div class="panel-head">
                    <h3>浏览器与终端</h3>
                    <span>Client</span>
                </div>
                <div class="kv-list">
                    <div class="kv-item">
                        <span>语言</span>
                        <strong>{{ config.client.language }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>平台</span>
                        <strong>{{ config.client.platform }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>User Agent</span>
                        <strong class="multiline">{{ config.client.userAgent }}</strong>
                    </div>
                </div>
            </article>

            <article class="panel-card">
                <div class="panel-head">
                    <h3>会话与诊断</h3>
                    <span>Session</span>
                </div>
                <div class="kv-list">
                    <div class="kv-item">
                        <span>管理员名称</span>
                        <strong>{{ metrics.adminName }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>登录标记</span>
                        <strong>{{ config.session.loginFlag }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>当前路由</span>
                        <strong>{{ config.session.route }}</strong>
                    </div>
                    <div class="kv-item">
                        <span>最后刷新</span>
                        <strong>{{ metrics.lastRefresh }}</strong>
                    </div>
                </div>
            </article>
        </section>
    </div>
</template>

<script>
const runtimeApiBase = import.meta.env.DEV
    ? '/api'
    : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080');

export default {
    name: 'SystemMonitor',
    data() {
        return {
            timer: null,
            metrics: {
                currentTime: '',
                lastRefresh: '',
                networkStatus: '',
                connectionHint: '',
                adminSession: '',
                adminName: '',
                viewport: '',
                deviceHint: ''
            },
            config: {
                runtime: {
                    mode: import.meta.env.MODE,
                    origin: '',
                    apiBase: runtimeApiBase,
                    uploadEndpoint: `${runtimeApiBase}/file`
                },
                backend: {
                    baseUrl: 'http://localhost:8080',
                    database: 'MySQL / second_hand_trading @ localhost:3306',
                    timezone: 'GMT+8 / yyyy-MM-dd HH:mm:ss',
                    uploadLimit: '200MB',
                    filePath: 'xmtp 文件目录'
                },
                client: {
                    language: '',
                    platform: '',
                    userAgent: ''
                },
                session: {
                    loginFlag: '',
                    route: ''
                }
            }
        };
    },
    mounted() {
        this.refreshMetrics();
        this.timer = window.setInterval(this.updateClock, 1000);
        window.addEventListener('resize', this.updateViewport);
        window.addEventListener('online', this.updateNetworkStatus);
        window.addEventListener('offline', this.updateNetworkStatus);
    },
    beforeUnmount() {
        if (this.timer) {
            window.clearInterval(this.timer);
            this.timer = null;
        }
        window.removeEventListener('resize', this.updateViewport);
        window.removeEventListener('online', this.updateNetworkStatus);
        window.removeEventListener('offline', this.updateNetworkStatus);
    },
    methods: {
        formatDate(date = new Date()) {
            const pad = value => String(value).padStart(2, '0');
            return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`;
        },
        updateClock() {
            this.metrics.currentTime = this.formatDate();
        },
        updateViewport() {
            const width = window.innerWidth;
            const height = window.innerHeight;
            let deviceHint = 'Desktop';
            if (width < 768) {
                deviceHint = 'Mobile';
            } else if (width < 1024) {
                deviceHint = 'Tablet';
            }

            this.metrics.viewport = `${width} x ${height}`;
            this.metrics.deviceHint = deviceHint;
        },
        updateNetworkStatus() {
            this.metrics.networkStatus = navigator.onLine ? '在线' : '离线';
            this.metrics.connectionHint = navigator.onLine ? '浏览器网络连接正常' : '浏览器当前处于离线状态';
        },
        refreshMetrics() {
            this.updateClock();
            this.metrics.lastRefresh = this.formatDate();
            this.updateViewport();
            this.updateNetworkStatus();
            this.metrics.adminSession = this.$sta.isLogin ? '有效' : '失效';
            this.metrics.adminName = this.$sta.adminName || sessionStorage.getItem('admin_name') || '未登录';

            this.config.runtime.origin = window.location.origin;
            this.config.client.language = navigator.language || 'unknown';
            this.config.client.platform = navigator.platform || 'unknown';
            this.config.client.userAgent = navigator.userAgent;
            this.config.session.loginFlag = sessionStorage.getItem('admin_is_login') === '1' ? '1' : '0';
            this.config.session.route = this.$route.fullPath;
        }
    }
};
</script>

<style scoped>
.monitor-page {
    display: flex;
    flex-direction: column;
    gap: 24px;
}

.hero-card {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 28px 32px;
    border-radius: 28px;
    background: linear-gradient(135deg, #ffffff 0%, #f5f7ff 100%);
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 20px 40px rgba(15, 23, 42, 0.06);
}

.hero-tag {
    display: inline-flex;
    align-items: center;
    padding: 6px 12px;
    border-radius: 999px;
    background: #eef2ff;
    color: #4f46e5;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
}

.hero-title {
    margin: 14px 0 8px;
    font-size: 30px;
    font-weight: 800;
    color: #0f172a;
}

.hero-desc {
    margin: 0;
    color: #64748b;
    font-size: 14px;
}

.refresh-btn {
    height: 44px;
    padding: 0 24px !important;
    border-radius: 14px !important;
}

.grid-top {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 18px;
}

.status-card {
    padding: 22px 24px;
    border-radius: 24px;
    background: #fff;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 12px 24px rgba(15, 23, 42, 0.05);
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.status-card.primary {
    background: linear-gradient(135deg, #eef2ff 0%, #ffffff 100%);
}

.status-label {
    color: #64748b;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.status-card strong {
    color: #0f172a;
    font-size: 26px;
    font-weight: 800;
}

.status-card small {
    color: #94a3b8;
    font-size: 12px;
}

.monitor-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 20px;
}

.panel-card {
    padding: 26px;
    border-radius: 28px;
    background: #fff;
    border: 1px solid rgba(226, 232, 240, 0.9);
    box-shadow: 0 12px 24px rgba(15, 23, 42, 0.05);
}

.panel-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 18px;
}

.panel-head h3 {
    margin: 0;
    font-size: 20px;
    font-weight: 800;
    color: #0f172a;
}

.panel-head span {
    padding: 6px 10px;
    border-radius: 999px;
    background: #f8fafc;
    color: #64748b;
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
}

.kv-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.kv-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
    padding: 14px 16px;
    border-radius: 18px;
    background: #f8fafc;
}

.kv-item span {
    color: #64748b;
    font-size: 12px;
    font-weight: 700;
}

.kv-item strong {
    color: #0f172a;
    font-size: 15px;
    font-weight: 700;
    word-break: break-word;
}

.multiline {
    line-height: 1.5;
}

@media (max-width: 1200px) {
    .grid-top {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .monitor-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 768px) {
    .hero-card {
        flex-direction: column;
        align-items: flex-start;
        gap: 16px;
    }

    .grid-top {
        grid-template-columns: 1fr;
    }
}
</style>
