<template>
    <div class="details-page">
        <app-head></app-head>
        <app-body>
            <div class="wide-layout">
                <!-- 第一行：主展示与核心交易区 -->
                <el-row :gutter="24" class="hero-row">
                    <!-- 左侧：巨幕画廊 -->
                    <el-col :lg="15" :md="24">
                        <div class="main-gallery trendy-card">
                            <div class="gallery-tag">GALLERY / 宝贝图集</div>
                            <el-carousel 
                                v-if="idleItemInfo.pictureList && idleItemInfo.pictureList.length > 0" 
                                height="600px" 
                                :interval="5000"
                                arrow="always"
                                class="big-carousel">
                                <el-carousel-item v-for="(imgUrl, i) in idleItemInfo.pictureList" :key="i">
                                    <el-image 
                                        :src="imgUrl" 
                                        fit="contain" 
                                        class="full-img"
                                        :preview-src-list="idleItemInfo.pictureList">
                                    </el-image>
                                </el-carousel-item>
                            </el-carousel>
                            <div v-else class="empty-gallery">
                                <i class="el-icon-picture-outline"></i>
                                <p>卖家太懒了，一张图都没传</p>
                            </div>
                        </div>
                    </el-col>

                    <!-- 右侧：交易与卖家（两行排列） -->
                    <el-col :lg="9" :md="24">
                        <!-- 交易卡片 -->
                        <div class="buy-card trendy-card">
                            <div class="buy-header">
                                <span class="price"><i>¥</i>{{idleItemInfo.idlePrice}}</span>
                                <el-tag size="small" effect="dark" type="danger">热销中</el-tag>
                            </div>
                            <h1 class="product-title">{{idleItemInfo.idleName}}</h1>
                            <div class="product-info-tags">
                                <span class="info-tag"><i class="el-icon-location"></i> {{idleItemInfo.idlePlace}}</span>
                                <span class="info-tag"><i class="el-icon-collection-tag"></i> {{getCategoryName(idleItemInfo.idleLabel)}}</span>
                                <span class="info-tag"><i class="el-icon-view"></i> 1.2k 浏览</span>
                            </div>
                            <div class="divider"></div>
                            <div class="action-grid">
                                <template v-if="idleItemInfo.idleStatus === 1">
                                    <el-button v-if="!isMaster" type="primary" class="main-btn buy" @click="buyButton(idleItemInfo)">
                                        <i class="el-icon-shopping-bag-1"></i> 立即下单
                                    </el-button>
                                    <el-button 
                                        v-if="!isMaster" 
                                        :type="isFavorite ? 'warning' : 'info'" 
                                        plain 
                                        class="main-btn fav"
                                        @click="favoriteButton(idleItemInfo)">
                                        <i :class="isFavorite ? 'el-icon-star-on' : 'el-icon-star-off'"></i>
                                        {{isFavorite ? '已在心愿单' : '加入心愿单'}}
                                    </el-button>
                                    <el-button v-else type="danger" class="main-btn delete" @click="changeStatus(idleItemInfo, 2)">
                                        下架宝贝
                                    </el-button>
                                </template>
                                <div v-else class="sold-out-box">
                                    <p>该宝贝已离开 Hub</p>
                                    <el-button v-if="isMaster" type="text" @click="changeStatus(idleItemInfo, 1)">重新上架</el-button>
                                </div>
                            </div>
                        </div>

                        <!-- 卖家卡片 -->
                        <div class="user-card trendy-card">
                            <div class="user-card-header">
                                <el-avatar :size="64" :src="idleItemInfo.user.avatar" class="u-avatar"></el-avatar>
                                <div class="u-info">
                                    <div class="u-name">{{idleItemInfo.user.nickname}}</div>
                                    <div class="u-meta">{{idleItemInfo.user.signInTime?.substring(0,10)}} 加入平台</div>
                                </div>
                            </div>
                            <div class="u-stats">
                                <div class="stat-item"><b>42</b><span>发布</span></div>
                                <div class="stat-item"><b>99%</b><span>好评</span></div>
                                <div class="stat-item"><b>15</b><span>粉丝</span></div>
                            </div>
                            <el-button
                                :type="isFollowing ? 'primary' : 'info'"
                                size="small"
                                round
                                :plain="!isFollowing"
                                class="full-width"
                                @click="toggleFollow"> {{ isFollowing ? '已关注' : '关注 TA' }}</el-button>
                        </div>
                    </el-col>
                </el-row>

                <!-- 第二行：详情与留言（左右分栏布局） -->
                <el-row :gutter="24" class="content-row">
                    <!-- 左侧：图文详情 -->
                    <el-col :lg="12" :md="24">
                        <div class="desc-card trendy-card">
                            <div class="box-title">📑 宝贝描述</div>
                            <div class="html-content" v-html="idleItemInfo.idleDetails"></div>
                            <div class="safety-tip">
                                <i class="el-icon-warning-outline"></i>
                                <span>温馨提示：请尽量选择校内线下交易，注意人身及财物安全。</span>
                            </div>
                        </div>
                    </el-col>

                    <!-- 右侧：交互留言 -->
                    <el-col :lg="12" :md="24">
                        <div class="msg-card trendy-card" id="replyMessageLocation">
                            <div class="box-title">💬 问答互动 ({{messageList.length}})</div>
                            
                            <!-- 留言输入区 -->
                            <div class="msg-input-box">
                                <div v-if="isReply" class="reply-banner">
                                    <span>回复 @{{replyData.toUserNickname}}</span>
                                    <i class="el-icon-close" @click="cancelReply"></i>
                                </div>
                                <el-input
                                    type="textarea"
                                    :rows="3"
                                    placeholder="有什么想问卖家的吗？"
                                    v-model="messageContent">
                                </el-input>
                                <div class="msg-btn-row">
                                    <el-button type="primary" round size="medium" @click="sendMessage">发送问答</el-button>
                                </div>
                            </div>

                            <!-- 留言列表 -->
                            <div class="msg-list-scroll">
                                <div v-if="messageList.length === 0" class="msg-empty">
                                    <i class="el-icon-chat-line-square"></i>
                                    <p>暂时还没有人提问哦</p>
                                </div>
                                <div v-else v-for="(mes, index) in messageList" :key="index" class="msg-bubble">
                                    <el-avatar :size="40" :src="mes.fromU.avatar"></el-avatar>
                                    <div class="msg-content-wrap">
                                        <div class="msg-user-row">
                                            <span class="name">{{mes.fromU.nickname}}</span>
                                            <span class="time">{{mes.createTime}}</span>
                                        </div>
                                        <div v-if="mes.toU.nickname" class="reply-quote">
                                            回复 @{{mes.toU.nickname}}: "{{mes.toM.content.substring(0,20)}}..."
                                        </div>
                                        <div class="text" v-html="mes.content"></div>
                                        <div class="ops" @click="replyMessage(index)">回复</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </el-col>
                </el-row>
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
        name: "idle-details",
        components: { AppHead, AppBody, AppFoot },
        data() {
            return {
                messageContent:'', toUser:null, toMessage:null, isReply:false,
                replyData:{ toUserNickname:'', toMessage:'' },
                messageList:[],
                idleItemInfo:{
                    id:'', idleName:'', idleDetails:'', pictureList:[],
                    idlePrice:0, idlePlace:'', idleLabel:'', idleStatus:-1,
                    userId:'', user:{ avatar:'', nickname:'', signInTime:'' },
                },
                isMaster:false, isFavorite:false, favoriteId:0, isFollowing:false,
                categories: { '1': '数码科技', '2': '生活用品', '3': '运动相关', '4': '图书笔记', '5': '公告' }
            };
        },
        created(){
            let id=this.$route.query.id;
            this.$api.getIdleItem({ id:id }).then(res=>{
                if(res.data){
                    let list=res.data.idleDetails.split(/\r?\n/);
                    let str='';
                    for(let i=0;i<list.length;i++){
                        str+='<p>'+list[i]+'</p>';
                    }
                    res.data.idleDetails=str;
                    res.data.pictureList=JSON.parse(res.data.pictureList);
                    this.idleItemInfo=res.data;
                    let userId=this.getCookie('shUserId');
                    if(userId == this.idleItemInfo.userId) this.isMaster=true;
                    this.isFollowing = this.getFollowState(userId, this.idleItemInfo.userId);
                    this.checkFavorite();
                    this.getAllIdleMessage();
                }
                window.scrollTo(0,0);
            });
        },
        methods: {
            getCategoryName(label) { return this.categories[label] || '其他'; },
            getAllIdleMessage(){
                this.$api.getAllIdleMessage({ idleId:this.idleItemInfo.id }).then(res=>{
                    if(res.status_code===1) this.messageList=res.data;
                });
            },
            checkFavorite(){
                this.$api.checkFavorite({ idleId:this.idleItemInfo.id }).then(res=>{
                    if(res.data){ this.isFavorite=true; this.favoriteId=res.data; }
                })
            },
            getCookie(cname){
                var name = cname + "=";
                var ca = document.cookie.split(';');
                for(var i=0; i<ca.length; i++) {
                    var c = ca[i].trim();
                    if (c.indexOf(name)===0) return c.substring(name.length,c.length);
                }
                return "";
            },
            getFollowStorageKey(userId){
                return 'followedUsers:' + userId;
            },
            getFollowState(userId, targetUserId){
                if(!userId || !targetUserId) return false;
                let raw = localStorage.getItem(this.getFollowStorageKey(userId));
                let followed = raw ? JSON.parse(raw) : [];
                return followed.includes(String(targetUserId));
            },
            toggleFollow(){
                let userId = this.getCookie('shUserId');
                if(!userId){
                    this.$message.warning('请先登录');
                    this.$router.push('/login');
                    return;
                }
                if(String(userId) === String(this.idleItemInfo.userId)){
                    this.$message.info('不能关注自己');
                    return;
                }
                let key = this.getFollowStorageKey(userId);
                let raw = localStorage.getItem(key);
                let followed = raw ? JSON.parse(raw) : [];
                let targetUserId = String(this.idleItemInfo.userId);
                if(this.isFollowing){
                    followed = followed.filter(id => id !== targetUserId);
                    this.isFollowing = false;
                    this.$message.success('已取消关注');
                } else {
                    if(!followed.includes(targetUserId)){
                        followed.push(targetUserId);
                    }
                    this.isFollowing = true;
                    this.$message.success('已关注 TA');
                }
                localStorage.setItem(key, JSON.stringify(followed));
            },
            replyMessage(index){
                this.isReply=true;
                this.replyData.toUserNickname=this.messageList[index].fromU.nickname;
                this.toUser=this.messageList[index].userId;
                this.toMessage=this.messageList[index].id;
                document.getElementById('replyMessageLocation').scrollIntoView({behavior:'smooth'});
            },
            changeStatus(idle,status){
                this.$api.updateIdleItem({ id:idle.id, idleStatus:status }).then(res=>{
                    if(res.status_code===1){
                        this.idleItemInfo.idleStatus=status;
                        this.$message.success('状态更新成功');
                    }
                });
            },
            buyButton(idleItemInfo){
                this.$api.addOrder({ idleId:idleItemInfo.id, orderPrice:idleItemInfo.idlePrice }).then(res=>{
                    if(res.status_code===1) this.$router.push({path: '/order', query: {id: res.data.id}});
                });
            },
            favoriteButton(idleItemInfo){
                if(this.isFavorite){
                    this.$api.deleteFavorite({ id: this.favoriteId }).then(res=>{
                        if(res.status_code===1){ this.$message.success('已移出心愿单'); this.isFavorite=false; }
                    })
                }else {
                    this.$api.addFavorite({ idleId:idleItemInfo.id }).then(res=>{
                        if(res.status_code===1){ this.$message.success('已加入心愿单'); this.isFavorite=true; this.favoriteId=res.data; }
                    })
                }
            },
            cancelReply(){ this.isReply=false; this.toUser=null; this.toMessage=null; },
            sendMessage(){
                if(!this.messageContent.trim()) return;
                this.$api.sendMessage({
                    idleId:this.idleItemInfo.id,
                    content:this.messageContent.replace(/\n/g, '<br>'),
                    toUser:this.toUser || this.idleItemInfo.userId,
                    toMessage:this.toMessage
                }).then(res=>{
                    if(res.status_code===1){
                        this.$message.success('发送成功');
                        this.messageContent='';
                        this.cancelReply();
                        this.getAllIdleMessage();
                    }
                });
            }
        }
    }
</script>

<style scoped>
.details-page { background: #f4f7ff; }
.wide-layout { width: 100%; }

.hero-row { margin-bottom: 32px; }

/* 巨幕画廊 */
.main-gallery { padding: 20px; position: relative; height: 640px; }
.gallery-tag { position: absolute; top: 30px; left: 30px; font-size: 12px; font-weight: 900; color: #6366f1; letter-spacing: 2px; z-index: 10; }
.big-carousel { border-radius: 16px; overflow: hidden; background: #f8fafc; }
.full-img { width: 100%; height: 100%; }
.empty-gallery { height: 100%; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #cbd5e1; }
.empty-gallery i { font-size: 80px; margin-bottom: 20px; }

/* 交易卡片 */
.buy-card { padding: 40px; margin-bottom: 24px; min-height: 340px; }
.buy-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
.price { font-size: 56px; font-weight: 900; color: #ec4899; letter-spacing: -2px; }
.price i { font-size: 24px; font-style: normal; margin-right: 4px; }

.product-title { font-size: 32px; font-weight: 900; color: #1e1b4b; margin-bottom: 16px; line-height: 1.2; }
.product-info-tags { display: flex; gap: 16px; color: #94a3b8; font-size: 14px; margin-bottom: 32px; }
.info-tag i { color: #6366f1; margin-right: 4px; }

.divider { height: 1px; background: #f1f5f9; margin-bottom: 32px; }
.action-grid { display: flex; flex-direction: column; gap: 16px; }
.main-btn { height: 64px; font-size: 18px; font-weight: 800; border-radius: 32px !important; margin: 0 !important; }
.btn-buy { background: var(--brand-gradient) !important; border: none; }

/* 卖家卡片 */
.user-card { padding: 30px; }
.user-card-header { display: flex; align-items: center; gap: 20px; margin-bottom: 24px; }
.u-avatar { border: 3px solid white; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
.u-name { font-size: 20px; font-weight: 800; color: #1e1b4b; }
.u-meta { font-size: 12px; color: #94a3b8; margin-top: 4px; }

.u-stats { display: flex; justify-content: space-around; background: #f8fafc; border-radius: 16px; padding: 16px; margin-bottom: 24px; }
.stat-item { display: flex; flex-direction: column; align-items: center; }
.stat-item b { font-size: 18px; color: #1e1b4b; }
.stat-item span { font-size: 11px; color: #94a3b8; text-transform: uppercase; }
.full-width { width: 100%; height: 40px; }

/* 详情与留言并排 */
.content-row { margin-bottom: 40px; }
.desc-card, .msg-card { padding: 32px; height: 500px; display: flex; flex-direction: column; }
.box-title { font-size: 20px; font-weight: 900; color: #1e1b4b; margin-bottom: 24px; border-left: 5px solid #6366f1; padding-left: 12px; }

.html-content { flex: 1; overflow-y: auto; font-size: 16px; line-height: 1.8; color: #475569; padding-right: 10px; }
.html-content :deep(p) { margin-bottom: 12px; }

.safety-tip { margin-top: 20px; padding: 12px; background: #fffbeb; border-radius: 12px; color: #b45309; font-size: 13px; display: flex; gap: 8px; }

.msg-input-box { background: #f1f5f9; padding: 16px; border-radius: 16px; margin-bottom: 24px; }
.reply-banner { display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: #6366f1; margin-bottom: 8px; }
.msg-btn-row { display: flex; justify-content: flex-end; margin-top: 12px; }

.msg-list-scroll { flex: 1; overflow-y: auto; padding-right: 10px; }
.msg-bubble { display: flex; gap: 12px; margin-bottom: 24px; }
.msg-content-wrap { flex: 1; }
.msg-user-row { display: flex; justify-content: space-between; margin-bottom: 6px; }
.msg-user-row .name { font-weight: 700; color: #1e1b4b; font-size: 14px; }
.msg-user-row .time { font-size: 11px; color: #94a3b8; }
.reply-quote { background: #f8fafc; padding: 6px 10px; border-radius: 8px; font-size: 12px; color: #64748b; margin-bottom: 8px; border-left: 2px solid #cbd5e1; }
.text { font-size: 14px; color: #475569; line-height: 1.5; }
.ops { margin-top: 8px; font-size: 12px; color: #6366f1; font-weight: 700; cursor: pointer; }

.msg-empty { text-align: center; padding-top: 40px; color: #cbd5e1; }
.msg-empty i { font-size: 48px; margin-bottom: 12px; }

@media (max-width: 1200px) {
    .desc-card, .msg-card { height: auto; margin-bottom: 24px; }
}
</style>
