var http = require('http')
const { exit } = require('process')

let repeat  = parseInt(process.argv[2])

function dorequest(repeat) {
    
    //var data = 'n=' + repeat.toString()
    var options = {
        host: 'MY_IBM_I',
        port: '1302',
        path: '/test/' + repeat,
        method: 'GET',
        headers: {
            'repeat': repeat
            //'Content-Type': 'application/x-www-form-urlencoded',
            //'Content-Length': data.length
        }
    }

    callback = function(response) {
        var str = ''

        // another chunk of data has been received, so append it to `str`
        response.on('data', function (chunk) {
            str += chunk
        });

        // the whole response has been received, so we just print it out here
        response.on('end', function () {
            console.log("req %d, resp: %s" , repeat,str )
            var ret = str.split(':');
            var retcnt = ret[3];
            if (retcnt != repeat) {
                console.log("!!!!!!!" , retcnt , repeat)
                exit();
            }
            if (repeat > 1) {
                dorequest (repeat - 1 )
            }
        });
    }
    var req = http.request(options, callback)
    //req.write(data)
    req.end()  
}
dorequest ( repeat )
