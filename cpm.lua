---@class cpm
local cpm = {}
cmake.cpm = cpm

local loaded = false
---@param path string
function cpm.load(path)
    cmake.include(path)
    loaded = true
end

---@class cpm.config
---@field name string
---@field version string | nil
---@field patches string | string[] | nil
---@field options table<string, string> | nil
---@field download_only boolean | nil
---
---@field url string | string[] | nil
---@field url_hash string | nil
---
---@field git_repository string | nil
---@field git_tag string | nil
---
---@field github_repository string | nil
---@field gitlab_repository string | nil
---
---@field exclude_from_all boolean | nil
---@field system boolean | nil

---@param config string | cpm.config
---@param imports string[] | nil
function cpm.add_package(config, imports)
    if not loaded then
        error("cpm is not loaded use 'cpm.load(<path>)'")
    end

    if type(config) == "string" then
        cmake.generator.add_action({
            name = "cpm.add_package.str",
            ---@param context string
            func = function(builder, context)
                builder:append_line("CPMAddPackage(", context, ")")
            end,
            context = config
        })
        return
    end

    cmake.generator.add_action({
        name = "cpm.add_package.config",
        ---@param context cpm.config
        func = function(builder, context)
            builder:append_line("CPMAddPackage(")
                :modify_indent(1)
                :append_line("NAME ", context.name)

            if context.version then
                builder:append_line("VERSION ", context.version)
            end

            if context.url then
                if type(context.url) == "string" then
                    builder:append_line("URL ", context.url)
                else
                    local urls = context.url
                    ---@cast urls -nil, -string

                    builder:append_line("URL")
                    for _, url in ipairs(urls) do
                        builder:append_indent()
                            :append_line(url)
                    end
                end
            end

            if context.url_hash then
                builder:append_line("URL_HASH ", context.url_hash)
            end

            if context.git_repository then
                builder:append_line("GIT_REPOSITORY ", context.git_repository)
            end

            if context.git_tag then
                builder:append_line("GIT_TAG ", context.git_tag)
            end

            if context.github_repository then
                builder:append_line("GITHUB_REPOSITORY \"", context.github_repository, "\"")
            end

            if context.gitlab_repository then
                builder:append_line("GITLAB_REPOSITORY \"", context.gitlab_repository, "\"")
            end

            if context.patches then
                local patches = context.patches
                if type(patches) == "string" then
                    ---@cast patches string
                    builder:append_line("PATCHES \"", context.patches, "\"")
                else
                    ---@cast patches string[]
                    builder:append_line("PATCHES")

                    for _, patch in ipairs(patches) do
                        builder:append_indent()
                            :append_line("\"", patch, "\"")
                    end
                end
            end

            if context.options then
                builder:append_line("OPTIONS")
                for key, value in pairs(context.options) do
                    builder:append_indent()
                        :append_line("\"", key, " ", value, "\"")
                end
            end

            if context.download_only ~= nil then
                builder:append("DOWNLOAD_ONLY ")
                if context.download_only then
                    builder:append_line("TRUE")
                else
                    builder:append_line("FALSE")
                end
            end

            if context.exclude_from_all ~= nil then
                builder:append("EXCLUDE_FROM_ALL ")
                if context.exclude_from_all then
                    builder:append_line("TRUE")
                else
                    builder:append_line("FALSE")
                end
            end

            if context.system ~= nil then
                builder:append("SYSTEM ")
                if context.exclude_from_all then
                    builder:append_line("TRUE")
                else
                    builder:append_line("FALSE")
                end
            end

            builder:modify_indent(-1)
                :append_line(")")
        end,
        context = config
    })

    if imports then
        for _, import in ipairs(imports) do
            cmake.registry.add_entry({
                get_name = function()
                    return import
                end,

                on_dep = function(entry)
                    entry.add_links({ import })
                end
            })
        end
    end
end
