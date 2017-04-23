/*global riot */
import "../dist/components/counter";

import EventStore from './EventStore'

let eventStore = new EventStore();
riot.mount("*", eventStore);
