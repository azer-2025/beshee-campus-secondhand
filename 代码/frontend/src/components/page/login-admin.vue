<template>
  <div class="admin-login-container">
    <div class="mesh-bg">
      <div class="mesh-ball ball-1"></div>
      <div class="mesh-ball ball-2"></div>
      <div class="mesh-ball ball-3"></div>
    </div>

    <div class="login-glass-card">
      <div class="login-inner">
        <div class="login-header">
          <div class="app-logo">
            <i class="el-icon-mobile-phone"></i>
          </div>
          <h1 class="login-title">手机平台后台<span>ADMIN</span></h1>
          <p class="login-subtitle">登录管理员账号以访问二手手机交易平台控制台</p>
        </div>

        <el-form :model="adminForm" class="premium-form">
          <div class="form-item-group">
            <label>管理员账号</label>
            <el-input
              v-model="adminForm.accountNumber"
              placeholder="Administrator Account"
              class="premium-input">
              <template #prefix><i class="el-icon-user"></i></template>
            </el-input>
          </div>

          <div class="form-item-group">
            <label>访问密钥</label>
            <el-input
              v-model="adminForm.adminPassword"
              type="password"
              placeholder="Enter Access Key"
              show-password
              @keyup.enter="login"
              class="premium-input">
              <template #prefix><i class="el-icon-lock"></i></template>
            </el-input>
          </div>

          <div class="login-footer-actions">
            <el-button type="primary" class="btn-login-gradient" @click="login">
              确认授权登录
            </el-button>
            <div class="secondary-link">
              <router-link to="/login">
                <i class="el-icon-back"></i> 返回手机平台前台
              </router-link>
            </div>
          </div>
        </el-form>
      </div>

      <div class="card-footer-info">
        <div class="security-status">
          <span class="dot pulse"></span>
          <span>SSL 加密连接已开启</span>
        </div>
        <span class="version-tag">V5.0.0</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'login-admin',
  data() {
    return {
      adminForm: { accountNumber: '', adminPassword: '' }
    };
  },
  methods: {
    login() {
      if (!this.adminForm.accountNumber || !this.adminForm.adminPassword) {
        return this.$message.warning('请提供有效的管理员凭证');
      }
      const loading = this.$loading({
        lock: true,
        text: '正在校验管理员身份...',
        background: 'rgba(255, 255, 255, 0.8)'
      });

      this.$api.adminLogin(this.adminForm).then(res => {
        if (res.status_code === 1) {
          this.$globalData.adminInfo = res.data;
          this.$sta.isLogin = true;
          this.$sta.adminName = res.data.adminName || '';
          sessionStorage.setItem('admin_is_login', '1');
          sessionStorage.setItem('admin_name', res.data.adminName || '');
          this.$message.success('授权成功，正在进入控制台');
          this.$router.replace({ path: '/platform-admin' });
        } else {
          this.$message.error(res.msg || '身份验证失败');
        }
      }).finally(() => {
        loading.close();
      });
    }
  }
};
</script>

<style scoped>
.admin-login-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #f8fafc;
  overflow: hidden;
  position: relative;
}

.mesh-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  filter: blur(80px);
}

.mesh-ball {
  position: absolute;
  border-radius: 50%;
  opacity: 0.4;
}

.ball-1 {
  width: 40%;
  height: 60%;
  background: #6366f1;
  top: -10%;
  left: -10%;
  animation: move 20s infinite alternate;
}

.ball-2 {
  width: 50%;
  height: 50%;
  background: #a855f7;
  bottom: -10%;
  right: -10%;
  animation: move 25s infinite alternate-reverse;
}

.ball-3 {
  width: 30%;
  height: 40%;
  background: #ec4899;
  top: 20%;
  right: 20%;
  animation: move 15s infinite alternate;
}

@keyframes move {
  from {
    transform: translate(0, 0);
  }

  to {
    transform: translate(100px, 100px);
  }
}

.login-glass-card {
  width: 460px;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.8);
  border-radius: var(--radius-xl);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.1);
  z-index: 1;
  overflow: hidden;
}

.login-inner {
  padding: 56px 48px;
}

.login-header {
  text-align: center;
  margin-bottom: 40px;
}

.app-logo {
  width: 56px;
  height: 56px;
  background: var(--brand-gradient);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: white;
  margin: 0 auto 20px;
  box-shadow: 0 8px 16px rgba(99, 102, 241, 0.25);
}

.login-title {
  font-size: 26px;
  font-weight: 800;
  color: var(--text-primary);
  letter-spacing: -0.02em;
}

.login-title span {
  font-size: 11px;
  font-weight: 700;
  color: #6366f1;
  background: rgba(99, 102, 241, 0.1);
  padding: 2px 8px;
  border-radius: 4px;
  margin-left: 8px;
  vertical-align: middle;
}

.login-subtitle {
  color: var(--text-tertiary);
  font-size: 14px;
  margin-top: 8px;
}

.form-item-group {
  margin-bottom: 24px;
}

.form-item-group label {
  display: block;
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  margin-bottom: 10px;
  letter-spacing: 0.05em;
}

.premium-input :deep(.el-input__wrapper) {
  height: 48px;
  background: white !important;
  border-radius: var(--radius-md) !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: none !important;
}

.premium-input :deep(.el-input__wrapper.is-focus) {
  border-color: var(--brand-primary) !important;
  box-shadow: 0 0 0 4px var(--brand-primary-light) !important;
}

.login-footer-actions {
  margin-top: 32px;
}

.btn-login-gradient {
  width: 100%;
  height: 52px;
  font-size: 15px;
  font-weight: 700;
  border-radius: var(--radius-md) !important;
  background: var(--brand-gradient) !important;
  border: none !important;
  box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.3) !important;
  margin-bottom: 20px;
}

.btn-login-gradient:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 20px -3px rgba(99, 102, 241, 0.4) !important;
}

.secondary-link {
  text-align: center;
}

.secondary-link a {
  color: var(--text-tertiary);
  text-decoration: none;
  font-size: 13px;
  font-weight: 600;
  transition: color 0.3s;
}

.secondary-link a:hover {
  color: var(--brand-primary);
}

.card-footer-info {
  background: rgba(248, 250, 252, 0.5);
  padding: 16px 48px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #f1f5f9;
}

.security-status {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #94a3b8;
  font-size: 11px;
  font-weight: 600;
}

.dot {
  width: 6px;
  height: 6px;
  background: #10b981;
  border-radius: 50%;
}

.pulse {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% {
    box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4);
  }

  70% {
    box-shadow: 0 0 0 10px rgba(16, 185, 129, 0);
  }

  100% {
    box-shadow: 0 0 0 0 rgba(16, 185, 129, 0);
  }
}

.version-tag {
  color: #cbd5e1;
  font-size: 10px;
  font-weight: 800;
  font-family: monospace;
}
</style>
