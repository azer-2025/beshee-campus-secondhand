<template>
    <div class="message-page">
        <app-head></app-head>
        <app-body>
            <div class="message-fluid-container">
                <!-- 顶部大气标题栏 -->
                <div class="page-header-box">
                    <div class="header-left">
                        <div class="brand-icon-main">
                            <i class="el-icon-chat-dot-round"></i>
                        </div>
                        <div class="title-group">
                            <h1 class="main-title">问答动态 <span>Activity Feed</span></h1>
                            <p class="sub-desc">在这里管理同学对你宝贝的所有咨询与互动</p>
                        </div>
                    </div>
                    <div class="header-right" v-if="meslist.length > 0">
                        <div class="stat-pill">
                            <span class="label">累计收到</span>
                            <span class="value">{{meslist.length}}</span>
                            <span class="unit">条咨询</span>
                        </div>
                    </div>
                </div>

                <!-- 多列网格布局 -->
                <div class="message-grid-layout">
                    <div v-if="meslist.length === 0" class="full-empty">
                        <div class="empty-card trendy-card">
                            <img src="https://img.icons8.com/bubbles/200/000000/empty-box.png"/>
                            <h3>静悄悄的...</h3>
                            <p>暂时还没有收到消息，快去发布更有吸引力的宝贝吧！</p>
                            <el-button type="primary" size="large" round @click="$router.push('/release')">立即发布</el-button>
                        </div>
                    </div>

                    <el-row :gutter="24" v-else>
                        <el-col :xl="8" :lg="12" :md="12" :sm="24" v-for="(mes, index) in meslist" :key="index" class="grid-item">
                            <div class="msg-card-v3 trendy-card" @click="toDetails(mes.idle.id)">
                                <!-- 宝贝背景装饰 -->
                                <div class="card-bg-decoration">
                                    <el-image :src="mes.idle.imgUrl" fit="cover"></el-image>
                                </div>
                                
                                <div class="card-main-content">
                                    <!-- 头部：发送者 -->
                                    <div class="user-header">
                                        <div class="u-avatar-wrap">
                                            <el-avatar :size="50" :src="mes.fromU.avatar" class="u-avatar"></el-avatar>
                                            <div class="status-ring"></div>
                                        </div>
                                        <div class="u-info">
                                            <div class="u-name">{{mes.fromU.nickname}}</div>
                                            <div class="u-time">{{mes.createTime}}</div>
                                        </div>
                                        <div class="item-mini-tag">关联宝贝</div>
                                    </div>

                                    <!-- 中部：聊天内容 -->
                                    <div class="chat-content-box">
                                        <div class="chat-bubble-v2">
                                            <div class="quote-mark">“</div>
                                            <p class="text">{{mes.content}}</p>
                                        </div>
                                    </div>

                                    <!-- 底部：宝贝信息卡 -->
                                    <div class="item-footer-card">
                                        <el-image class="footer-img" :src="mes.idle.imgUrl" fit="cover"></el-image>
                                        <div class="footer-info">
                                            <div class="item-title">{{mes.idle.idleName}}</div>
                                            <div class="item-price">¥{{mes.idle.idlePrice}}</div>
                                        </div>
                                        <div class="go-btn"><i class="el-icon-right"></i></div>
                                    </div>
                                </div>
                            </div>
                        </el-col>
                    </el-row>
                </div>
            </div>
            <app-foot></app-foot>
        </app-body>
    </div>
</template>

<script>
    import AppHead from '../common/AppHeader.vue';
    import AppBody from '../common/AppPageBody.vue'
    import AppFoot from '../common/AppFoot.vue'

    export default {
        name: "message",
        components: { AppHead, AppBody, AppFoot },
        data(){
            return { meslist:[] };
        },
        created(){
            const loading = this.$loading({ 
                text: '正在同步消息流...',
                background: 'rgba(244, 247, 255, 0.9)' 
            });
            this.$api.getAllMyMessage().then(res=>{
                if(res.status_code===1){
                    res.data.forEach(mes => {
                        const imgList = JSON.parse(mes.idle.pictureList);
                        mes.idle.imgUrl = imgList ? imgList[0] : '';
                        mes.content = mes.content.replace(/<br>/g, ' ');
                    });
                    this.meslist = res.data;
                }
            }).finally(() => { loading.close(); });
        },
        methods:{
            toDetails(id){ this.$router.push({path: '/details', query:{id:id}}); }
        }
    }
</script>

<style scoped>
.message-page { background: #f4f7ff; min-height: 100vh; }
.message-fluid-container { width: 100%; padding: 20px 0; }

/* 页面头部设计 */
.page-header-box {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 40px;
    padding: 0 10px;
}
.header-left { display: flex; align-items: center; gap: 24px; }
.brand-icon-main {
    width: 64px; height: 64px;
    background: var(--brand-gradient);
    border-radius: 20px;
    display: flex; align-items: center; justify-content: center;
    font-size: 32px; color: white;
    box-shadow: 0 12px 24px rgba(99, 102, 241, 0.3);
    transform: rotate(-5deg);
}
.main-title { font-size: 36px; font-weight: 900; color: #1e1b4b; letter-spacing: -1px; }
.main-title span { font-size: 16px; color: #94a3b8; font-weight: 400; margin-left: 12px; text-transform: uppercase; letter-spacing: 2px; }
.sub-desc { color: #64748b; font-size: 16px; margin-top: 6px; }

.stat-pill {
    background: white; padding: 12px 24px; border-radius: 30px;
    display: flex; align-items: baseline; gap: 10px;
    box-shadow: var(--shadow-md);
}
.stat-pill .label { font-size: 14px; color: #94a3b8; }
.stat-pill .value { font-size: 28px; font-weight: 900; color: #6366f1; }
.stat-pill .unit { font-size: 14px; color: #64748b; }

/* 网格卡片设计 */
.message-grid-layout { width: 100%; }
.grid-item { margin-bottom: 24px; }

.msg-card-v3 {
    height: 420px;
    position: relative;
    overflow: hidden;
    cursor: pointer;
    background: white;
    display: flex;
    flex-direction: column;
}

/* 卡片背景装饰图 */
.card-bg-decoration {
    position: absolute;
    top: 0; right: 0; width: 150px; height: 150px;
    opacity: 0.05;
    filter: grayscale(100%) blur(2px);
    z-index: 0;
    pointer-events: none;
}
.card-bg-decoration :deep(img) { border-radius: 0 0 0 100%; }

.card-main-content {
    position: relative;
    z-index: 1;
    padding: 32px;
    height: 100%;
    display: flex;
    flex-direction: column;
}

/* 用户头部 */
.user-header { display: flex; align-items: center; gap: 16px; margin-bottom: 24px; }
.u-avatar-wrap { position: relative; }
.status-ring {
    position: absolute; inset: -4px;
    border: 2px solid #6366f1; border-radius: 50%;
    opacity: 0.3;
}
.u-name { font-size: 18px; font-weight: 800; color: #1e1b4b; }
.u-time { font-size: 12px; color: #94a3b8; margin-top: 4px; }
.item-mini-tag {
    margin-left: auto; font-size: 10px; font-weight: 900;
    color: #6366f1; background: #eef2ff;
    padding: 4px 10px; border-radius: 6px;
}

/* 聊天气泡 */
.chat-content-box { flex: 1; margin-bottom: 24px; }
.chat-bubble-v2 {
    background: #f8fafc;
    padding: 20px;
    border-radius: 20px;
    position: relative;
    height: 100%;
}
.quote-mark {
    position: absolute; top: 10px; left: 10px;
    font-size: 40px; font-family: serif; color: #e2e8f0; line-height: 1;
}
.chat-bubble-v2 .text {
    font-size: 16px; color: #475569; line-height: 1.6;
    position: relative; z-index: 1;
    display: -webkit-box; -webkit-line-clamp: 4; -webkit-box-orient: vertical;
    overflow: hidden;
}

/* 底部宝贝预览 */
.item-footer-card {
    background: #1e1b4b;
    border-radius: 16px;
    padding: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
    transition: all 0.3s;
}
.footer-img { width: 48px; height: 48px; border-radius: 10px; flex-shrink: 0; }
.footer-info { flex: 1; min-width: 0; }
.footer-info .item-title { color: white; font-size: 14px; font-weight: 700; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.footer-info .item-price { color: #f472b6; font-size: 16px; font-weight: 900; margin-top: 2px; }
.go-btn { color: #6366f1; font-size: 20px; }

.msg-card-v3:hover { transform: translateY(-10px) scale(1.02); }
.msg-card-v3:hover .item-footer-card { background: #312e81; transform: scale(1.02); }
.msg-card-v3:hover .status-ring { opacity: 1; transform: scale(1.1); transition: 0.4s; }

/* 空状态 */
.full-empty { padding: 100px 0; text-align: center; }
.empty-card { display: inline-flex; flex-direction: column; align-items: center; padding: 80px; gap: 20px; max-width: 600px; }
.empty-card h3 { font-size: 24px; font-weight: 900; color: #1e1b4b; }
.empty-card p { color: #94a3b8; font-size: 16px; }

@media (max-width: 768px) {
    .page-header-box { flex-direction: column; align-items: flex-start; gap: 20px; }
    .stat-pill { width: 100%; justify-content: center; }
}
</style>