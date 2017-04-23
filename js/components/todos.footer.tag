<todo-footer>
    <footer class="footer">
        <!-- This should be `0 items left` by default -->
        <span class="todo-count"><strong>{ items_left }</strong> { items_left === 1 ? "item left" : "items left" }</span>
        <!-- Remove this if you don't implement routing -->
        <ul class="filters">
            <li>
                <a class="selected" href="#/">All</a>
            </li>
            <li>
                <a href="#/active">Active</a>
            </li>
            <li>
                <a href="#/completed">Completed</a>
            </li>
        </ul>
        <!-- Hidden if no completed items are left ↓ -->
        <button class="clear-completed">Clear completed</button>
    </footer>

    <script>
        import postal from 'postal/lib/postal.lodash'

        import { log } from "../../js/util";

        let eventStore = opts.event_store;

        this.items_left = 0;
        this.subscriptions = {};
        this.completedItems = false;

        this.on('before-mount', function() {
            this.subscribe('sync', 'todo.add');
        });

        this.subscribe = function(channel, topic) {
            let subscription = postal.subscribe({
                channel: channel,
                topic: topic,
                callback: function(data, envelope) {
                    let events = eventStore.filter(this.subscriptions);

                    let state = this.reduce(events);

                    this.items_left = state.itemsLeft;
                    this.completedItems = state.completedItems;

                    this.update();

                }.bind(this)
            });

            this.subscriptions[topic] = subscription;

            return subscription;
        };

        this.reduce = function(events) {
            return events.reduce(function(state, event){
                if(event.topic === 'todo.add') {
                    state.itemsLeft += event.data.itemsLeft;

                    return state;
                }
            }, {
                itemsLeft: 0,
                completedItems: 0
            });
        }
    </script>
</todo-footer>