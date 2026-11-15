import { createRouter, createWebHashHistory } from 'vue-router';

const platformTitle = '二手手机交易平台';

const routes = [
  {
    path: '/',
    redirect: '/index'
  },
  {
    path: '/index',
    component: () => import('../components/page/index.vue'),
    meta: { title: platformTitle }
  },
  {
    path: '/search',
    component: () => import('../components/page/search.vue'),
    meta: { title: `手机搜索 | ${platformTitle}` }
  },
  {
    path: '/me',
    component: () => import('../components/page/me.vue'),
    meta: { title: `个人中心 | ${platformTitle}` }
  },
  {
    path: '/message',
    component: () => import('../components/page/message.vue'),
    meta: { title: `消息中心 | ${platformTitle}` }
  },
  {
    path: '/release',
    component: () => import('../components/page/release.vue'),
    meta: { title: `发布手机 | ${platformTitle}` }
  },
  {
    path: '/details',
    component: () => import('../components/page/idle-details.vue'),
    meta: { title: `手机详情 | ${platformTitle}` }
  },
  {
    path: '/order',
    component: () => import('../components/page/order.vue'),
    meta: { title: `订单详情 | ${platformTitle}` }
  },
  {
    path: '/alipay/pay',
    component: () => import('../components/page/alipay-success.vue'),
    meta: { title: `支付成功 | ${platformTitle}` }
  },
  {
    path: '/login',
    component: () => import('../components/page/login.vue'),
    meta: { title: `登录 | ${platformTitle}` }
  },
  {
    path: '/sign-in',
    component: () => import('../components/page/sign-in.vue'),
    meta: { title: `注册 | ${platformTitle}` }
  },
  {
    path: '/login-admin',
    component: () => import('../components/page/login-admin.vue'),
    meta: { title: `管理员登录 | ${platformTitle}` }
  },
  {
    path: '/platform-admin',
    component: () => import('../components/page/platform-admin.vue'),
    meta: { title: `后台管理 | ${platformTitle}` }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
];

const router = createRouter({
  history: createWebHashHistory(),
  routes
});

export default router;
