const yaml = require("js-yaml");

module.exports = function (eleventyConfig) {
  // Parse YAML data files
  eleventyConfig.addDataExtension("yaml", (contents) => yaml.load(contents));

  // Passthrough copy for static assets
  eleventyConfig.addPassthroughCopy("assets");

  // Filter: get archive entry by year
  eleventyConfig.addFilter("getByYear", function (arr, year) {
    return arr.find((item) => item.year === year);
  });

  return {
    dir: {
      input: ".",
      includes: "_includes",
      data: "_data",
      output: "_site",
    },
    templateFormats: ["njk", "md"],
    htmlTemplateEngine: "njk",
  };
};
