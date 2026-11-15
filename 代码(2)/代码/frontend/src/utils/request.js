import axios from 'axios';
import router from '../router';

/* axios功能封装  */

const baseURL = import.meta.env.DEV
    ? '/api'
    : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080');

const service = axios.create({
    timeout: 5000,
    baseURL,
    withCredentials:  true
});

// request interceptor(请求拦截器)
service.interceptors.request.use(
    config => {
        return config;
    },
    error => {
        console.log(error);
        return Promise.reject();
    }
);

// response interceptor（接收拦截器）
service.interceptors.response.use(
    response => {
        if (response.status === 200) {
            const data = response.data;
            const isAdminRequest = response.config?.url?.startsWith('/admin/');
            const isSessionExpired = data?.status_code === 0 && data?.msg === '请重新登录';

            if (isSessionExpired) {
                const inAdminPage = router.currentRoute.value.path === '/platform-admin';
                const targetPath = isAdminRequest
                    ? '/login-admin'
                    : (inAdminPage ? '' : '/login');

                if (!targetPath) {
                    return data;
                }

                if (router.currentRoute.value.path !== targetPath) {
                    router.replace(targetPath);
                }
            }

            return response.data;
        } else {
            Promise.reject();
        }
    },
    error => {
        console.log(error);
        return Promise.reject();
    }
);

export default service;
