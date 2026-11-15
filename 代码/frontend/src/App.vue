<template>
    <div id="app">
        <router-view v-slot="{ Component }">
            <transition name="page-fade" mode="out-in">
                <component :is="Component" />
            </transition>
        </router-view>
    </div>
</template>
<style>
:root {
    /* Premium SaaS Palette */
    --brand-primary: #4f46e5; /* Indigo 600 */
    --brand-primary-light: rgba(79, 70, 229, 0.1);
    --brand-gradient: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
    
    /* Semantic Colors */
    --success-green: #10b981; /* Emerald 500 */
    --warning-orange: #f59e0b; /* Amber 500 */
    --danger-red: #ef4444; /* Red 500 */
    --info-blue: #3b82f6; /* Blue 500 */
    
    /* Refined Backgrounds */
    --bg-main: #f8fafc; /* Slate 50 */
    --bg-card: #ffffff;
    --bg-glass: rgba(255, 255, 255, 0.7);
    
    /* Typography */
    --text-primary: #1e293b; /* Slate 800 */
    --text-secondary: #475569; /* Slate 600 */
    --text-tertiary: #94a3b8; /* Slate 400 */
    
    /* Effects & Border Radius */
    --shadow-soft: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
    --shadow-md: 0 10px 15px -3px rgba(0, 0, 0, 0.08), 0 4px 6px -4px rgba(0, 0, 0, 0.08);
    --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
    --radius-sm: 8px;
    --radius-md: 12px;
    --radius-lg: 20px;
    --radius-xl: 24px;
    
    --glass-blur: blur(12px);
}

* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
    transition: background-color 0.3s, border-color 0.3s, box-shadow 0.3s;
}

html, body, #app {
    height: 100%;
    font-family: 'Inter', 'SF Pro Display', 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', sans-serif;
    background-color: var(--bg-main);
    color: var(--text-primary);
    -webkit-font-smoothing: antialiased;
    scroll-behavior: smooth;
}

/* Premium Card Style */
.premium-card {
    background: var(--bg-card);
    border-radius: var(--radius-lg);
    border: 1px solid rgba(226, 232, 240, 0.8);
    box-shadow: var(--shadow-soft);
    padding: 24px;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.premium-card:hover {
    box-shadow: var(--shadow-lg);
    transform: translateY(-4px);
    border-color: var(--brand-primary-light);
}

/* Element Plus Global Overrides */
.el-button {
    border-radius: var(--radius-md) !important;
    font-weight: 500 !important;
    padding: 10px 20px !important;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important;
}

.el-button--primary {
    background: var(--brand-gradient) !important;
    border: none !important;
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25) !important;
}

.el-button--primary:hover {
    box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4) !important;
    transform: translateY(-2px);
    opacity: 0.95;
}

.el-input__wrapper {
    border-radius: var(--radius-md) !important;
    box-shadow: 0 0 0 1px #e2e8f0 inset !important;
    padding: 2px 12px !important;
    background: #f8fafc !important;
}

.el-input__wrapper.is-focus {
    box-shadow: 0 0 0 2px var(--brand-primary-light) inset, 0 0 0 1px var(--brand-primary) inset !important;
    background: #ffffff !important;
}

/* Scrollbar Customization */
::-webkit-scrollbar {
    width: 6px;
    height: 6px;
}

::-webkit-scrollbar-track {
    background: transparent;
}

::-webkit-scrollbar-thumb {
    background: #cbd5e1;
    border-radius: 10px;
}

::-webkit-scrollbar-thumb:hover {
    background: #94a3b8;
}

/* Animations */
.fade-up-enter-active, .fade-up-leave-active {
    transition: all 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.fade-up-enter-from {
    opacity: 0;
    transform: translateY(20px);
}

.fade-up-leave-to {
    opacity: 0;
    transform: translateY(-20px);
}
</style>
