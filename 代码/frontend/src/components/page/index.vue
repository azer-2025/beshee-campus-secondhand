<template>
    <div class="index-page">
        <app-head></app-head>
        <app-body>
            <section class="banner-section">
                <div class="banner-card">
                    <div class="banner-content">
                        <div class="banner-tag">二手手机严选</div>
                        <h1 class="banner-title">把旧手机变成<span>现金</span></h1>
                        <p class="banner-desc">在这里快速买卖二手手机，覆盖安卓、苹果、游戏手机和折叠屏机型。</p>
                        <div class="banner-actions">
                            <el-button type="primary" size="large" round @click="toRelease">立即发布</el-button>
                            <div class="banner-stats">
                                <div class="stat-unit"><b>2k+</b><span>今日上新</span></div>
                                <div class="stat-unit"><b>15k+</b><span>活跃买家</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="banner-visual">
                        <div class="floating-item item-1">
                            <el-icon><Camera /></el-icon>
                        </div>
                        <div class="floating-item item-2">
                            <el-icon><Headset /></el-icon>
                        </div>
                        <div class="floating-item item-3">
                            <el-icon><Monitor /></el-icon>
                        </div>
                        <div class="banner-circle"></div>
                    </div>
                </div>
            </section>

            <div class="cat-nav">
                <div class="cat-scroll">
                    <div
                        v-for="cat in categoryOptions"
                        :key="cat.value"
                        class="cat-pill"
                        :class="{ active: labelName === cat.value }"
                        @click="handleCategoryChange(cat.value)"
                    >
                        <div class="pill-icon">
                            <el-icon><component :is="cat.icon" /></el-icon>
                        </div>
                        <span>{{ cat.label }}</span>
                    </div>
                </div>
            </div>

            <div class="feed-section">
                <div class="feed-header">
                    <h2 class="feed-title">
                        {{ getCategoryLabel(labelName) }}
                        <span v-if="totalItem > 0">({{ totalItem }})</span>
                    </h2>
                    <div class="feed-sort">
                        <span>最新发布</span>
                        <el-icon><Sort /></el-icon>
                    </div>
                </div>

                <div v-if="idleList.length === 0" class="empty-feed">
                    <div class="empty-box">
                        <el-icon><Refresh /></el-icon>
                        <p>这个分类暂时还没有手机，先看看全部机型。</p>
                        <el-button type="primary" plain round @click="handleCategoryChange('0')">查看全部</el-button>
                    </div>
                </div>

                <el-row :gutter="20" class="product-grid">
                    <el-col :xs="12" :sm="8" :md="6" :lg="6" v-for="(idle, index) in idleList" :key="index">
                        <div class="product-card trendy-card" @click="toDetails(idle)">
                            <div class="img-container">
                                <el-image :src="idle.imgUrl" fit="cover" lazy class="product-img">
                                    <template #placeholder>
                                        <div class="img-loading"></div>
                                    </template>
                                    <template #error>
                                        <div class="img-error">
                                            <el-icon><Picture /></el-icon>
                                        </div>
                                    </template>
                                </el-image>
                                <div class="product-badge" :class="'cat-' + idle.idleLabel">
                                    {{ getItemCategory(idle.idleLabel) }}
                                </div>
                            </div>

                            <div class="product-info">
                                <h3 class="product-title">{{ idle.idleName }}</h3>
                                <div class="product-meta">
                                    <span class="product-price"><small>¥</small>{{ idle.idlePrice }}</span>
                                    <span class="product-loc">
                                        <el-icon><LocationInformation /></el-icon>
                                        {{ idle.idlePlace }}
                                    </span>
                                </div>
                                <div class="product-footer">
                                    <div class="user-strip">
                                        <el-avatar :size="20" :src="idle.user.avatar"></el-avatar>
                                        <span class="username">{{ idle.user.nickname }}</span>
                                    </div>
                                    <span class="time-ago">{{ getTimeAgo(idle.releaseTime) }}</span>
                                </div>
                            </div>
                        </div>
                    </el-col>
                </el-row>
            </div>

            <div class="pager-wrapper">
                <el-pagination
                    background
                    layout="prev, pager, next"
                    :total="totalItem"
                    :page-size="8"
                    v-model:current-page="currentPage"
                    @current-change="handleCurrentChange"
                    class="trendy-pager">
                </el-pagination>
            </div>

            <app-foot></app-foot>
        </app-body>
    </div>
</template>

<script>
import {
    Camera,
    CoffeeCup,
    Grid,
    Headset,
    LocationInformation,
    Microphone,
    Monitor,
    Picture,
    Reading,
    Refresh,
    Sort
} from '@element-plus/icons-vue';
import AppHead from '../common/AppHeader.vue';
import AppBody from '../common/AppPageBody.vue';
import AppFoot from '../common/AppFoot.vue';

export default {
    name: 'index',
    components: {
        AppHead,
        AppBody,
        AppFoot,
        Camera,
        Headset,
        Monitor,
        Sort,
        Refresh,
        Picture,
        LocationInformation
    },
    data() {
        return {
            labelName: '0',
            idleList: [],
            currentPage: 1,
            totalItem: 0,
            categoryOptions: [
                { label: '全部机型', value: '0', icon: Grid },
                { label: '安卓手机', value: '1', icon: Monitor },
                { label: '苹果手机', value: '2', icon: CoffeeCup },
                { label: '游戏手机', value: '3', icon: Headset },
                { label: '折叠屏', value: '4', icon: Reading },
                { label: '手机配件', value: '5', icon: Microphone }
            ],
            categories: { '1': '安卓', '2': '苹果', '3': '游戏', '4': '折叠', '5': '配件' }
        };
    },
    created() {
        const q = this.$route.query;
        this.labelName = q.labelName || '0';
        this.currentPage = parseInt(q.page, 10) || 1;
        this.fetchData(this.currentPage);
    },
    watch: {
        $route(to) {
            this.labelName = to.query.labelName || '0';
            this.currentPage = parseInt(to.query.page, 10) || 1;
            this.fetchData(this.currentPage);
        }
    },
    methods: {
        fetchData(page) {
            const loading = this.$loading({ background: 'rgba(244, 247, 255, 0.8)' });
            const api = this.labelName > 0
                ? this.$api.findIdleTiemByLable({ idleLabel: this.labelName, page, nums: 8 })
                : this.$api.findIdleTiem({ page, nums: 8 });

            api.then(res => {
                const list = res.data.list || [];
                list.forEach(item => {
                    const pics = JSON.parse(item.pictureList || '[]');
                    item.imgUrl = pics.length > 0 ? pics[0] : '';
                });
                this.idleList = list;
                this.totalItem = res.data.count || 0;
            }).finally(() => {
                loading.close();
                window.scrollTo({ top: 0, behavior: 'smooth' });
            });
        },
        handleCategoryChange(v) {
            this.$router.push({ query: { page: 1, labelName: v } });
        },
        handleCurrentChange(v) {
            this.$router.push({ query: { page: v, labelName: this.labelName } });
        },
        toDetails(item) {
            this.$router.push({ path: '/details', query: { id: item.id } });
        },
        toRelease() {
            this.$router.push('/release');
        },
        getItemCategory(l) {
            return this.categories[l] || '其他';
        },
        getCategoryLabel(v) {
            return this.categoryOptions.find(c => c.value === v)?.label || '发现手机';
        },
        getTimeAgo(time) {
            return time ? time.substring(5, 10) : '';
        }
    }
};
</script>

<style scoped>
.banner-section {
    padding: 20px 0 40px;
}

.banner-card {
    height: 340px;
    background: var(--brand-gradient);
    border-radius: 32px;
    display: flex;
    overflow: hidden;
    position: relative;
    box-shadow: 0 20px 40px rgba(99, 102, 241, 0.2);
}

.banner-content {
    flex: 1;
    padding: 60px;
    color: white;
    z-index: 2;
    position: relative;
}

.banner-tag {
    display: inline-block;
    padding: 6px 16px;
    background: rgba(255, 255, 255, 0.2);
    backdrop-filter: blur(10px);
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 20px;
}

.banner-title {
    font-size: 48px;
    font-weight: 900;
    margin-bottom: 16px;
    letter-spacing: -1px;
}

.banner-title span {
    color: #ffd60a;
    text-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

.banner-desc {
    font-size: 18px;
    opacity: 0.9;
    margin-bottom: 32px;
    max-width: 420px;
}

.banner-actions {
    display: flex;
    align-items: center;
    gap: 32px;
}

.banner-stats {
    display: flex;
    gap: 24px;
}

.stat-unit {
    display: flex;
    flex-direction: column;
}

.stat-unit b {
    font-size: 20px;
}

.stat-unit span {
    font-size: 12px;
    opacity: 0.7;
}

.banner-visual {
    flex: 1;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}

.banner-circle {
    width: 400px;
    height: 400px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    position: absolute;
    right: -100px;
}

.floating-item {
    position: absolute;
    width: 60px;
    height: 60px;
    background: white;
    border-radius: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    color: #6366f1;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
    animation: float 4s infinite ease-in-out;
}

.item-1 {
    top: 60px;
    right: 150px;
    animation-delay: 0s;
}

.item-2 {
    bottom: 80px;
    right: 80px;
    animation-delay: 1s;
}

.item-3 {
    top: 180px;
    right: 40px;
    animation-delay: 2s;
}

@keyframes float {
    0%,
    100% {
        transform: translateY(0);
    }

    50% {
        transform: translateY(-20px);
    }
}

.cat-nav {
    margin-bottom: 40px;
    overflow-x: auto;
    padding: 10px 0;
}

.cat-scroll {
    display: flex;
    gap: 16px;
    justify-content: center;
}

.cat-pill {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 24px;
    background: white;
    border-radius: 30px;
    cursor: pointer;
    font-weight: 700;
    color: var(--text-body);
    transition: all 0.3s ease;
    border: 1px solid rgba(0, 0, 0, 0.05);
}

.cat-pill .pill-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    transition: all 0.3s;
}

.cat-pill:hover {
    border-color: #6366f1;
    color: #6366f1;
}

.cat-pill.active {
    background: #6366f1;
    color: white;
    border-color: #6366f1;
    box-shadow: 0 10px 20px rgba(99, 102, 241, 0.2);
}

.cat-pill.active .pill-icon {
    background: rgba(255, 255, 255, 0.2);
    color: white;
}

.feed-section {
    margin-bottom: 60px;
}

.feed-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding: 0 10px;
}

.feed-title {
    font-size: 24px;
    font-weight: 900;
    color: var(--text-title);
}

.feed-sort {
    color: var(--text-light);
    font-size: 14px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
}

.product-card {
    margin-bottom: 24px;
    overflow: hidden;
    height: 320px;
    display: flex;
    flex-direction: column;
}

.img-container {
    height: 180px;
    position: relative;
    overflow: hidden;
}

.product-img {
    width: 100%;
    height: 100%;
    transition: transform 0.5s;
}

.product-card:hover .product-img {
    transform: scale(1.15);
}

.product-badge {
    position: absolute;
    top: 12px;
    left: 12px;
    padding: 4px 10px;
    border-radius: 8px;
    font-size: 11px;
    font-weight: 800;
    color: white;
    backdrop-filter: blur(4px);
    background: rgba(0, 0, 0, 0.5);
}

.product-info {
    padding: 16px;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.product-title {
    font-size: 16px;
    font-weight: 700;
    color: var(--text-title);
    margin-bottom: 12px;
    display: -webkit-box;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.product-meta {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: auto;
}

.product-price {
    font-size: 22px;
    font-weight: 900;
    color: var(--accent-pink);
}

.product-price small {
    font-size: 14px;
    margin-right: 2px;
}

.product-loc {
    font-size: 12px;
    color: var(--text-light);
    display: flex;
    align-items: center;
    gap: 4px;
}

.product-footer {
    padding-top: 12px;
    border-top: 1px solid #f1f5f9;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.user-strip {
    display: flex;
    align-items: center;
    gap: 6px;
}

.username {
    font-size: 12px;
    font-weight: 600;
    color: var(--text-body);
}

.time-ago {
    font-size: 11px;
    color: var(--text-light);
}

.empty-feed {
    padding: 100px 0;
    text-align: center;
}

.empty-box :deep(.el-icon) {
    font-size: 64px;
    color: #e2e8f0;
    margin-bottom: 20px;
}

.pager-wrapper {
    display: flex;
    justify-content: center;
    padding-bottom: 40px;
}

:deep(.trendy-pager .el-pager li) {
    background: white !important;
    border-radius: 10px !important;
    border: 1px solid #e2e8f0 !important;
}

:deep(.trendy-pager .el-pager li.is-active) {
    background: var(--brand-gradient) !important;
    color: white !important;
    border: none !important;
}

@media (max-width: 768px) {
    .banner-card {
        height: auto;
        flex-direction: column;
    }

    .banner-visual {
        display: none;
    }

    .banner-title {
        font-size: 32px;
    }

    .cat-scroll {
        justify-content: flex-start;
        padding: 0 20px;
    }
}
</style>
