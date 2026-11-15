<template>
  <div class="signin-container">
    <!-- 背景流光特效 (继承自登录页) -->
    <div class="aurora-bg">
      <div class="aurora-item"></div>
      <div class="aurora-item"></div>
      <div class="aurora-item"></div>
    </div>

    <div class="split-wrapper">
      <!-- 左侧：品牌展示区 -->
      <div class="brand-side">
        <div class="brand-content">
          <div class="icon-stack">
            <div class="stack-item item-1"><i class="el-icon-user"></i></div>
            <div class="stack-item item-2"><i class="el-icon-star-on"></i></div>
          </div>
          <h1 class="brand-slogan">
            加入我们<br/>
            <span>创造你的主场</span>
          </h1>
          <p class="brand-sub">
            注册成为 Hub 成员，即刻开启校园二手交易新体验
          </p>
          <div class="feature-list">
            <div class="feature-item"><i class="el-icon-circle-check"></i> 极速交易</div>
            <div class="feature-item"><i class="el-icon-circle-check"></i> 校友实名</div>
            <div class="feature-item"><i class="el-icon-circle-check"></i> 安全保障</div>
          </div>
        </div>
        <!-- 装饰性元素 -->
        <div class="deco-mesh"></div>
      </div>

      <!-- 右侧：注册操作区 -->
      <div class="form-side">
        <div class="signin-card">
          <div class="form-header">
            <h2>创建新账号 ✨</h2>
            <p>填写基本信息，加入 1.5w+ 校友社区</p>
          </div>

          <el-form :model="userInfo" class="signin-form">
            <div class="form-row">
              <div class="input-group">
                <label>如何称呼你</label>
                <el-input 
                  v-model="userInfo.nickname" 
                  placeholder="请输入个性昵称"
                  maxlength="30"
                  class="trendy-input">
                  <template #prefix><i class="el-icon-magic-stick"></i></template>
                </el-input>
              </div>
            </div>

            <div class="form-row">
              <div class="input-group">
                <label>联系手机 (登录账号)</label>
                <el-input 
                  v-model="userInfo.accountNumber" 
                  placeholder="请输入11位手机号"
                  maxlength="11"
                  class="trendy-input">
                  <template #prefix><i class="el-icon-phone"></i></template>
                </el-input>
              </div>
            </div>
            
            <div class="form-row split">
              <div class="input-group">
                <label>设置密码</label>
                <el-input 
                  v-model="userInfo.userPassword" 
                  type="password" 
                  placeholder="密码"
                  show-password
                  class="trendy-input">
                  <template #prefix><i class="el-icon-lock"></i></template>
                </el-input>
              </div>
              <div class="input-group">
                <label>确认密码</label>
                <el-input 
                  v-model="userPassword2" 
                  type="password" 
                  placeholder="再次输入"
                  show-password
                  @keyup.enter="signIn"
                  class="trendy-input">
                  <template #prefix><i class="el-icon-finished"></i></template>
                </el-input>
              </div>
            </div>

            <div class="agreement">
              <el-checkbox v-model="agreed">
                我已阅读并同意 <span class="link-text">用户协议</span> 与 <span class="link-text">隐私政策</span>
              </el-checkbox>
            </div>

            <el-button type="primary" class="btn-signin" @click="signIn">
              立即注册并登录
            </el-button>

            <div class="form-footer">
              <span>已经有账号了？</span>
              <span @click="toLogin" class="login-link">立即登录</span>
            </div>
          </el-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "sign-in",
  data() {
    return {
      userPassword2: '',
      agreed: true,
      userInfo: {
        accountNumber: '',
        userPassword: '',
        nickname: ''
      }
    };
  },
  methods: {
    toLogin() {
      this.$router.replace({path: '/login'});
    },
    signIn() {
      if (!this.agreed) {
        return this.$message.warning('请先同意用户协议');
      }
      if (this.userInfo.accountNumber && this.userInfo.userPassword && this.userInfo.nickname) {
        if (this.userInfo.accountNumber.length !== 11) {
          this.$message.error('请输入正确的11位手机号');
        } else if (this.userInfo.userPassword !== this.userPassword2) {
          this.$message.error('两次输入的密码不一致');
        } else {
          const loading = this.$loading({ background: 'rgba(255, 255, 255, 0.8)' });
          this.$api.signIn(this.userInfo).then(res => {
            if (res.status_code === 1) {
              this.$message.success('注册成功！正在前往登录');
              setTimeout(() => {
                this.$router.replace({path: '/login'});
              }, 1000);
            } else {
              this.$message.error(res.msg || '该手机号已被注册');
            }
          }).finally(() => { loading.close(); });
        }
      } else {
        this.$message.warning('请填写完整的注册信息');
      }
    }
  }
}
</script>

<style scoped>
.signin-container {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  position: relative;
  background: #0f172a;
}

/* 极光背景特效 (与登录页保持一致) */
.aurora-bg {
  position: absolute;
  top: 0; left: 0; width: 100%; height: 100%;
  z-index: 0;
  overflow: hidden;
}
.aurora-item {
  position: absolute;
  width: 800px; height: 800px;
  filter: blur(100px);
  opacity: 0.3;
  border-radius: 50%;
  animation: drift 25s infinite alternate;
}
.aurora-item:nth-child(1) { background: #8b5cf6; top: -100px; right: -100px; }
.aurora-item:nth-child(2) { background: #ec4899; bottom: -100px; left: -100px; animation-delay: -7s; }
.aurora-item:nth-child(3) { background: #3b82f6; top: 40%; left: 20%; animation-duration: 30s; }

@keyframes drift {
  from { transform: translate(0,0) scale(1); }
  to { transform: translate(-100px, 50px) scale(1.3); }
}

.split-wrapper {
  position: relative;
  z-index: 1;
  display: flex;
  height: 100%;
  width: 100%;
}

/* 左侧展示 */
.brand-side {
  flex: 5;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px;
}
.brand-content { position: relative; z-index: 5; }
.icon-stack { display: flex; gap: 15px; margin-bottom: 40px; }
.stack-item {
  width: 64px; height: 64px;
  background: white; border-radius: 20px;
  display: flex; align-items: center; justify-content: center;
  font-size: 32px; color: #6366f1;
  box-shadow: 0 15px 30px rgba(0,0,0,0.2);
}
.item-2 { background: #f472b6; color: white; transform: rotate(15deg); margin-top: 20px; }

.brand-slogan {
  font-size: 64px; font-weight: 900;
  color: white; line-height: 1.1;
  letter-spacing: -1px;
}
.brand-slogan span {
  background: linear-gradient(to right, #fb7185, #f472b6);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.brand-sub { font-size: 18px; color: #94a3b8; margin-top: 24px; }

.feature-list { margin-top: 48px; display: flex; flex-direction: column; gap: 16px; }
.feature-item { display: flex; align-items: center; gap: 10px; color: #cbd5e1; font-weight: 600; }
.feature-item i { color: #10b981; font-size: 20px; }

/* 右侧表单 */
.form-side {
  flex: 5;
  background: rgba(255, 255, 255, 0.02);
  backdrop-filter: blur(40px);
  border-left: 1px solid rgba(255,255,255,0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
}

.signin-card {
  width: 100%;
  max-width: 500px;
}

.form-header { margin-bottom: 32px; }
.form-header h2 { font-size: 28px; font-weight: 800; color: white; margin-bottom: 8px; }
.form-header p { color: #94a3b8; font-size: 15px; }

.form-row { margin-bottom: 20px; }
.form-row.split { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

.input-group label { display: block; color: #cbd5e1; font-size: 13px; font-weight: 700; margin-bottom: 8px; }

.trendy-input :deep(.el-input__wrapper) {
  height: 52px;
  background: rgba(255,255,255,0.05) !important;
  border: 1px solid rgba(255,255,255,0.1) !important;
  border-radius: 14px !important;
  color: white !important;
}
.trendy-input :deep(.el-input__inner) { color: white !important; }
.trendy-input :deep(.el-input__wrapper.is-focus) {
  background: rgba(255,255,255,0.08) !important;
  border-color: #ec4899 !important;
  box-shadow: 0 0 15px rgba(236, 72, 153, 0.2) !important;
}

.agreement { margin: 24px 0; }
:deep(.el-checkbox__label) { color: #94a3b8 !important; font-size: 13px; }
.link-text { color: #f472b6; cursor: pointer; font-weight: 600; }

.btn-signin {
  width: 100%; height: 56px;
  font-size: 17px; font-weight: 800;
  border-radius: 16px !important;
  background: linear-gradient(135deg, #ec4899 0%, #8b5cf6 100%) !important;
  border: none !important;
  box-shadow: 0 8px 20px rgba(236, 72, 153, 0.3) !important;
  margin-bottom: 24px;
}

.form-footer { text-align: center; color: #94a3b8; font-size: 14px; }
.login-link { color: white; font-weight: 800; cursor: pointer; margin-left: 6px; border-bottom: 2px solid #6366f1; }

@media (max-width: 1024px) {
  .brand-side { display: none; }
  .form-side { flex: 1; padding: 20px; }
  .form-row.split { grid-template-columns: 1fr; gap: 0; }
}
</style>