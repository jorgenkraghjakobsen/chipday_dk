// Point the shared map script in base.njk at the SDU venue.
module.exports = {
  eleventyComputed: {
    mapEvent: (data) => data.sdu,
  },
};
