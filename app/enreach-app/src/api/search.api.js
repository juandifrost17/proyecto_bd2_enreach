import { get } from '@/api/client';

export const searchApi = {
  searchPartners(query = '', signal) {
    return get('/partner/search', { params: { query }, signal });
  },

  searchClientes(query = '', signal) {
    return get('/cliente/search', { params: { query }, signal });
  },
};

export default searchApi;
