fs = require 'fs'
util = require 'util'
path = require 'path'
postcss = require 'postcss'
precss = require 'precss'
sugarss = require 'sugarss'
postcss_color_function = require 'postcss-color-function'
postcss_advanced_variables = require 'postcss-advanced-variables'
autoprefixer = require 'autoprefixer'

VERBOSE = process.env.METASERVE_VERBOSE?

# ------------------------------------------------------------------------------

mapObj = (o, f) ->
    mapped = {}
    Object.keys(o).forEach (k) ->
        v = o[k]
        if typeof v == 'object'
            mapped[k] = mapObj v, f
        else
            mapped[k] = f v
    return mapped

mapFilteredNodes = (root, filter, fn) ->
    root.nodes.map (node) ->
        if filter(node)
            fn node
        if node.nodes?
            node = mapFilteredNodes node, filter, fn

# ------------------------------------------------------------------------------

module.exports =
    ext: 'sass'

    default_config:
        content_type: 'text/css'

    compile: (filename, config, context, cb) ->
        console.log '[PostCSSCompiler.compile]', filename, config if VERBOSE

        source = fs.readFileSync(filename).toString()

        # Build plugins list
        plugins = [precss, postcss_advanced_variables, postcss_color_function]
        if config.plugins?
            for plugin in config.plugins
                if plugin[0] not in ['.', '/']
                    plugin = './node_modules/' + plugin
                plugins.push require path.resolve process.cwd(), plugin
        plugins.push autoprefixer

        postcss(plugins)
            .process source, {parser: sugarss}
            .then (compiled) ->
                compiled = compiled.content
                cb null, {
                    content_type: config.content_type
                    source
                    compiled
                }
            .catch (err) ->
                cb err

