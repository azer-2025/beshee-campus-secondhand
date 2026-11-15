<template>
    <main class="main-container">
        <div class="page-content">
            <slot></slot>
        </div>
    </main>
</template>

<script>
    export default {
        name: "AppPageBody"
    }
</script>

<style scoped>
.main-container {
    margin-top: 80px; 
    min-height: calc(100vh - 80px);
    display: flex;
    justify-content: center;
    padding-bottom: 60px;
}

.page-content {
    width: 1600px; /* 增加宽度 */
    max-width: 96%;
    display: flex;
    flex-direction: column;
}

@media (max-width: 768px) {
    .main-container { padding-bottom: 20px; }
}
</style>