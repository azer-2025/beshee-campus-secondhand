import { createApp, reactive } from 'vue';
import ElementPlus, { ElMessage, ElMessageBox } from 'element-plus';
import 'element-plus/dist/index.css';
import './styles/legacy-icons.css';
import App from './App.vue';
import router from './router';
import api from './api/index.js';

const globalData = reactive({
  userInfo: {
    nickname: ''
  }
});

const sta = reactive({
  isLogin: sessionStorage.getItem('admin_is_login') === '1',
  adminName: sessionStorage.getItem('admin_name') || ''
});

router.beforeEach(async to => {
  document.title = to.meta?.title ?? '二手手机交易平台';

  const requiresLogin = ['/me', '/message', '/release', '/order'].includes(to.path);
  if (!requiresLogin || globalData.userInfo.nickname) {
    return true;
  }

  try {
    const res = await api.getUserInfo();
    if (res.status_code !== 1) {
      return '/login';
    }

    res.data.signInTime = res.data.signInTime.substring(0, 10);
    globalData.userInfo = res.data;
    return true;
  } catch {
    return '/login';
  }
});

const app = createApp(App);
app.config.globalProperties.$api = api;
app.config.globalProperties.$sta = sta;
app.config.globalProperties.$globalData = globalData;
app.config.globalProperties.$message = ElMessage;
app.config.globalProperties.$confirm = ElMessageBox.confirm;
app.use(router);
app.use(ElementPlus, {
  size: 'default'
});
app.mount('#app');
