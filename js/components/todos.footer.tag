<todo-footer>
    <footer class="footer">
        <!-- This should be `0 items left` by default -->
        <span class="todo-count"><strong>{ items_left }</strong> { items_left === 1 ? "item left" : "items left" }</span>
        <!-- Remove this if you don't implement routing -->
        <ul class="filters">
            <li>
                <a class={ selected: filter == 'all' } href="#/">All</a>
            </li>
            <li>
                <a class={ selected: filter == 'active' } href="#/active">Active</a>
            </li>
            <li>
                <a class={ selected: filter == 'completed' } href="#/completed">Completed</a>
            </li>
        </ul>
        <!-- Hidden if no completed items are left ↓ -->
        <button if={ completed_items > 0 } onclick={ clear } class="clear-completed">Clear completed</button>
    </footer>

    <script>
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.items_left = 0;
        this.subscriptions = {};
        this.completed_items = 0;
        this.filter = 'all';

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
            this.subscribe('sync', 'todo.toggle');
            this.subscribe('sync', 'todo.toggle.all');
            this.subscribe('sync', 'todo.clear');
            this.subscribe('routing', 'todo.filter.all');
            this.subscribe('routing', 'todo.filter.active');
            this.subscribe('routing', 'todo.filter.completed');
        });

        this.clear = function() {
            let lastToggleEvent = eventStore.events.filter( (event) => {
                return event.topic === 'todo.toggle' || event.topic === 'todo.toggle.all';
            }).pop();

            let todos = lastToggleEvent.data.todos.filter( (todo) => {
                return todo.completed === false;
            });

            let clearCompletedEvent = {
                channel: "sync",
                topic: `todo.clear`,
                eventType: 'click',
                data: {
                    todos: todos,
                    itemsLeft: todos.length
                }
            };

            eventStore.add(clearCompletedEvent);
        }.bind(this);

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.items_left = state.itemsLeft;
                    this.completed_items = state.completedItems;
                    this.filter = state.filter;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        };

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                if(event.topic === 'todo.toggle.all') {
                    if(event.data.markAllComplete === true) {
                        state.itemsLeft = 0;
                        state.completedItems = event.data.todos.length;
                    } else {
                        state.itemsLeft = event.data.todos.length;
                        state.completedItems = 0;
                    }
                } else if(event.topic === 'todo.clear'){
                    state.itemsLeft = event.data.todos.length;
                    state.completedItems = 0;
                } else if(event.channel !== 'routing') {
                    state.itemsLeft += event.data.itemsLeft;
                    state.completedItems += event.data.completedItems;
                }

                state.filter = event.data.filter;

                return state;
            }, {
                itemsLeft: 0,
                completedItems: 0,
                filter: 'all'
            });
        }
    </script>
</todo-footer>