const yaml = require("js-yaml");

module.exports = function (eleventyConfig) {
  // Parse YAML data files
  eleventyConfig.addDataExtension("yaml", (contents) => yaml.load(contents));

  // Zero-pad numbers: {{ 5 | pad(2) }} → "05"
  eleventyConfig.addFilter("pad", (num, size) => String(num).padStart(size, "0"));

  // Passthrough copy for static assets
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("2026/**/*.pptx");
  eleventyConfig.addPassthroughCopy("2026/**/*.png");

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
