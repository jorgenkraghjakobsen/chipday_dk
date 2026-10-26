// Point the shared map script in base.njk at the DTU Chipday 2027 venue.
module.exports = {
  eleventyComputed: {
    mapEvent: (data) => data.dtu2027,
  },
};
