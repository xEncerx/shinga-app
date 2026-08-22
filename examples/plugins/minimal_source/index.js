export default {
  async getSearchSchema() {
    return { fields: [], sorts: [] };
  },

  async search() {
    return { items: [], pagination: { kind: "end" } };
  },

  async getTitle(_context, sourceTitleId) {
    return { id: sourceTitleId, title: sourceTitleId };
  },
};
