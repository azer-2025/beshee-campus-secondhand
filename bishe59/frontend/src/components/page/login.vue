<template>
  <div class="login-container">
    <div class="aurora-bg">
      <div class="aurora-item"></div>
      <div class="aurora-item"></div>
      <div class="aurora-item"></div>
    </div>

    <div class="login-split-wrapper">
      <div class="brand-side">
        <div class="brand-content">
          <div class="logo-circle">
            <i class="el-icon-mobile-phone"></i>
          </div>
          <h1 class="brand-slogan">
            发现靠谱的<br/>
            <span>二手手机</span>
          </h1>
          <p class="brand-sub">
            二手手机交易平台 - 超过 15,000+ 用户在这里买卖二手手机
          </p>
          <div class="scroll-down">
            <div class="mouse"></div>
            <span>TRADE WITH CONFIDENCE</span>
          </div>
        </div>
        <div class="deco-ball ball-1"></div>
        <div class="deco-ball ball-2"></div>
      </div>

      <div class="form-side">
        <div class="login-card-v2">
          <div class="form-header">
            <h2>欢迎回来</h2>
            <p>输入你的账号，继续浏览你想买的手机</p>
          </div>

          <el-form :model="userForm" class="login-form">
            <div class="input-group">
              <label>账号 / 手机号</label>
              <el-input
                v-model="userForm.accountNumber"
                placeholder="请输入账号"
                class="trendy-input">
                <template #prefix><i class="el-icon-user"></i></template>
              </el-input>
            </div>

            <div class="input-group">
              <label>密码</label>
              <el-input
                v-model="userForm.userPassword"
                type="password"
                placeholder="请输入密码"
                show-password
                @keyup.enter="login"
                class="trendy-input">
                <template #prefix><i class="el-icon-lock"></i></template>
              </el-input>
            </div>

            <div class="form-options">
              <el-checkbox v-model="rememberMe">记住我</el-checkbox>
              <span class="forgot-pwd">忘记密码？</span>
            </div>

            <el-button type="primary" class="btn-login-v2" @click="login">
              立即进入 二手手机交易平台
            </el-button>

            <div class="form-footer">
              <span>还没有账号？</span>
              <router-link to="/sign-in" class="reg-link">立即注册</router-link>
            </div>

            <div class="admin-portal">
              <router-link to="/login-admin">管理员入口 <i class="el-icon-right"></i></router-link>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'login',
  data() {
    return {
      userForm: { accountNumber: '', userPassword: '' },
      rememberMe: false
    };
  },
  methods: {
    login() {
      if (!this.userForm.accountNumber || !this.userForm.userPassword) {
        return this.$message.warning('账号和密码都要填写');
      }
      const loading = this.$loading({ background: 'rgba(255, 255, 255, 0.8)' });
      this.$api.userLogin(this.userForm).then(res => {
        if (res.status_code === 1) {
          res.data.signInTime = res.data.signInTime.substring(0, 10);
          this.$globalData.userInfo = res.data;
          this.$message.success('登录成功');
          this.$router.replace({ path: '/index' });
        } else {
          this.$message.error(res.msg);
        }
      }).finally(() => {
        loading.close();
      });
    }
  }
};
</script>

<style scoped>
.login-container {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  position: relative;
  background: #0f172a;
}

.aurora-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
}

.aurora-item {
  position: absolute;
  width: 800px;
  height: 800px;
  filter: blur(100px);
  opacity: 0.4;
  border-radius: 50%;
  animation: drift 20s infinite alternate;
}

.aurora-item:nth-child(1) {
  background: #6366f1;
  top: -200px;
  left: -200px;
}

.aurora-item:nth-child(2) {
  background: #a855f7;
  bottom: -200px;
  right: -200px;
  animation-delay: -5s;
}

.aurora-item:nth-child(3) {
  background: #ec4899;
  top: 20%;
  left: 30%;
  animation-duration: 25s;
}

@keyframes drift {
  from {
    transform: translate(0, 0) scale(1);
  }

  to {
    transform: translate(100px, 100px) scale(1.2);
  }
}

.login-split-wrapper {
  position: relative;
  z-index: 1;
  display: flex;
  height: 100%;
  width: 100%;
}

.brand-side {
  flex: 6;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 80px;
  position: relative;
}

.brand-content {
  position: relative;
  z-index: 5;
}

.logo-circle {
  width: 80px;
  height: 80px;
  background: white;
  border-radius: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 40px;
  color: #6366f1;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
  margin-bottom: 40px;
}

.brand-slogan {
  font-size: 72px;
  font-weight: 900;
  color: white;
  line-height: 1.1;
  letter-spacing: -2px;
}

.brand-slogan span {
  background: linear-gradient(to right, #818cf8, #f472b6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.brand-sub {
  font-size: 20px;
  color: #94a3b8;
  margin-top: 24px;
  font-weight: 500;
}

.scroll-down {
  margin-top: 80px;
  display: flex;
  align-items: center;
  gap: 12px;
  color: #64748b;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 2px;
}

.mouse {
  width: 20px;
  height: 32px;
  border: 2px solid #64748b;
  border-radius: 10px;
  position: relative;
}

.mouse::after {
  content: '';
  width: 4px;
  height: 8px;
  background: #64748b;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  top: 6px;
  border-radius: 2px;
}

.deco-ball {
  position: absolute;
  border-radius: 50%;
  background: white;
  opacity: 0.05;
}

.ball-1 {
  width: 300px;
  height: 300px;
  top: -50px;
  left: 10%;
}

.ball-2 {
  width: 150px;
  height: 150px;
  bottom: 10%;
  right: 20%;
}

.form-side {
  flex: 4;
  background: rgba(255, 255, 255, 0.03);
  backdrop-filter: blur(40px);
  border-left: 1px solid rgba(255, 255, 255, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.login-card-v2 {
  width: 100%;
  max-width: 420px;
}

.form-header {
  margin-bottom: 40px;
}

.form-header h2 {
  font-size: 32px;
  font-weight: 800;
  color: white;
  margin-bottom: 12px;
}

.form-header p {
  color: #94a3b8;
  font-size: 16px;
}

.input-group {
  margin-bottom: 24px;
}

.input-group label {
  display: block;
  color: #cbd5e1;
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 10px;
}

.trendy-input :deep(.el-input__wrapper) {
  height: 56px;
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 16px !important;
  color: white !important;
  transition: all 0.3s;
}

.trendy-input :deep(.el-input__inner) {
  color: white !important;
}

.trendy-input :deep(.el-input__wrapper.is-focus) {
  background: rgba(255, 255, 255, 0.1) !important;
  border-color: #6366f1 !important;
  box-shadow: 0 0 20px rgba(99, 102, 241, 0.2) !important;
}

.form-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

:deep(.el-checkbox__label) {
  color: #94a3b8 !important;
}

.forgot-pwd {
  color: #6366f1;
  font-size: 14px;
  cursor: pointer;
  font-weight: 600;
}

.btn-login-v2 {
  width: 100%;
  height: 60px;
  font-size: 18px;
  font-weight: 800;
  border-radius: 18px !important;
  background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%) !important;
  border: none !important;
  box-shadow: 0 10px 25px rgba(99, 102, 241, 0.4) !important;
  margin-bottom: 24px;
}

.form-footer {
  text-align: center;
  color: #94a3b8;
  font-size: 15px;
  margin-bottom: 32px;
}

.reg-link {
  color: white;
  font-weight: 800;
  text-decoration: none;
  margin-left: 6px;
}

.admin-portal {
  text-align: center;
  padding-top: 32px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.admin-portal a {
  color: #64748b;
  text-decoration: none;
  font-size: 14px;
  transition: color 0.3s;
}

.admin-portal a:hover {
  color: white;
}

@media (max-width: 1024px) {
  .brand-side {
    display: none;
  }

  .form-side {
    flex: 1;
    background: none;
    border: none;
  }
}
</style>
