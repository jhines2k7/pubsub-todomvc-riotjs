/*global riot */
import "../dist/components/todos";
import "../dist/components/todos.header";
import "../dist/components/todos.container";
import "../dist/components/todos.footer";

import EventStore from './EventStore'

let eventStore = new EventStore();
riot.mount("*", eventStore);

// A hash to store our routes:
let routes = {};

function route (path, controller) {
    routes[path] = {controller: controller};
}

function router () {
    // Current route url (getting rid of '#' in hash as well):
    var url = location.hash.slice(1) || '/';
    // Get route by url:
    var route = routes[url];

    route.controller();
}
// Listen on hash change:
window.addEventListener('hashchange', router);
// Listen on page load:
window.addEventListener('load', router);

route('/', function () {
    "use strict";

    console.log('All controller fired');
});

route('/active', function () {
    "use strict";
    console.log('Active controller fired');
});

route('/completed', function () {
    "use strict";

    console.log('Completed controller fired');
});
