import { config, fields, collection } from "@keystatic/core"

export default config({
    storage: {
        kind: "local",
    },
    collections: {
        blog: collection({
            label: "Blog",
            slugField: "title",
            path: "src/content/blog/*",
            format: { contentField: "content" },
            schema: {
                title: fields.slug({
                    name: { label: "Title" },
                    slug: { label: "Slug" },
                }),
                description: fields.text({
                    label: "Description",
                    multiline: true,
                }),
                date: fields.date({
                    label: "Date",
                }),
                tags: fields.array(fields.text({ label: "Tag" }), {
                    label: "Tags",
                    itemLabel: (data) => data.value,
                }),
                readTime: fields.text({
                    label: "Read time",
                }),
                draft: fields.checkbox({
                    label: "Draft",
                    defaultValue: false,
                }),
                thumbnail: fields.image({
                    label: "Thumbnail",
                    directory: "public",
                    publicPath: "/",
                }),
                thumbnailAlt: fields.text({
                    label: "Thumbnail alt",
                }),
                content: fields.mdx({
                    label: "Content",
                }),
            },
        }),
    },
})
