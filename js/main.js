/*global riot */
import "../dist/components/todo-app";
import "../dist/components/todo-app.header";
import "../dist/components/todo-app.container";
import "../dist/components/todo-app.footer";

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

    let lastTodoEvent = eventStore.events.filter( (event) => {
        return event.topic === 'todo.add' || event.topic === 'todo.toggle'
            || event.topic === 'todo.toggle.all' || event.topic === 'todo.clear';
    }).pop();

    eventStore.add({
        channel: 'routing',
        topic: 'todo.filter.all',
        eventType: 'click',
        state: {
            todos: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.todos : [],
            filter: 'all',
            completedTodos: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.completedTodos : 0,
            markAllComplete: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.markAllComplete : false
        }
    });
});

route('/active', function () {
    "use strict";

    let lastTodoEvent = eventStore.events.filter( (event) => {
        return event.topic === 'todo.add' || event.topic === 'todo.toggle'
            || event.topic === 'todo.toggle.all' || event.topic === 'todo.clear';
    }).pop();

    let todos = lastTodoEvent.state.todos.filter( (todo) => {
        return todo.completed === false;
    });

    eventStore.add({
        channel: 'routing',
        topic: 'todo.filter.active',
        eventType: 'click',
        state: {
            todos: todos,
            filter: 'active',
            completedTodos: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.completedTodos : 0,
            markAllComplete: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.markAllComplete : false
        }
    });
});

route('/completed', function () {
    "use strict";

    let lastTodoEvent = eventStore.events.filter( (event) => {
        return event.topic === 'todo.add' || event.topic === 'todo.toggle'
            || event.topic === 'todo.toggle.all' || event.topic === 'todo.clear';
    }).pop();

    let todos = lastTodoEvent.state.todos.filter( (todo) => {
        return todo.completed === true;
    });

    eventStore.add({
        channel: 'routing',
        topic: 'todo.filter.completed',
        eventType: 'click',
        state: {
            todos: todos,
            filter: 'completed',
            completedTodos: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.completedTodos : 0,
            markAllComplete: lastTodoEvent && lastTodoEvent.state ? lastTodoEvent.state.markAllComplete : false
        }
    });
});
