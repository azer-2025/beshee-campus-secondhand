import defaultAvatarUrl from '../img/default-avatar.svg';

const API_ORIGIN = (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '');

export const DEFAULT_AVATAR = defaultAvatarUrl;

export function resolveAssetUrl(url, fallback = '') {
    const rawUrl = typeof url === 'string' ? url.trim() : '';

    if (!rawUrl) {
        return fallback;
    }

    if (/^(https?:)?\/\//i.test(rawUrl) || rawUrl.startsWith('data:') || rawUrl.startsWith('blob:')) {
        return rawUrl;
    }

    if (rawUrl.startsWith('/api/')) {
        return rawUrl;
    }

    if (rawUrl.startsWith('/')) {
        return `${API_ORIGIN}${rawUrl}`;
    }

    return `${API_ORIGIN}/${rawUrl.replace(/^\/+/, '')}`;
}
