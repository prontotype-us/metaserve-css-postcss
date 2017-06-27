fs = require 'fs'
util = require 'util'
postcss = require 'postcss'
precss = require 'precss'
sugarss = require 'sugarss'
autoprefixer = require 'autoprefixer'
postcss_bounce = require '../../../postcss-bounce/src'

VERBOSE = process.env.METASERVE_VERBOSE?

print = (o) -> console.log util.inspect o, depth: null, colors: true

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
        console.log 'source', source

        # postcss([precss, customplugin, autoprefixer])
        postcss([precss, postcss_bounce])
            .process source, {parser: sugarss}
            .then (compiled) ->
                compiled = compiled.content
                cb null, {
                    content_type: config.content_type
                    source
                    compiled
                }
            .catch (err) ->
                console.log 'faileure', err
                cb err


