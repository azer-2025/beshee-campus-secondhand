<template>
  <div class="monitor-page">
    <div class="hero premium-card">
      <div>
        <h2 class="page-title">系统监控</h2>
        <p class="page-subtitle">查看系统配置、运行环境和核心资源指标。</p>
      </div>
      <el-button type="primary" round @click="loadData">刷新配置</el-button>
    </div>

    <div class="stats-grid">
      <div class="stat-card premium-card">
        <span class="stat-label">总订单数</span>
        <strong>{{ trading.totalOrders ?? 0 }}</strong>
      </div>
      <div class="stat-card premium-card">
        <span class="stat-label">总交易额</span>
        <strong>¥{{ trading.totalAmount ?? 0 }}</strong>
      </div>
      <div class="stat-card premium-card">
        <span class="stat-label">总用户数</span>
        <strong>{{ users.totalUsers ?? 0 }}</strong>
      </div>
      <div class="stat-card premium-card">
        <span class="stat-label">活跃用户</span>
        <strong>{{ users.activeUsers ?? 0 }}</strong>
      </div>
    </div>

    <div class="config-layout" v-loading="loading">
      <div class="config-card premium-card">
        <h3>系统配置</h3>
        <div class="config-list">
          <div v-for="item in configItems" :key="item.label" class="config-row">
            <span class="config-label">{{ item.label }}</span>
            <span class="config-value">{{ item.value }}</span>
          </div>
        </div>
      </div>

      <div class="config-card premium-card">
        <h3>运行资源</h3>
        <div class="config-list">
          <div v-for="item in runtimeItems" :key="item.label" class="config-row">
            <span class="config-label">{{ item.label }}</span>
            <span class="config-value">{{ item.value }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SystemMonitor',
  data() {
    return {
      loading: false,
      systemConfig: {},
      trading: {},
      users: {},
    };
  },
  computed: {
    configItems() {
      return [
        { label: '应用名称', value: this.systemConfig.appName || '-' },
        { label: '服务端口', value: this.systemConfig.serverPort || '-' },
        { label: '基础地址', value: this.systemConfig.baseUrl || '-' },
        { label: '数据库连接', value: this.systemConfig.datasource || '-' },
        { label: '时区', value: this.systemConfig.timezone || '-' },
        { label: '启动时间', value: this.systemConfig.startTime || '-' },
        { label: '运行目录', value: this.systemConfig.userDir || '-' },
      ];
    },
    runtimeItems() {
      return [
        { label: 'Java 版本', value: this.systemConfig.javaVersion || '-' },
        { label: 'Java 供应商', value: this.systemConfig.javaVendor || '-' },
        { label: '操作系统', value: this.systemConfig.osName || '-' },
        { label: '系统架构', value: this.systemConfig.osArch || '-' },
        { label: 'CPU 核心数', value: this.systemConfig.availableProcessors ?? '-' },
        { label: '运行时长（分钟）', value: this.systemConfig.uptimeMinutes ?? '-' },
        { label: '最大内存（MB）', value: this.systemConfig.maxMemoryMb ?? '-' },
        { label: '已分配内存（MB）', value: this.systemConfig.totalMemoryMb ?? '-' },
        { label: '空闲内存（MB）', value: this.systemConfig.freeMemoryMb ?? '-' },
      ];
    },
  },
  created() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      Promise.all([
        this.$api.getSystemConfig(),
        this.$api.getTradingData(),
        this.$api.getUserStatistics(),
      ])
        .then(([configRes, tradingRes, userRes]) => {
          if (configRes.status_code === 1) {
            this.systemConfig = configRes.data || {};
          }
          if (tradingRes.status_code === 1) {
            this.trading = tradingRes.data || {};
          }
          if (userRes.status_code === 1) {
            this.users = userRes.data || {};
          }
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
};
</script>

<style scoped>
.monitor-page {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.hero {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-title {
  font-size: 28px;
  font-weight: 800;
  color: var(--text-primary);
}

.page-subtitle {
  margin-top: 6px;
  color: var(--text-tertiary);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 16px;
}

.stat-card {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.stat-label {
  font-size: 13px;
  color: var(--text-tertiary);
}

.stat-card strong {
  font-size: 28px;
  color: var(--brand-primary);
}

.config-layout {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}

.config-card h3 {
  margin-bottom: 18px;
  font-size: 18px;
  font-weight: 800;
  color: var(--text-primary);
}

.config-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.config-row {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid #eef2f7;
}

.config-label {
  min-width: 110px;
  color: var(--text-secondary);
}

.config-value {
  color: var(--text-primary);
  text-align: right;
  word-break: break-all;
}

@media (max-width: 1024px) {
  .stats-grid,
  .config-layout {
    grid-template-columns: 1fr;
  }

  .hero {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}
</style>
