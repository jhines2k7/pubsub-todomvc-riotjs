/*global riot */
import "../dist/components/todos";
import "../dist/components/todos.header";
import "../dist/components/todos.container";
import "../dist/components/todos.footer";

import EventStore from './EventStore'

let eventStore = new EventStore();
riot.mount("*", eventStore);
