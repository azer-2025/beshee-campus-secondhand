import axios from 'axios';

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
