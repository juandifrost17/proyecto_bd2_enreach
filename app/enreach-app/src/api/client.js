import { API_BASE_URL, DEFAULT_PERIOD, HTTP_STATUS } from '@/constants/api';

export class ApiError extends Error {
  constructor(message, details = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = details.status ?? null;
    this.statusText = details.statusText ?? '';
    this.url = details.url ?? '';
    this.payload = details.payload ?? null;
  }
}

function normalizeBaseUrl(baseUrl) {
  return String(baseUrl || '').replace(/\/+$/, '');
}

function normalizePath(path) {
  const normalized = String(path || '').trim();
  if (!normalized) {
    return '';
  }

  return normalized.startsWith('/') ? normalized : `/${normalized}`;
}

export function createUrl(path, params = {}) {
  const url = new URL(`${normalizeBaseUrl(API_BASE_URL)}${normalizePath(path)}`);

  Object.entries(params).forEach(([key, value]) => {
    if (value === null || value === undefined || value === '') {
      return;
    }

    if (Array.isArray(value)) {
      value.forEach((item) => {
        if (item !== null && item !== undefined && item !== '') {
          url.searchParams.append(key, item);
        }
      });
      return;
    }

    url.searchParams.set(key, value);
  });

  return url;
}

export function withPeriodParams(period = {}) {
  return {
    anio: period.anio ?? DEFAULT_PERIOD.anio,
    periodo: period.periodo ?? DEFAULT_PERIOD.periodo,
    tipoFiltro: period.tipoFiltro ?? DEFAULT_PERIOD.tipoFiltro,
  };
}

async function parseResponseBody(response) {
  const contentType = response.headers.get('content-type') || '';

  if (contentType.includes('application/json')) {
    return response.json();
  }

  if (contentType.startsWith('text/')) {
    return response.text();
  }

  const rawText = await response.text();
  if (!rawText) {
    return null;
  }

  try {
    return JSON.parse(rawText);
  } catch {
    return rawText;
  }
}

async function buildApiError(response, url) {
  let payload = null;

  try {
    payload = await parseResponseBody(response);
  } catch {
    payload = null;
  }

  const message = `API ${response.status}: ${response.statusText || 'Request failed'}`;
  return new ApiError(message, {
    status: response.status,
    statusText: response.statusText,
    url,
    payload,
  });
}

export async function request(path, options = {}) {
  const {
    method = 'GET',
    params,
    body,
    headers = {},
    signal,
    credentials = 'include',
  } = options;

  const url = createUrl(path, params).toString();
  const isJsonBody = body !== undefined && body !== null && !(body instanceof FormData);

  let response;

  try {
    response = await fetch(url, {
      method,
      signal,
      credentials,
      headers: {
        ...(isJsonBody ? { 'Content-Type': 'application/json' } : {}),
        ...headers,
      },
      body: body === undefined || body === null
        ? undefined
        : isJsonBody
          ? JSON.stringify(body)
          : body,
    });
  } catch (error) {
    if (error?.name === 'AbortError') {
      throw error;
    }

    throw new ApiError('Network error while requesting dashboard API.', {
      status: null,
      statusText: error?.message || 'Network error',
      url,
      payload: error,
    });
  }

  if (response.status === HTTP_STATUS.NO_CONTENT) {
    return null;
  }

  if (!response.ok) {
    throw await buildApiError(response, url);
  }

  if (response.status === HTTP_STATUS.OK) {
    return parseResponseBody(response);
  }

  return null;
}

export function get(path, options = {}) {
  return request(path, { ...options, method: 'GET' });
}
