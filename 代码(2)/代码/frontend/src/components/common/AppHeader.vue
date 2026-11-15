<template>
    <header class="app-header">
        <div class="header-container">
            <div class="brand">
                <router-link to="/" class="brand-logo">
                    <div class="logo-box">
                        <i class="el-icon-shopping-bag-2"></i>
                    </div>
                    <span class="logo-text">校园二手<span>交易平台</span></span>
                </router-link>
            </div>

            <div class="search-box">
                <el-input
                    placeholder="搜点好玩的宝贝..."
                    v-model="searchValue"
                    @keyup.enter="searchIdle"
                    class="trendy-search">
                    <template #prefix>
                        <i class="el-icon-search search-icon"></i>
                    </template>
                </el-input>
            </div>

            <div class="nav-right">
                <el-button type="primary" class="btn-publish" @click="toRelease">
                    <i class="el-icon-plus"></i> 马上发布
                </el-button>

                <div class="quick-icons">
                    <div class="icon-item" @click="toMessage">
                        <el-badge is-dot v-if="hasNewMessage">
                            <i class="el-icon-chat-round"></i>
                        </el-badge>
                        <i v-else class="el-icon-chat-round"></i>
                    </div>
                </div>

                <div class="user-control">
                    <router-link v-if="!isLogin" class="login-text" to="/login">登录</router-link>

                    <el-dropdown trigger="click" v-else @command="handleCommand">
                        <div class="user-trigger">
                            <el-avatar :size="38" :src="displayAvatar" class="header-avatar" @error="handleAvatarError"></el-avatar>
                            <i class="el-icon-caret-bottom"></i>
                        </div>
                        <template #dropdown>
                            <el-dropdown-menu class="user-menu">
                                <el-dropdown-item command="toMe"><i class="el-icon-user"></i> 我的主页</el-dropdown-item>
                                <el-dropdown-item divided command="logout" class="menu-logout"><i class="el-icon-switch-button"></i> 退出登录</el-dropdown-item>
                            </el-dropdown-menu>
                        </template>
                    </el-dropdown>
                </div>
            </div>
        </div>
    </header>
</template>
<script>
    import { DEFAULT_AVATAR, resolveAssetUrl } from '../../utils/asset';

    export default {
        name: 'AppHeader',
        props: ['searchInput','nicknameValue','avatarValue'],
        data() {
            return {
                searchValue: this.searchInput,
                nickname:'登录',
                avatar:'',
                defaultAvatar: DEFAULT_AVATAR,
                avatarLoadFailed: false,
                isLogin:false,
                hasNewMessage: false
            };
        },
        computed: {
            displayAvatar() {
                if (this.avatarLoadFailed) {
                    return this.defaultAvatar;
                }
                return resolveAssetUrl(this.avatarValue || this.avatar, this.defaultAvatar);
            }
        },
        watch: {
            avatarValue() {
                this.avatarLoadFailed = false;
            },
            avatar() {
                this.avatarLoadFailed = false;
            }
        },
        created(){
            if(! this.$globalData.userInfo.nickname){
                this.$api.getUserInfo().then(res=>{
                    if(res.status_code===1){
                        this.nickname=res.data.nickname;
                        this.avatar=res.data.avatar;
                        this.$globalData.userInfo=res.data;
                        this.isLogin=true;
                    }
                })
            }else {
                this.nickname=this.$globalData.userInfo.nickname;
                this.avatar=this.$globalData.userInfo.avatar;
                this.isLogin=true;
            }
        },
        methods: {
            handleAvatarError() {
                this.avatarLoadFailed = true;
                return false;
            },
            handleCommand(command) {
                if (command === 'toMe') this.toMe();
                if (command === 'logout') this.loginOut();
            },
            searchIdle() {
                if(this.searchValue && this.searchValue.trim() !== '') {
                    this.$router.push({path: '/search', query: {searchValue: this.searchValue}});
                } else {
                    this.$message.warning('想搜什么呢？');
                }
            },
            toMe() { this.$router.push({path: '/me'}); },
            toMessage(){ this.$router.push({path: '/message'}); },
            toRelease(){ this.$router.push({path: '/release'}); },
            loginOut(){
                this.$api.logout().then(res=>{
                    if(res.status_code===1){
                        this.$globalData.userInfo={};
                        this.$message.success('已安全退出');
                        this.$router.push({path: '/index'});
                    }
                });
            }
        }
    };
</script>
<style scoped>
.app-header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    height: 80px;
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(20px);
    z-index: 2000;
    display: flex;
    justify-content: center;
    border-bottom: 1px solid rgba(0,0,0,0.05);
}

.header-container {
    width: 1400px;
    max-width: 95%;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.brand-logo {
    display: flex;
    align-items: center;
    gap: 12px;
    text-decoration: none;
}

.logo-box {
    width: 44px;
    height: 44px;
    background: var(--brand-gradient);
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 24px;
    transform: rotate(-10deg);
}

.logo-text {
    font-size: 24px;
    font-weight: 900;
    color: var(--text-title);
    letter-spacing: -1px;
}

.logo-text span {
    color: #8b5cf6;
}

.search-box {
    flex: 1;
    max-width: 500px;
    margin: 0 40px;
}

.trendy-search :deep(.el-input__wrapper) {
    height: 48px;
    border-radius: 24px !important;
    background: #f1f5f9 !important;
    border: none !important;
    padding: 0 20px;
}

.search-icon {
    font-size: 18px;
    color: var(--text-light);
}

.nav-right {
    display: flex;
    align-items: center;
    gap: 24px;
}

.btn-publish {
    height: 46px;
    padding: 0 24px;
    border-radius: 23px !important;
    font-weight: 700;
}

.icon-item {
    font-size: 24px;
    color: var(--text-body);
    cursor: pointer;
    transition: color 0.3s;
}

.icon-item:hover {
    color: #6366f1;
}

.user-trigger {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    padding: 4px;
    border-radius: 24px;
    transition: background 0.3s;
}

.user-trigger:hover {
    background: #f1f5f9;
}

.header-avatar {
    border: 2px solid white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.login-text {
    text-decoration: none;
    color: #6366f1;
    font-weight: 700;
}

.user-menu {
    border-radius: 16px !important;
    padding: 8px !important;
    border: none !important;
    box-shadow: var(--shadow-lg) !important;
}

.menu-logout {
    color: var(--accent-pink) !important;
}

@media (max-width: 1024px) {
    .logo-text { display: none; }
    .search-box { margin: 0 20px; }
}
</style>
