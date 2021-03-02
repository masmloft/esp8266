
function dumpProperty(key, value, level)
{
    var indent = ''
    for (var k=0; k < level; ++k)
        indent += '  '
    console.info(indent + key + ': ' + value)
}

function traverseObject(obj, func, level)
{
    if (!level)
        level = 0
    var i, children = {}
    for (i in obj) {
        if (typeof(obj[i]) === "object" && !(obj[i] instanceof Array))
            children[i] = obj[i]
        else
            func.apply(this, [i, obj[i], level])
    }
    level++
    for (i in children) {
        func.apply(this, [i, children[i], level - 1])
        traverseObject(children[i], func, level)
    }
    level--
}

function dumpObject(obj, description)
{
    if (!description)
        description = 'object dump'
    console.info('+++++++++ ' + description + ' +++++++++')
    traverseObject(obj, dumpProperty)
}

