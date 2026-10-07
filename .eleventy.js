const yaml = require("js-yaml");

module.exports = function (eleventyConfig) {
  // Parse YAML data files
  eleventyConfig.addDataExtension("yaml", (contents) => yaml.load(contents));

  // Zero-pad numbers: {{ 5 | pad(2) }} → "05"
  eleventyConfig.addFilter("pad", (num, size) => String(num).padStart(size, "0"));

  // Passthrough copy for static assets
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy("backstage/**/*.pptx");
  eleventyConfig.addPassthroughCopy("backstage/**/*.png");
  eleventyConfig.addPassthroughCopy("archive/2026_dtu/photos");
  eleventyConfig.addPassthroughCopy("archive/2026_dtu/presentations");
  eleventyConfig.addPassthroughCopy("archive/2026_dtu/*.pdf");

  // Filter: events with status "upcoming" (Nunjucks selectattr can't test equality)
  eleventyConfig.addFilter("upcomingEvents", (events) => events.filter((e) => e.status === "upcoming"));

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
