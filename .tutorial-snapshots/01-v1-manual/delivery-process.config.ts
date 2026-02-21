import { defineConfig } from "@libar-dev/delivery-process/config";

export default defineConfig({
  preset: "libar-generic",
  sources: {
    typescript: ["src/sample-sources/**/*.ts"],
    features: ["src/specs/**/*.feature"],
    stubs: ["src/stubs/**/*.ts"],
  },
  output: {
    directory: "docs-generated",
    overwrite: true,
  },
  referenceDocConfigs: [
    {
      title: "Identity & Persistence Reference",
      conventionTags: [],
      shapeSources: ["src/sample-sources/**/*.ts"],
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
