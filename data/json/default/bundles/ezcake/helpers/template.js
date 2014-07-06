exports.template = {
"name":"template",
"args":["path", "template", "data", "callback"],
"dependencies":["fs","path","writeFile"],
"body":"writeFile path, (_.template template, data), (e) => callback e"
};