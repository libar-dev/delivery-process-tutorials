import { defineConfig } from "@libar-dev/architect/config";

export default defineConfig({
  preset: "libar-generic",
  sources: {
    typescript: ["src/sample-sources/**/*.ts"],
    features: ["src/specs/**/*.feature", "src/decisions/**/*.feature"],
    stubs: ["src/stubs/**/*.ts"],
  },
  output: {
    directory: "docs-generated",
    overwrite: true,
  },
  generatorOverrides: {
    adrs: {
      replaceFeatures: ["src/decisions/**/*.feature"],
    },
  },
  referenceDocConfigs: [
    {
      title: "Identity & Persistence Reference",
      conventionTags: [],
      behaviorCategories: ["core", "api", "infra"],
      diagramScopes: [
        {
          archContext: ["identity", "persistence"],
          direction: "LR",
          title: "System Architecture",
          diagramType: "graph",
          showEdgeLabels: true,
        },
      ],
      claudeMdSection: "reference",
      docsFilename: "IDENTITY-PERSISTENCE-REFERENCE.md",
      claudeMdFilename: "identity-persistence-reference.md",
    },
  ],
});
